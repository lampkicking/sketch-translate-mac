#! /bin/bash
# Merge the result files from main.rb into the appropriate repos for processing (assumes strings in
# spreadsheet are for en)
#
# Required folders:
# results contains the result folder from a successful run of main.rb
# android-repo contains checked out mobile-localisation repo. New Android strings will be committed here.
# ios-repo contains checked out strings-merger repo. New iOS strings will be committed here.

ANDROID_IN_PATH=en-strings.xml
IOS_IN_PATH=ios.strings
ANDROID_OUT_PATH=en/Android/strings.xml
IOS_OUT_PATH=new.strings

cp results/$ANDROID_IN_PATH android-repo/$ANDROID_OUT_PATH
cp results/$IOS_IN_PATH ios-repo/$IOS_OUT_PATH

## Android
cd android-repo
git config user.email "ci@yoti.com"
git config user.name "yoti-ci"

git add $ANDROID_OUT_PATH

git diff-index --quiet HEAD $ANDROID_OUT_PATH || git commit -m "Update strings from spreadsheet merge"

## iOS
cd ../ios-repo
git config user.email "ci@yoti.com"
git config user.name "yoti-ci"

git add $IOS_OUT_PATH

git diff-index --quiet HEAD $IOS_OUT_PATH || git commit -m "Update strings from spreadsheet merge"