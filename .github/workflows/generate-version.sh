#! /bin/bash

VERSION=${1,,}

if [ -n $VERSION ]
then
  case $VERSION in
    
    major)
      VERSION_INDEX=0
      ;;

    minor)
      VERSION_INDEX=1
      ;;

    patch | "")
      VERSION_INDEX=2
      ;;

    *)
      echo "Incorrect argument. Please use 'major', 'minor', or 'patch' to indicate the position to increment (default: patch)."
      exit
      ;;
  esac
fi

V_NOW=$(gh release list --repo MiloWical/Release-Tests --limit 1 | awk '{print substr($1, 2)}')

if [ -z $V_NOW ]
then
  V_NOW="0.0.0"
fi

IFS='.'
read -ra V_NEXT <<< "$V_NOW"

((V_NEXT[VERSION_INDEX]++))

echo ${V_NEXT[0]}.${V_NEXT[1]}.${V_NEXT[2]}