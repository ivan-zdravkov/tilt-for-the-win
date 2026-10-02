# Tilt for the Win — context for Claude

Ball-in-a-maze mobile game (iOS + Android) by Ivan Zdravkov, published under his own name.
Solo developer with a software engineering background; has Unity course/demo experience but has never
shipped a game because the non-game work (builds, stores, ads, UI, marketing) became overwhelming.
**Claude's main job is to absorb that non-game work**: recommend the simplest path, automate it, and
break everything into small, pick-up-able tasks.

## Guiding principles
1. **Published first, perfect second.** Prefer the boring, well-trodden path. Ship to store test tracks early.
2. **Fair monetization.** Tutorial + first daily attempt are ad-free; ads only between daily retries.
3. **Automate everything repeatable.** Push to `master` → test → build → upload to store test tracks.
4. **Small tasks.** Every GitHub issue should be doable in one sitting and state its acceptance criteria.
5. **Public repo, no secrets, proprietary license.** Never commit keys, keystores, passwords or service-account files
   (see `docs/guides/secrets.md`). Every third-party plugin/asset is added to `THIRD_PARTY_NOTICES.md`.

## Stack (see `docs/decisions.md`)
- Godot **4.7.2**, GDScript. Version pinned in `tools/setup-dev.sh` and in CI; upgrade both together.
- Bundle ID / package: `dev.zdravkov.tiltforthewin`.
- iOS: no Mac. Xcode project exported on Linux → built/signed on GitHub macOS runners → TestFlight.
- Android: AAB → Google Play via the Play Developer API.
- Leaderboard: Epic Online Services. Ads: AdMob. Tests: gdUnit4 (proposed).

## Where things live
- `docs/vision.md` — game design and product vision (MVP scope).
- `docs/decisions.md` — decision log (open + settled). Check it before re-litigating anything.
- `docs/roadmap.md` — milestones; the individual tasks live as issues.
- `docs/guides/` — step-by-step guides (secrets, account setup, signing, …).
- `tools/setup-dev.sh` — idempotent local toolchain installer.
- Website: separate public repo `ivan-zdravkov/tilt-for-the-win-website` → https://tilt-for-the-win.zdravkov.dev
  (GitHub Pages; DNS at GoDaddy, which Ivan manages by hand).
- Kanban: GitHub user project #4 (`gh project ... --owner ivan-zdravkov 4`). Tasks are repo issues added to it.
  Project fields: Status (Backlog/Ready/In progress/In review/Done), Priority (P0–P2), Size (XS–XL).
  Every issue gets a milestone (M0–M5, see roadmap), `area:*` labels, `type:decision`/`type:spike` where relevant,
  and an "Acceptance criteria" checklist.

## Dev environment (Bazzite Linux, immutable Fedora/Silverblue)
- Don't layer packages with rpm-ostree. Use Homebrew (CLIs), Flatpak (GUI apps), distrobox, or `~/.local/opt` tarballs.
- Homebrew is not on PATH in non-interactive shells. `gh`, `git-lfs`, `jq` are symlinked into `~/.local/bin`; for other
  brew tools, prefix with `eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"`.
- Toolchain (from `tools/setup-dev.sh`): `godot` and `adb` in `~/.local/bin`; JDK 17 at `~/.local/opt/jdk-17`;
  Android SDK at `~/.local/opt/android-sdk`; export templates in `~/.local/share/godot/export_templates/`.
- Local secrets (if any) go in `~/.config/tilt-for-the-win/`, never in the repo.
- `gh` interactive auth flows must be run by Ivan in a real terminal (the `!` shell is non-interactive).
- Hardware: 12 cores, 30 GB RAM, AMD RX 9060 XT. Test devices: an iPhone and Android phones.

## Conventions
- Default branch: `master`. Work on branches and open PRs; don't commit or push unless asked.
- Binary assets go through Git LFS (`.gitattributes`).
