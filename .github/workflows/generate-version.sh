#! /bin/bash

# --- Flag defaults ---

FORCE_FLAG=0
PRERELEASE_FLAG=0

# --- Process command-line arguments ---

CURRENT_RELEASE_TAG=$1 # First param is CURRENT_RELEASE_TAG
shift

while [[ $# -gt 0 ]]; do
  case $1 in
    
    -i|--increment-position)
      INCREMENT_POSITION=${2,,}
      shift
      shift
      ;;

    -s|--suffix)
      VERSION_SUFFIX=$2
      shift
      shift
      ;;

    -M|--major)
      MAJOR_MASK=$2
      shift
      shift
      ;;
    
    -m|--minor)
      MINOR_MASK=$2
      shift
      shift
      ;;

    -p|--patch)
      PATCH_MASK=$2
      shift
      shift
      ;;
    
    -f|--force)
      FORCE_FLAG=1
      shift
      ;;

    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# --- Validate configuration ---

if [ -z $INCREMENT_POSITION ]
then
  VERSION_INDEX=2 # Default is patch
else
  case $INCREMENT_POSITION in  
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

# --- Process release tag ---

V_NOW=$(sed -rn 's/v?([0-9]\.[0-9]\.[0-9]).*/\1/p' <<< "$CURRENT_RELEASE_TAG")
RELEASE_SUFFIX=$(sed -rn 's/.*-(\S+).*/\1/p' <<< "$CURRENT_RELEASE_TAG")

# --- Process version configurations ---

if [ -z $V_NOW ]
then
  V_NOW="0.0.0"
  V_DEFAULT=1
fi

IFS=.
read -ra V_NEXT_ARR <<< "$V_NOW"

if [ ! -z $MAJOR_MASK ] && [ "$MAJOR_MASK" -ne "${V_NEXT_ARR[0]}" ]
then
  RESET_PATCH=1
else
  RESET_PATCH=0
fi

if [ ! -z $MINOR_MASK ] && [ "$MINOR_MASK" -ne "${V_NEXT_ARR[1]}" ]
then
  RESET_PATCH=1
else
  RESET_PATCH=0
fi

if [ ! -z $MAJOR_MASK ]
then
  V_NEXT_ARR[0]=$MAJOR_MASK
fi

if [ ! -z $MINOR_MASK ]
then
  V_NEXT_ARR[1]=$MINOR_MASK
fi

if [ ! -z $PATCH_MASK ]
then
  V_NEXT_ARR[2]=$PATCH_MASK
else 
  if [ $RESET_PATCH -eq 1 ]
  then
    V_NEXT_ARR[2]=0
  else
    if [ "$RELEASE_SUFFIX" == "$VERSION_SUFFIX" ] || [ $FORCE_FLAG -eq 1 ] || [ -n $V_DEFAULT ]
    then
      ((V_NEXT_ARR[VERSION_INDEX]++))
    fi  
  fi
fi

unset IFS
V_NEXT="${V_NEXT_ARR[0]}.${V_NEXT_ARR[1]}.${V_NEXT_ARR[2]}"

if [ ! -z $VERSION_SUFFIX ]
then
  V_NEXT="$V_NEXT-$VERSION_SUFFIX"
fi

echo $V_NEXT