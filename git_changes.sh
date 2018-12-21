#!/bin/bash
#
# Example usage: ./git_changes.sh $HOME/CIL_Public_Data_JSON /pub/data2/dams/dams-staging/rdcp-staging/rdcp-0126-cil

dir=$(pwd)

if [ -z "$1" ]; then echo "No project directory provided"; exit 1; fi
if [ -z "$2" ]; then echo "No rdcp-staging base directory provided"; exit 1; fi

files_count=$(find $2 -path "*/metadata_source/*" -type f -name "*.json" | wc -l)
echo "$files_count files"

# base directory in rdcp staging for this CIL harvesting
harvest_dir="$2/cil_harvest_$(date +%F)"
mkdir -p "$harvest_dir"
mkdir -p "$harvest_dir/metadata_source"
mkdir -p "$harvest_dir/metadata_processed"
mkdir -p "$harvest_dir/content_files"

cd "$1" || exit 1

current_head=$(git log | head -1 | awk '{print $2}')
current_branch=$(git rev-parse --abbrev-ref HEAD)

git pull origin "$current_branch"

new_head=$(git log | head -1 | awk '{print $2}')
if [ "$current_head" == "$new_head" -a "$files_count" -gt 0 ]; then
  echo "No new commits have been added"
  exit 0
fi

source_files="$harvest_dir/metadata_processed/json_files.txt"

# Process json files added
if [ $files_count -gt 0 ]; then
  # unset rename limits for large batch of files
  git config diff.renames 0

  echo "git diff --name-only --diff-filter=A $current_head..$new_head"

  diff_files=$(git diff --name-only --diff-filter=A "$current_head".."$new_head")

  # insert diff files into array
  eval "files=($diff_files)"

  # loop through all file in the array
  for f in "${files[@]}"
  do
    if [[ $f == *"/DATA/"* ]]; then
      echo "$f"
      # insert new json file with path
      echo "$1/$f\n" >> $source_files
    fi
  done
else
  # Initial set up to process all files
  new_files=$(find $1 -path "*/Version*/DATA/*" -type f -name "*.json")
  echo "$new_files"

  # insert new json file with path
  echo "$new_files" >> $source_files
fi

# download JSON source files and content files
ruby "$dir/cil_download.rb" -e "$harvest_dir" "$source_files" > "$dir/log.txt"
