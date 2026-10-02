extends Node
## Facade over external services (leaderboard, ads, analytics). Autoloaded as `Services`.
## Game code only talks to this node, so tests can swap in fakes and the real SDKs stay isolated.
## Placeholder: real implementations arrive in M3 (EOS) and M4 (AdMob).
