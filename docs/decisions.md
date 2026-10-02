# Decision log

Newest first. Status: **Open** (needs Ivan), **Proposed** (Claude's recommendation, awaiting a yes), **Decided**.

---

## D-010 · Website — Decided (2026-10-02)
A static marketing site in its own public repo, `ivan-zdravkov/tilt-for-the-win-website`, served by GitHub Pages at
**https://tilt-for-the-win.zdravkov.dev** (DNS: a GoDaddy CNAME `tilt-for-the-win` → `ivan-zdravkov.github.io`).
It also hosts the privacy policy, and `app-ads.txt` later. It's plain HTML/CSS with no build step.

## D-009 · CI/CD architecture — Proposed
- **Every push/PR** (Ubuntu runner): Godot headless import → unit tests → Android debug export (catches export breakage).
- **Push to `master`**: Android release AAB (signed with the upload key) → Google Play **internal** track;
  Godot exports the Xcode project on Ubuntu → a **macOS runner** archives, signs and uploads to **TestFlight**.
- Promoting to closed/production is a manual click in the store consoles for now (safer; automate later).
- Tooling: the official Godot binaries and export templates (pinned to the same version as `tools/setup-dev.sh`), fastlane
  for iOS signing/upload, and the Play Developer API for Android upload. iOS signing assets are created **on Linux** with
  openssl plus the App Store Connect API, so no Mac is needed.
- Note: Google Play's API cannot create a new app, so the **first** AAB upload is done by hand in Play Console.

## D-008 · Test framework — Proposed: gdUnit4
GDScript unit and scene tests, a headless CLI runner, a maintained GitHub Action and JUnit reports. GUT is the simpler alternative.
Test layers: pure logic (maze generator: solvable, deterministic per seed; timer formatting; ad-pacing rules) →
scene tests (ball rolls downhill under simulated tilt, goal triggers) → CI export smoke tests.

## D-007 · Secrets — Decided
None in the repo, ever. Password manager + GitHub Actions secrets; see `docs/guides/secrets.md`.

## D-006 · License — Decided
Proprietary, **all rights reserved**, even though the source is publicly visible (`LICENSE`). Third-party licenses go into
`THIRD_PARTY_NOTICES.md` and the in-game credits. (Not legal advice; if the game takes off, also consider registering
the name/logo as a trademark.)

## D-005 · Repo visibility — Decided: public
Unlimited free GitHub Actions minutes (macOS included) for public repos. Secrets stay in Actions secrets.
Git LFS on a free account: about 10 GiB storage + 10 GiB bandwidth/month. Keep assets lean and cache LFS in CI.

## D-004 · Daily leaderboard mechanics — Open (spike #8)
How to get a **daily reset** on EOS leaderboards, and which login (Device ID vs Apple/Google). The fallback is
Game Center + Play Games daily leaderboards (one per platform).

## D-003 · Ads provider — Proposed: Google AdMob (+ UMP consent SDK)
For Godot: the community AdMob plugin (Poing Studios `godot-admob-plugin`, Android + iOS). Check it supports Godot 4.7
before M4. iOS also needs the ATT prompt.

## D-002 · Store accounts & identity — Decided
Personal accounts under Ivan's legal name. Bundle ID / package name: **`dev.zdravkov.tiltforthewin`**.
- Google Play: a new account ($25). New personal accounts need a **closed test with ≥12 testers for 14 days** before production.
- Apple Developer Program: $99/year, individual. Testing on Ivan's iPhone goes through **TestFlight** (no local Mac).

## D-001 · Game engine — Decided: Godot 4.7.2, GDScript (2026-10-02)
Lightweight Linux editor; Android builds on Linux; iOS via an exported Xcode project built on GitHub's macOS
runners (Ivan has a work Mac but won't use it). **GDScript** rather than C#: it has the best mobile/iOS support,
the smallest builds, and most plugins (AdMob, EOS) target it. The engine version is pinned in `tools/setup-dev.sh` and
CI, and upgrades are deliberate. Unity/Unreal were considered (see git history of this file).
