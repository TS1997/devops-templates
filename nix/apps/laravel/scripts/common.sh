if [[ -t 2 ]]; then
  red=$'\033[31m'
  bold=$'\033[1m'
  reset=$'\033[0m'
else
  red=""
  bold=""
  reset=""
fi

fail() {
  printf '%s\n' "${red}${bold}Error:${reset} $*" >&2
  exit 1
}

slugify() {
  local separator=$1
  tr '[:upper:]' '[:lower:]' \
    | sed -E "s/[^a-z0-9]+/${separator}/g; s/^${separator}//; s/${separator}$//"
}

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is not on PATH."
}

require_template_dir() {
  [[ -n "${TEMPLATE_DIR:-}" ]] || fail "TEMPLATE_DIR is not set. Run this script through the Nix app."
  [[ -d "$TEMPLATE_DIR" ]] || fail "Template directory does not exist: $TEMPLATE_DIR"
}

copy_template() {
  rsync \
    -aL \
    --no-owner \
    --no-group \
    --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
    "$TEMPLATE_DIR/" \
    "$target_dir/"

  if [[ -f "$target_dir/.gitattributes.template" ]]; then
    mv "$target_dir/.gitattributes.template" "$target_dir/.gitattributes"
  fi
}
