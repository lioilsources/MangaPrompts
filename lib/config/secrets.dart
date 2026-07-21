// Committed with EMPTY values so the app compiles everywhere (CI, fresh clone,
// public release builds) WITHOUT leaking anyone's Cloudflare Access token.
//
// To bake your own comfyui.ol1n.com creds locally WITHOUT committing them:
//   1. fill in the values below
//   2. git update-index --skip-worktree lib/config/secrets.dart
// Your local edits then stay untracked. (Undo with --no-skip-worktree.)
//
// These are only DEFAULTS — a value saved in Settings (SharedPreferences) wins.
class Secrets {
  static const cfAccessClientId = '';
  static const cfAccessClientSecret = '';
}
