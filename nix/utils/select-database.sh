#!/usr/bin/env bash

# Usage: Source this script after defining names, users, and optional passwords arrays
# Expects: names[@] users[@] passwords[@] (passwords are optional)
# Returns: index db user password (via global variables)

if [ ${#names[@]} -gt 1 ]; then
  PS3="Select a database to connect to: "
  select db in "${names[@]}"; do
    [ -n "$db" ] || continue
    index=$((REPLY-1))
    break
  done
else
  index=0
  db="${names[0]}"
fi

user="${users[$index]}"
password="${passwords[$index]:-}"