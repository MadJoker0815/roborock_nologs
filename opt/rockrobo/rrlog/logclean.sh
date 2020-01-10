#!/bin/bash

echo "`date` ---"

if [ ! -d "$1" ]; then
  echo '"'"$1"'": not a directory'
  exit
fi

items="$1"/*
for item in $items
do
  if [ -d "$item" ]; then
    echo "Removing directory $item..."
    rm -fr "$item"
  elif [ -f "$item" ]; then
    if [[ $item == *".log" ]]; then
      echo "Shrinking log $item..."
      echo "$(tail -20 "$item")" > "$item"
    else
      echo "Removing file $item..."
      rm "$item"
    fi
  fi
done
