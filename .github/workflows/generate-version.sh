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
RELEASE_SUFFIX=$(sed -rn 's/[^-]+-(\S+).*/\1/p' <<< "$CURRENT_RELEASE_TAG")

# --- Process version configurations ---

if [ -z $V_NOW ]
then
  V_NOW="0.0.0"
  V_DEFAULT=1
fi

IFS=.
read -ra V_NOW_ARR <<< "$V_NOW"

V_NEXT_ARR=(${V_NOW_ARR[*]})

# --- Process masking ---

MASKED_INDEX=-1

if [ ! -z $MAJOR_MASK ]
then
  V_NEXT_ARR[0]=$MAJOR_MASK
  MASKED_INDEX=0
fi

if [ ! -z $MINOR_MASK ]
then
  V_NEXT_ARR[1]=$MINOR_MASK
  MASKED_INDEX=1
fi

if [ ! -z $PATCH_MASK ]
then
  V_NEXT_ARR[2]=$PATCH_MASK
  MASKED_INDEX=2
fi

echo Before increment logic...
echo "V_NOW_ARR: ${V_NOW_ARR[*]}"
echo "V_NEXT_ARR: ${V_NEXT_ARR[*]}"
echo "VERSION_INDEX: $VERSION_INDEX"
echo "MASKED_INDEX: $MASKED_INDEX"

# --- Perform the increment, if applicable ---

if [ $VERSION_INDEX -ne $MASKED_INDEX ]
then
  echo "VERSION_INDEX -ne MASKED_INDEX => TRUE!"
  echo "CURRENT_RELEASE_TAG: $CURRENT_RELEASE_TAG"
  echo "RELEASE_SUFFIX: $RELEASE_SUFFIX"
  echo "VERSION_SUFFIX: $VERSION_SUFFIX"
  echo "FORCE_FLAG: $FORCE_FLAG"
  echo "V_DEFAULT: $V_DEFAULT"
  if ([ -z $RELEASE_SUFFIX ] || [ "$RELEASE_SUFFIX" == "$VERSION_SUFFIX" ]) || [ $FORCE_FLAG -eq 1 ] || [ ! -z $V_DEFAULT ]
  then
    ((V_NEXT_ARR[VERSION_INDEX]++))
  fi  
fi

echo After increment logic...
echo "V_NOW_ARR: ${V_NOW_ARR[*]}"
echo "V_NEXT_ARR: ${V_NEXT_ARR[*]}"

if [ "${V_NEXT_ARR[0]}" -gt "${V_NOW_ARR[0]}" ] || [ "${V_NEXT_ARR[1]}" -gt "${V_NOW_ARR[1]}" ]
then
  V_NEXT_ARR[2]=0
fi

if [ "${V_NEXT_ARR[0]}" -gt "${V_NOW_ARR[0]}" ]
then
  V_NEXT_ARR[1]=0
fi

echo After patch reset logic...
echo "V_NOW_ARR: ${V_NOW_ARR[*]}"
echo "V_NEXT_ARR: ${V_NEXT_ARR[*]}"

# --- Output new version ---

unset IFS
V_NEXT="${V_NEXT_ARR[0]}.${V_NEXT_ARR[1]}.${V_NEXT_ARR[2]}"

if [ ! -z $VERSION_SUFFIX ]
then
  V_NEXT="$V_NEXT-$VERSION_SUFFIX"
fi

echo $V_NEXT