#!/usr/bin/env python3
"""
Bakes the small bundled fallback dataset used by BattleBrain's Core data layer.

Not part of the app build — run manually (or on a schedule, later, by the AWS
data pipeline) to produce BattleBrain/Resources/dataset.json:

    python3 Scripts/bake_dataset.py

Sources (see plan doc for why): Smogon sample sets + usage stats via
pkmn.github.io/smogon/data, base species data via PokeAPI. Scoped to gen9ou
(singles) and gen9vgc (doubles) only — see plan's "Dataset scope" decision.

Known scoping simplifications (documented, not oversights):
- VGC sample sets lag the current regulation upstream, so sets come from
  gen9vgc2025 while usage stats come from the current gen9vgc2026.
- Where Smogon lists alternative moves/natures/tera types for a set, only the
  first (primary) alternative is kept — full alternative-set support is a
  post-MVP enhancement, not required for the Team Builder/Database MVP scope.
- The upstream `counters` field (used for topThreats) is genuinely sparse: most
  gen9ou species and ALL gen9vgc2026 species have it empty upstream (verified,
  not a bug in this script). UI consuming topThreats must handle the empty case.
"""

import json
import re
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CACHE_DIR = ROOT / "Scripts" / ".pokeapi_cache"
OUTPUT_PATH = ROOT / "BattleBrain" / "Resources" / "dataset.json"

SETS_FORMATS = {
    "gen9ou": "https://pkmn.github.io/smogon/data/sets/gen9ou.json",
    "gen9vgc": "https://pkmn.github.io/smogon/data/sets/gen9vgc2025.json",
}
STATS_FORMATS = {
    "gen9ou": "https://pkmn.github.io/smogon/data/stats/gen9ou.json",
    "gen9vgc": "https://pkmn.github.io/smogon/data/stats/gen9vgc2026.json",
}

# Manual overrides for species whose Smogon display name doesn't map cleanly
# to a PokeAPI slug via the generic normalizer below.
SLUG_OVERRIDES = {
    "Farfetch'd": "farfetchd",
    "Sirfetch'd": "sirfetchd",
    "Mr. Mime": "mr-mime",
    "Mr. Rime": "mr-rime",
    "Mime Jr.": "mime-jr",
    "Type: Null": "type-null",
    "Jangmo-o": "jangmo-o",
    "Hakamo-o": "hakamo-o",
    "Kommo-o": "kommo-o",
    "Nidoran-F": "nidoran-f",
    "Nidoran-M": "nidoran-m",
    "Basculegion-F": "basculegion-female",
    "Indeedee-F": "indeedee-female",
    "Necrozma-Dawn-Wings": "necrozma-dawn",
    "Necrozma-Dusk-Mane": "necrozma-dusk",
    "Ogerpon-Cornerstone": "ogerpon-cornerstone-mask",
    "Ogerpon-Hearthflame": "ogerpon-hearthflame-mask",
    "Ogerpon-Wellspring": "ogerpon-wellspring-mask",
    "Tauros-Paldea-Blaze": "tauros-paldea-blaze-breed",
}


def fetch_json(url: str) -> dict:
    # PokeAPI (and possibly others) reject the default "Python-urllib/x.y"
    # User-Agent with a 403 — send an explicit one.
    request = urllib.request.Request(url, headers={"User-Agent": "BattleBrain-DatasetBaker/1.0"})
    with urllib.request.urlopen(request) as response:
        return json.load(response)


def slugify_species(display_name: str) -> str:
    if display_name in SLUG_OVERRIDES:
        return SLUG_OVERRIDES[display_name]
    slug = display_name.lower()
    slug = slug.replace("'", "").replace(".", "")
    slug = re.sub(r"[^a-z0-9]+", "-", slug).strip("-")
    return slug


def default_variety_slug(slug: str) -> str | None:
    """Some species (e.g. 'giratina', 'mimikyu') have no bare /pokemon/ entry —
    only named forms do. Resolve the default form via /pokemon-species/."""
    try:
        species_data = fetch_json(f"https://pokeapi.co/api/v2/pokemon-species/{slug}")
    except urllib.error.HTTPError:
        return None
    for variety in species_data.get("varieties", []):
        if variety["is_default"]:
            return variety["pokemon"]["name"]
    return None


def fetch_pokeapi_species(slug: str) -> dict | None:
    cache_path = CACHE_DIR / f"{slug}.json"
    if cache_path.exists():
        return json.loads(cache_path.read_text())

    try:
        data = fetch_json(f"https://pokeapi.co/api/v2/pokemon/{slug}")
    except urllib.error.HTTPError as error:
        if error.code != 404:
            print(f"  ! PokeAPI lookup failed for '{slug}': {error}")
            return None
        fallback_slug = default_variety_slug(slug)
        if fallback_slug is None:
            print(f"  ! PokeAPI lookup failed for '{slug}': no default variety found")
            return None
        try:
            data = fetch_json(f"https://pokeapi.co/api/v2/pokemon/{fallback_slug}")
        except urllib.error.HTTPError as error:
            print(f"  ! PokeAPI lookup failed for '{slug}' (fallback '{fallback_slug}'): {error}")
            return None

    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    cache_path.write_text(json.dumps(data))
    time.sleep(0.05)  # be polite to the free public API
    return data


def stat_value(stats: list[dict], name: str) -> int:
    for entry in stats:
        if entry["stat"]["name"] == name:
            return entry["base_stat"]
    return 0


def first_or_none(value):
    if isinstance(value, list):
        return value[0] if value else None
    return value


def main() -> None:
    print("Fetching Smogon sets and usage stats...")
    sets_by_format = {fmt: fetch_json(url) for fmt, url in SETS_FORMATS.items()}
    stats_by_format = {fmt: fetch_json(url) for fmt, url in STATS_FORMATS.items()}

    species_names: set[str] = set()
    for sets_data in sets_by_format.values():
        species_names.update(sets_data.keys())
    for stats_data in stats_by_format.values():
        species_names.update(stats_data["pokemon"].keys())

    print(f"Found {len(species_names)} unique species across all formats.")

    species_out = []
    slug_by_name: dict[str, str] = {}
    for name in sorted(species_names):
        slug = slugify_species(name)
        pokeapi_data = fetch_pokeapi_species(slug)
        if pokeapi_data is None:
            continue
        slug_by_name[name] = slug
        types = [t["type"]["name"].capitalize() for t in pokeapi_data["types"]]
        abilities = [a["ability"]["name"].replace("-", " ").title() for a in pokeapi_data["abilities"]]
        species_out.append({
            "id": slug,
            "name": name,
            "primaryType": types[0] if len(types) > 0 else "Normal",
            "secondaryType": types[1] if len(types) > 1 else None,
            "hp": stat_value(pokeapi_data["stats"], "hp"),
            "attack": stat_value(pokeapi_data["stats"], "attack"),
            "defense": stat_value(pokeapi_data["stats"], "defense"),
            "specialAttack": stat_value(pokeapi_data["stats"], "special-attack"),
            "specialDefense": stat_value(pokeapi_data["stats"], "special-defense"),
            "speed": stat_value(pokeapi_data["stats"], "speed"),
            "abilities": abilities,
        })

    print(f"Resolved {len(species_out)} species against PokeAPI.")

    sets_out = []
    for fmt, sets_data in sets_by_format.items():
        for species_name, named_sets in sets_data.items():
            slug = slug_by_name.get(species_name)
            if slug is None:
                continue
            for set_name, set_data in named_sets.items():
                evs = first_or_none(set_data.get("evs", {})) or {}
                ivs = first_or_none(set_data.get("ivs", {})) or {}
                moves = [first_or_none(m) for m in set_data.get("moves", [])]
                sets_out.append({
                    "id": f"{fmt}-{slug}-{set_name}",
                    "format": fmt,
                    "speciesId": slug,
                    "setName": set_name,
                    "moves": [m for m in moves if m],
                    "ability": first_or_none(set_data.get("ability")),
                    "item": first_or_none(set_data.get("item")),
                    "nature": first_or_none(set_data.get("nature")),
                    "hpEV": evs.get("hp", 0),
                    "attackEV": evs.get("atk", 0),
                    "defenseEV": evs.get("def", 0),
                    "specialAttackEV": evs.get("spa", 0),
                    "specialDefenseEV": evs.get("spd", 0),
                    "speedEV": evs.get("spe", 0),
                    "hpIV": ivs.get("hp", 31),
                    "attackIV": ivs.get("atk", 31),
                    "defenseIV": ivs.get("def", 31),
                    "specialAttackIV": ivs.get("spa", 31),
                    "specialDefenseIV": ivs.get("spd", 31),
                    "speedIV": ivs.get("spe", 31),
                    "teraType": first_or_none(set_data.get("teratypes")),
                })

    print(f"Collected {len(sets_out)} competitive sets.")

    TOP_N = 5

    def top_teammate_slugs(entry: dict) -> list[str]:
        ranked = sorted(entry.get("teammates", {}).items(), key=lambda kv: kv[1], reverse=True)
        slugs = [slug_by_name[name] for name, _ in ranked if name in slug_by_name]
        return slugs[:TOP_N]

    def top_threat_slugs(entry: dict) -> list[str]:
        # counters[name] = [score, koPercent, switchPercent]; higher score ranks first.
        ranked = sorted(entry.get("counters", {}).items(), key=lambda kv: kv[1][0], reverse=True)
        slugs = [slug_by_name[name] for name, _ in ranked if name in slug_by_name]
        return slugs[:TOP_N]

    usage_out = []
    for fmt, stats_data in stats_by_format.items():
        for species_name, entry in stats_data["pokemon"].items():
            slug = slug_by_name.get(species_name)
            if slug is None:
                continue
            usage_out.append({
                "id": f"{fmt}-{slug}",
                "format": fmt,
                "speciesId": slug,
                "usagePercent": round(entry["usage"]["weighted"] * 100, 2),
                "topTeammates": top_teammate_slugs(entry),
                "topThreats": top_threat_slugs(entry),
            })

    print(f"Collected {len(usage_out)} usage stat entries.")

    dataset = {
        "version": time.strftime("%Y-%m-%d"),
        "species": species_out,
        "sets": sets_out,
        "usage": usage_out,
    }

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(json.dumps(dataset, indent=2))
    print(f"Wrote {OUTPUT_PATH} ({OUTPUT_PATH.stat().st_size / 1024:.0f} KB)")


if __name__ == "__main__":
    main()
