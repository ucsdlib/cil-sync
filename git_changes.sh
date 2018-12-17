#!/bin/bash
#
# Example usage: ./git_changes.sh $HOME/CIL_Public_Data_JSON

if [ -z "$1" ]; then echo "No project directory provided"; exit 1; fi
cd "$1" || exit 1

current_head=$(git log | head -1 | awk '{print $2}')
current_branch=$(git rev-parse --abbrev-ref HEAD)

git pull origin "$current_branch"

new_head=$(git log | head -1 | awk '{print $2}')
if [[ "$current_head" == "$new_head" ]]; then
  echo "No new commits have been added"
  exit 0
fi

new_files=$(git diff --name-only --diff-filter=A "$current_head".."$new_head")
echo "$new_files"
