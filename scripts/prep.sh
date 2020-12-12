#!/usr/bin/env zsh
set -e

calling_directory="$PWD"
day_name="$1"
root=$(git rev-parse --show-toplevel)

cd "$root"

if [[ -d "$day_name" ]]; then
  echo "Directory already exists: $day_name" >&2
  cd "$calling_directory"
  exit 1
fi

if [[ -n "$(git status --porcelain=v1)" ]]; then
  echo "Unstaged changes; exiting"
  cd "$calling_directory"
  exit 1
fi

mkdir "$day_name"
cp template/part_{1,2}.rb template/input "$day_name"
git add "$day_name"
git commit -m "Setup day $day_name"

cd "$calling_directory"
