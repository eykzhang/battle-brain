# BattleBrain

**A native iOS companion for competitive Pokémon Showdown players** — team building,
competitive reference data, and replay analysis powered by a real battle engine, in
one polished SwiftUI app backed by serverless AWS infrastructure.

BattleBrain doesn't replace Pokémon Showdown — it sits alongside it, turning raw
battle data into the kind of actionable feedback that helps a player actually improve.

It is one half of a two-project system:

| Project | Role |
|---|---|
| **BattleBrain** (this repo) | The product: a native iOS app — UI, data layer, replay parsing, and cloud backend |
| [**battle-engine**](https://github.com/eykzhang/battle-engine) | The intelligence: an ML/search battle engine ("Stockfish for Pokémon") that produces the win-probability analysis this app surfaces |

## Why this design

The obvious way to build an "AI coach" in 2026 is to hand a battle log to an LLM and
ask for advice. BattleBrain deliberately doesn't do that. LLMs are articulate but
unreliable *players* — they can't search a game tree, and they hallucinate damage
ranges. So the roles are split:

- **The engine plays.** A dedicated search + machine-learning engine (separate repo)
  evaluates positions and finds strong lines, the way Stockfish does for chess.
- **The LLM explains.** Apple's on-device Foundation Models framework translates the
  engine's structured output — eval swings, the best line vs. the line actually
  played — into plain-language coaching. It never invents strategy; it narrates
  ground truth.

This "ML plays, LLM explains" split is the project's core architectural thesis, and it
mirrors how serious game-analysis products (chess.com, Lichess) actually work.

## Features

| Pillar | Description |
|---|---|
| **Team Builder** | Full-depth native team editor — legality-aware species/move/ability/item search, EV/IV editing with live stat calculation, nature selection, SwiftData persistence, Showdown text import/export. |
| **Competitive Database** | Per-Pokémon competitive reference — base stats, typing, abilities, usage statistics, and common sets, from curated Smogon + PokeAPI data refreshed by the AWS pipeline. |
| **Replay Analysis** *(flagship)* | Paste a Showdown replay URL → the app parses the raw battle protocol on-device, reconstructs the battle turn by turn in an interactive timeline, and overlays a per-turn win-probability graph computed by the engine. |
| **AI Coach** | For any pivotal turn, on-device natural-language coaching grounded entirely in the engine's structured analysis — explanatory, not a black box. |
| **Battle Companion** | A manual-entry reference screen for use alongside a live desktop battle — weakness charts, speed tiers, coverage gaps, and a damage calculator that update as opponents are revealed. Deliberately manual: no live engine assistance during ranked play, which would violate Showdown's rules. |

## Architecture

**iOS app** — Swift, SwiftUI, SwiftData, targeting iOS 26 / Apple Intelligence-capable
devices. The view architecture is intentionally hybrid rather than dogmatic:
CRUD-shaped screens (Database, Team Builder) bind SwiftData `@Query` directly in
views — the framework already provides live reactivity, and wrapping it in ViewModels
would only re-publish the same data — while orchestration-heavy features (Replay
Analysis, AI Coach, Battle Companion) get dedicated `@Observable` ViewModels because
they manage real async pipelines and need to be unit-testable. Choosing per-screen
instead of applying one pattern uniformly was a deliberate, documented decision.

**Data layer** — a versioned competitive dataset (species, moves, abilities, items,
usage stats, sample sets) baked by a Python pipeline from Smogon and PokeAPI sources,
bundled with the app for offline/first-launch use, and refreshed from the cloud API.

**AWS backend** ("BattleBrain Data Service") — serverless and defined entirely as
infrastructure-as-code (SAM/CDK):
- a scheduled data pipeline (EventBridge → Lambda → S3) that refreshes competitive
  data and serves it via API Gateway;
- an engine analysis service that runs the battle engine against submitted replays
  and caches per-turn evaluations in DynamoDB;
- opt-in cross-device team sync (Cognito + DynamoDB) as a stretch goal.

## Tech stack

- **iOS**: Swift, SwiftUI, SwiftData, Foundation Models framework
- **Cloud**: AWS Lambda, API Gateway, DynamoDB, S3, EventBridge, Cognito; SAM/CDK
- **Data pipeline**: Python (Smogon/`pkmn` data + PokeAPI, cached and normalized)
- **Tooling**: XcodeGen (project generated from a versioned `project.yml` spec)

## Project status

In active development, built in deliberate end-to-end slices:

- [x] Project scaffolding (XcodeGen, feature-first module structure)
- [x] Core data layer + baked competitive dataset (gen9 OU/VGC sets, usage stats, full legal movepools)
- [x] Competitive Database (search, per-Pokémon detail, usage data)
- [x] Team Builder (legality-aware pickers, EV/IV editor, import/export)
- [ ] AWS data pipeline + dataset API
- [ ] Replay Analysis (protocol parser + interactive timeline)
- [ ] Engine integration (win-probability overlay via the AWS analysis service)
- [ ] AI Coach (Foundation Models explainer over engine output)
- [ ] Battle Companion

## Getting started

The `.xcodeproj` is generated from `project.yml` via
[XcodeGen](https://github.com/yonaskolb/XcodeGen) and isn't checked in:

```sh
brew install xcodegen
xcodegen generate
open BattleBrain.xcodeproj
```

Or build from the command line:

```sh
xcodebuild -project BattleBrain.xcodeproj -scheme BattleBrain \
  -destination 'generic/platform=iOS Simulator' build
```

Requires Xcode with the iOS 26 SDK — BattleBrain targets Apple Intelligence-capable
devices (iPhone 15 Pro or newer) for the Foundation Models framework.
