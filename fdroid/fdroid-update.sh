#!/bin/bash

export PATH=$PATH:/sdk/build-tools/24.0.1/

fdroid_dir="/apk/repo"

apk_url="http://download.cgeo.org"

aapt="/sdk/build-tools/24.0.1/aapt"

verbose=true
version_code=""
latest_apk=""

function usage {
   echo "E: Incorrect number of arguments"
   echo "Usage: Download current version of c:geo app and update index for fdroid repo"
   echo
   echo "$0 [nightly | mainline]"
   exit 1
}

if [[ $1 != "nightly" && $1 != "mainline" ]]; then
   usage
fi

$verbose && echo "I: Updating $1 repo"

[ -d $fdroid_dir/$1/repo ] || { mkdir -p $fdroid_dir/$1/repo; $verbose && echo "I: Creating repo dir"; }
[ -e $fdroid_dir/$1/cgeo-logo.png ] || cp /apk/cgeo-logo.png $fdroid_dir/$1/

cp -a /apk/metadata $fdroid_dir/$1/

if [ ! -e $fdroid_dir/$1/config.py ]; then
    echo "E: config.py file is missing. You need to create one."
    exit 1
fi

# Download apk
function download_apk {
   apk=$1
   url=$2
   release=$3

   cd $fdroid_dir/$release/repo
   $verbose && echo "I: downloading $apk from $url"
   wget -q -O tmp-${apk}.apk $url || { echo "Fail to download apk"; exit 2; }
   apk_version=`$aapt dump badging tmp-${apk}.apk | head -n1 | sed "s/.*versionName='\([^ ]*\)' .*/\1/"`
   $verbose && echo "I: apk version is $apk_version"

   [[ $apk_version =~ ^[legacyNOJITBa-f0-9.-]+$ ]] || { echo "Fail to extract apk version"; exit 3; }

   version_code=`$aapt dump badging tmp-${apk}.apk | head -n1 | sed "s/.*versionCode='\([^ ]*\)' .*/\1/"`
   latest_apk=${apk}-${apk_version}.apk
   mv tmp-${apk}.apk ${latest_apk}
}

# Update indexes
function update_indexes {
   release=$1

   $verbose && echo "I: Updating F-Droid index"
   cd $fdroid_dir/$release;
   fdroid update -c && exit $?

   # Found duplicates versionCode :/
   drop_duplicate_versioncode $release
}

# Drop duplicate VersionCode
function drop_duplicate_versioncode {
   release=$1
   has_duplicates=false

   $verbose && echo "I: Finding apk with same versionCode: $version_code"
   cd $fdroid_dir/$release/repo
   for apk in cgeo*.apk; do
      vcode=`$aapt dump badging ${apk} | head -n1 | sed "s/.*versionCode='\([^ ]*\)' .*/\1/"`
      [ "x${apk}" == "x${latest_apk}" ] && continue

      $verbose && echo "I: Found ${apk} with versionCode: $vcode"
      if [ "x$vcode" == "x$version_code" ]; then
         has_duplicates=true
         $verbose && echo "I: Deleting ${apk} with same versionCode: $version_code"
         rm ${apk}
      fi
   done
   $has_duplicates && update_indexes $release || { $verbose && echo "E: No duplicates version found. Abording..."; exit 4 ; }
}


if [[ $1 == "mainline" ]]; then
   $verbose && echo "I: Finding download links"
   apk=$(curl -s https://api.github.com/repos/cgeo/cgeo/releases/latest | grep 'browser_' | cut -d\" -f4)
   download_apk "cgeo-release" "$apk" "mainline"
   download_apk "cgeo-contacts" "https://github.com/cgeo/cgeo/releases/download/market_20150112/cgeo-contacts_v1.5.apk" "mainline"
   update_indexes "mainline"
fi

if [[ $1 == "nightly" ]]; then
   # - cgeo-nightly-nojit lead to duplicate versions
   # - Contact is not yet available
   #for apk in cgeo-nightly cgeo-nightly-nojit cgeo-contacts-nightly; do
   for apk in cgeo-nightly; do
      download_apk "${apk}" "${apk_url}/${apk}.apk" "nightly"
   done
   update_indexes "nightly"
fi

