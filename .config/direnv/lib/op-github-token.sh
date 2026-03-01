# Usage: use_op_github_token
use_op_github_token() {
  local vault="fitz-biz"
  local item="GitHub NuGet PAT"

  if has op; then
    export GITHUB_TOKEN=$(op read "op://$vault/$item/credential" 2>/dev/null)
    if [ -z "$GITHUB_TOKEN" ]; then
      log_error "Failed to read GitHub token from 1Password"
      return 1
    fi
  else
    log_error "op CLI not found — cannot load GITHUB_TOKEN"
    return 1
  fi
}
