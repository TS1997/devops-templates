#!/usr/bin/env bash

# Usage: Source this script after defining names, users, and optional passwords arrays
# Expects: names[@] users[@] passwords[@] (passwords are optional)
# Returns: index db user password (via global variables)
# A database name as the first argument skips the menu and is shifted off,
# e.g. `mysql-local mydb < dump.sql`.

index=""
for i in "${!names[@]}"; do
  if [ "${1:-}" = "${names[$i]}" ]; then
    index=$i
    db="${names[$i]}"
    shift
    break
  fi
done

if [ -n "$index" ]; then
  :
elif [ ${#names[@]} -gt 1 ]; then
  # select reads the choice from stdin, which is the input data when piping
  if [ ! -t 0 ]; then
    echo "Multiple databases, pass one as the first argument: ${names[*]}" >&2
    exit 1
  fi
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