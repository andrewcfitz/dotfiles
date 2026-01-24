# Usage: use_op_kubeconfig <document-name>
use_op_kubeconfig() {
  local document="$1"
  local vault="a44jnvsz2fw4mgpcz6sbomnsi4"
  local cache_name=$(echo "$document" | tr ' ' '-')
  
  local cache_file="$HOME/.cache/kubeconfig-$cache_name"
  
  mkdir -p "$(dirname "$cache_file")"
  
  if [ ! -f "$cache_file" ] || [ ! -s "$cache_file" ]; then
    echo "Fetching kubeconfig from 1Password..."
    op document get "$document" \
      --vault "$vault" \
      --out-file "$cache_file" \
      --force || {
      echo "Failed to fetch kubeconfig from 1Password. Make sure you're signed in with: op signin"
      return 1
    }
  fi
  
  watch_file "$cache_file"
  export KUBECONFIG="$cache_file"
}
