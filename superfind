#!/bin/bash
# A command line utility to recursively search for files and directories with names containing a given string

# Parse command line options
OPTIONS=$(getopt -o d:l: --long help -- "$@")
if [ $? -ne 0 ]; then
  echo "script usage: $(basename $0) [--help] [-d value] [-l value]" >&2
  exit 1
fi

eval set -- "$OPTIONS"
# flag control
while true; do
  case "$1" in
    # help flag
    --help)
      echo "Superfind"
      echo "A command line utility to recursively search for files and directories with names containing a given string"
      echo "Usage: $ superfind <string to search for> [-d <depth limit>] [-l <location>]"
      echo "--help: display this help message"
      echo "-d: recursive depth limit to search (e.g. -d 1 will only search the current directory and the first level of subdirectories)"
      echo "-l: directory to search in (default is the current directory)"
      exit 0
      ;;
    # depth flag
    -d)
      depth="$2"
      shift 2
      ;;
    -l)
    # location flag
      location="$2"
      shift 2
      ;;
    # parse for long-form flags
    --)
      shift
      break
      ;;
    #error handling
    *)
      echo "script usage: $(basename $0) [--help] [-d value] [-l value]" >&2
      exit 1
      ;;
  esac
done
# Assigning the search string
searchstring=$1
if [ -z "$searchstring" ]; then
  echo "Error: no search string provided"
  echo "Usage: $ superfind <string to search for> [-d <depth limit>] [-l <location>]"
  exit 1
fi
# Setting location to current directory if not provided
if [ -z "$location" ]; then
  location=$(pwd)
fi
# Providing a warning if the search is being run in the root directory
if [ "$location" = / ]; then
  echo "Warning: running command in a root-level directory. Most files will not be searched."
  sleep 1
fi
# The searching part
echo "Searching recursively for files and directories with names containing '$searchstring' in $location..."
if [ -z "$depth" ]; then
  find "$location" \( -type f -o -type d \) -name "*$searchstring*" -exec sh -c 'echo "found $(basename {}) in $(dirname {})"' \;
else
  find "$location" -maxdepth "$depth" \( -type f -o -type d \) -name "*$searchstring*" -exec sh -c 'echo "found $(basename {}) in $(dirname {})"' \;
fi