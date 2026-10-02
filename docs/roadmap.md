# Roadmap

Milestones map 1:1 to GitHub milestones; every task is an issue on project #4.
Order matters: accounts with long lead times (Google's 14-day closed test, Apple enrollment review) start first.

## M0 — Foundations
Engine decided: Godot 4.7.2 (D-001). Disk freed. Toolchain via `tools/setup-dev.sh`. Create the accounts:
Apple Developer, Google Play Console, Epic Developer Portal (EOS), AdMob. Put up a privacy-policy page
on the website (tilt-for-the-win.zdravkov.dev, GitHub Pages). Bundle ID: `dev.zdravkov.tiltforthewin`.

## M1 — Ball in a box (pipeline proof)
A flat box, a ball, tilt controls, a main menu with placeholder Leaderboard/Settings/Credits buttons.
CI: on every push, run tests and build Android + iOS. On `master`, upload to the Play internal/closed track
and TestFlight. Start the 12-tester closed test here so the 14-day clock runs while we build the game.

## M2 — Core gameplay + tutorial
Maze building blocks, the hole/goal, timer (`hh:mm:ss:ms`), the material system (physics presets),
10 tutorial levels, saving progress.

## M3 — Daily maze + leaderboard
Seeded procedural maze generator (a solvable maze is guaranteed and tested), first run vs time-trial flow,
EOS login and daily leaderboard.

## M4 — Monetization & compliance
AdMob ads between retries with fair-play rules, consent (UMP/GDPR, ATT), store listings, screenshots,
age rating, data safety forms.

## M5 — Launch
Production release on both stores. Basic analytics/crash reporting. Post-launch tuning.
