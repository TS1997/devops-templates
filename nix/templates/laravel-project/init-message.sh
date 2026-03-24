#!/bin/bash

# Standardfärger
TEXT_COLOR="\033[1;33m"   # Gul
RESET="\033[0m"
URL=$MAIN_HTTPS_URL

# Färgfunktion
get_color_code() {
  case "$1" in
    red) echo "\033[1;31m" ;;
    green) echo "\033[1;32m" ;;
    yellow) echo "\033[1;33m" ;;
    blue) echo "\033[1;34m" ;;
    cyan) echo "\033[1;36m" ;;
    *) echo "\033[0m" ;;
  esac
}

# Flagghantering
while getopts "u:t:" opt; do
  case $opt in
    u) URL="$OPTARG" ;;
    t) TEXT_COLOR=$(get_color_code "$OPTARG") ;;
  esac
done

# ✏️ Ditt meddelande här (kan vara hur långt som helst)
read -r -d '' MESSAGE << EOM

Laravel-miljön är nu uppsatt!

För att vara på säkra sidan, är det bäst om du startar om din devenv-miljö först.
Kör devenv up för att starta din miljö.

Sedan kan du navigera till din webbplats på:
$URL

Ha en fantastisk dag!

EOM

# Skriv ut meddelandet
echo -e "${TEXT_COLOR}${MESSAGE}${RESET}"
