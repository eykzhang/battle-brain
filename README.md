# BattleBrain

**An intelligent iOS companion for competitive Pokémon Showdown players**, combining a
native team builder, a competitive Pokémon database, AI-assisted replay analysis, and a
cloud-backed sync service into a single application.

BattleBrain doesn't replace Pokémon Showdown — it sits alongside it, turning raw battle
data into the kind of actionable feedback that helps a player actually improve.

## Overview

Competitive Pokémon players have plenty of tools for building teams and looking up
stats, but very little that helps them understand *why* a battle was won or lost.
BattleBrain's flagship feature parses a Showdown replay, reconstructs the battle turn
by turn, and uses Apple's on-device Foundation Models framework to explain the
consequential decisions in plain language — coaching, not just scorekeeping.

The project is also built to be a complete, end-to-end software engineering showcase:
a polished native iOS client backed by a real, infrastructure-as-code AWS service —
not just a frontend demo.

## Features

| Pillar | Description |
|---|---|
| **Team Builder** | Native SwiftUI team builder — species/move/ability/item search, EV/IV editing, nature selection, and local persistence, with optional cloud sync across devices. |
| **Competitive Database** | Rich per-Pokémon reference data — base stats, typing, abilities, usage statistics, and common sets, sourced from Smogon and PokeAPI data. |
| **Replay Analysis** | Paste a Showdown replay URL and get an interactive, turn-by-turn reconstruction of the battle, with key moments automatically surfaced. |
| **AI Coach** | On-device natural-language explanations of pivotal turns via Apple's Foundation Models framework — grounded in reconstructed battle state, not a black box. |
| **Battle Companion** | A manual-entry reference screen for use alongside a live battle on desktop — weakness charts, speed tiers, coverage, and a damage calculator that update as opponents are revealed. |

## Architecture

**iOS app** — Swift, SwiftUI, and SwiftData, structured MVVM with a shared `Core` data
layer feeding independent feature modules (`TeamBuilder`, `Database`, `ReplayAnalysis`,
`AICoach`, `Companion`). Foundation Models inference runs entirely on-device: the app
reconstructs and summarizes battle state itself, and only asks the model to explain an
already-structured event — keeping the AI coaching feature fast, private, and free of
network dependency.

**AWS backend** ("BattleBrain Data Service") — a serverless service, defined entirely as
infrastructure-as-code (AWS SAM/CDK), providing:
- a scheduled data pipeline (EventBridge + Lambda) that refreshes competitive data from
  Smogon and PokeAPI into S3/DynamoDB and serves it via API Gateway,
- opt-in cross-device team sync (Cognito + DynamoDB),
- a replay-analysis cache that avoids redundant re-parsing of previously seen battles.

The iOS app ships with a small bundled dataset so it's fully functional offline and on
first launch, then transparently syncs against the live service.

## Tech stack

- **iOS**: Swift, SwiftUI, SwiftData, Foundation Models framework
- **Cloud**: AWS Lambda, API Gateway, DynamoDB, S3, Cognito, EventBridge; AWS SAM/CDK
- **Tooling**: XcodeGen (project generation from a versioned `project.yml` spec)

## Project status

BattleBrain is in active early development. The Xcode project is scaffolded and
building; feature implementation is in progress following the build order below.

- [x] Project scaffolding (XcodeGen, module structure)
- [x] Core data layer + local competitive dataset
- [ ] Competitive Database
- [ ] Team Builder
- [ ] AWS data pipeline + dataset API
- [ ] Replay Analysis
- [ ] AI Coach
- [ ] Battle Companion

**Stretch, post-MVP:** AWS replay-analysis cache, AWS team sync (Cognito + DynamoDB).

## Getting started

The `.xcodeproj` is generated from `project.yml` via [XcodeGen](https://github.com/yonaskolb/XcodeGen)
and isn't checked into version control:

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
devices (iPhone 15 Pro or newer) to support the Foundation Models framework.
