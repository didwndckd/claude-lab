#!/bin/sh
# Local statusLine: model + context usage bar only

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // ""')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Build output
right=""
if [ -n "$model" ]; then
  right=$(printf "\033[0;36m%s\033[0m" "$model")
fi
if [ -n "$remaining" ]; then
  used=$(printf "%.0f" "$(echo "100 - $remaining" | bc)")
  filled=$((used / 10))
  empty=$((10 - filled))
  bar=""
  i=0; while [ $i -lt $filled ]; do bar="${bar}█"; i=$((i + 1)); done
  i=0; while [ $i -lt $empty ]; do bar="${bar}░"; i=$((i + 1)); done
  ctx_str=$(printf "\033[1;37mctx: [%s] %s%%\033[0m" "$bar" "$used")
  if [ -n "$right" ]; then
    right="$right  $ctx_str"
  else
    right="$ctx_str"
  fi
fi

printf "%s\n" "$right"
