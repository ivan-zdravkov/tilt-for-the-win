# Vision — Tilt for the Win

## Pitch
The classic wooden ball-in-a-maze toy on your phone: tilt the phone, roll the ball from the middle of the
board to the single hole. Simple geometry, but every surface is a **material** (wood, grass, stone, ice, …)
with its own physics, so the same maze plays differently depending on what it's made of.
One new maze every day, the same for everyone, with a global daily leaderboard.

## Core loop
1. Open the game → today's maze.
2. **First run = discovery.** Find the path. Ad-free.
3. **Every further run = time trial** against your best. Time shown as `hh:mm:ss:ms`.
4. Best time is submitted to the **daily leaderboard**. Ads may play between retries (not before the first run).

## Content
- **10 tutorial levels** (ad-free) that teach: tilt controls → momentum → friction → bounciness →
  each material → combinations. Hand-made.
- **Daily levels**: procedurally generated from a seed derived from the UTC date, so every player gets the same
  maze with no server needed. The generator must guarantee a solvable maze.

## Materials (first pass, tune later)
| Material | Ground feel | Wall feel |
|---|---|---|
| Wood | baseline | baseline bounce |
| Stone | fast, low friction | hard, bouncy |
| Grass | slow, high friction | soft, dead bounce |
| Ice | very slippery | bouncy |
| Sand/Mud | heavy drag | absorbs |

## Platforms & services
- iOS + Android, published under Ivan Zdravkov's personal developer accounts.
- Leaderboards: Epic Online Services (free, cross-platform).
- Monetization: video ads between daily retries. Tutorial and the first daily run are ad-free.
  Fair-play rules to define: frequency cap, never mid-run, optional "remove ads" IAP later.

## MVP definition
A game that is live on both stores with: gyro controls, the 10 tutorial levels, the daily maze, the daily
leaderboard, ads between retries, a settings/credits screen, a privacy policy, and GDPR/ATT consent.

## First milestone (not the game yet)
**"Ball in a box"**: one flat box, one ball, tilt controls, a minimal menu, placeholder buttons for
leaderboard/credits/settings — built and uploaded to the store **test tracks** automatically from CI.
Its purpose is to prove the whole pipeline end to end before investing in gameplay.
