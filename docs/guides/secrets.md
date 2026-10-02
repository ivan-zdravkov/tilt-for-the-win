# Secrets policy

The repository is **public**, so it never contains secrets. They live in exactly two places:

1. **Password manager**: the master copy of every secret and file (keystores, keys, passwords).
2. **GitHub Actions secrets** (repo → Settings → Secrets and variables → Actions): what CI uses.
   Set them with `gh secret set NAME -R ivan-zdravkov/tilt-for-the-win` (for files: `base64 -w0 file | gh secret set NAME`).

Local copies that are needed for development live **outside the repo** in `~/.config/tilt-for-the-win/` (chmod 700).

Guard rails:
- `.gitignore` blocks common secret file types (`*.keystore`, `*.jks`, `*.p12`, `*.p8`, `*.mobileprovision`,
  `.env`, `*service-account*.json`, `secrets/`) and Godot's `export_credentials.cfg`.
- GitHub **secret scanning + push protection** are enabled on the repo, so pushes containing known token formats are blocked.
- Godot's `export_presets.cfg` is committed **without** keystore paths or passwords; CI injects them through the
  `GODOT_ANDROID_KEYSTORE_RELEASE_*` environment variables.

## Secret inventory (filled in as we go)
| Secret | Used for | Created in issue |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` | Signing the Android upload bundle | M1 |
| `PLAY_SERVICE_ACCOUNT_JSON` | Uploading to Google Play | M1 |
| `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8_BASE64` | App Store Connect API (TestFlight upload, signing) | M1 |
| `IOS_DIST_CERT_P12_BASE64`, `IOS_DIST_CERT_PASSWORD`, `IOS_PROFILE_BASE64` | iOS code signing | M1 |
| `EOS_CLIENT_ID`, `EOS_CLIENT_SECRET` (+ product/sandbox/deployment IDs) | Leaderboard (injected at build time) | M3 |

> Losing the **Android upload keystore** is recoverable (Play App Signing lets you reset the upload key), but painful.
> Keep it in the password manager from day one.
