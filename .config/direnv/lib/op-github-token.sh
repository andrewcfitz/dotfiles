# Usage: use_op_github_token
use_op_github_token() {
  local vault="fitz-biz"
  local item="GitHub NuGet PAT"

  if has op; then
    export NUGET_TOKEN=$(op read "op://$vault/$item/credential" 2>/dev/null)
    if [ -z "$NUGET_TOKEN" ]; then
      log_error "Failed to read NuGet token from 1Password"
      return 1
    fi
  else
    log_error "op CLI not found — cannot load NUGET_TOKEN"
    return 1
  fi
}
