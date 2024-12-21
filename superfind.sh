#!/bin/bash
# A command line utility to recursively search for files and directories with names containing a given string

# Parse command line options
OPTIONS=$(getopt -o d:l: --long help -- "$@")
if [ $? -ne 0 ]; then
  echo "script usage: $(basename $0) [--help] [-d value] [-l value]" >&2
  exit 1
fi

eval set -- "$OPTIONS"

while true; do
  case "$1" in
    --help)
      echo "Superfind"
      echo "A command line utility to recursively search for files and directories with names containing a given string"
      echo "Usage: $ superfind <string to search for> [-d <depth limit>] [-l <location>]"
      echo "--help: display this help message"
      echo "-d: recursive depth limit to search (e.g. -d 1 will only search the current directory and the first level of subdirectories)"
      echo "-l: directory to search in (default is the current directory)"
      exit 0
      ;;
    -d)
      depth="$2"
      shift 2
      ;;
    -l)
      location="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "script usage: $(basename $0) [--help] [-d value] [-l value]" >&2
      exit 1
      ;;
  esac
done

searchstring=$1
if [ -z "$location" ]; then
  location=$(pwd)
fi

echo "Searching recursively for files and directories with names containing '$searchstring' in $location..."
if [ -z "$depth" ]; then
  find "$location" \( -type f -o -type d \) -name "*$searchstring*" -exec sh -c 'echo "found $(basename {}) in $(dirname {})"' \;
else
  find "$location" -maxdepth "$depth" \( -type f -o -type d \) -name "*$searchstring*" -exec sh -c 'echo "found $(basename {}) in $(dirname {})"' \;
fi