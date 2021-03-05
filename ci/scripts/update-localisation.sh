#! /bin/bash
# Merge the result files from main.rb into the appropriate repos for processing (assumes strings in
# spreadsheet are for en)
#
# Required folders:
# results contains the result folder from a successful run of main.rb
# android-repo contains checked out mobile-localisation repo. New Android strings will be committed here.
# ios-repo contains checked out strings-merger repo. New iOS strings will be committed here.

#Android paths
YOTI_ANDROID_IN_PATH=strings.xml
POSTOFFICE_ANDROID_IN_PATH=strings_postofficeid.xml

YOTI_ANDROID_OUT_PATH=en/Android/strings.xml
POSTOFFICE_ANDROID_OUT_PATH=en/Android/strings_postofficeid.xml

#iOS file names
YOTI_IOS_FILE_NAME=ios.strings
POSTOFFICE_IOS_FILE_NAME=ios_postofficeid.strings

cp results/$YOTI_ANDROID_IN_PATH android-repo/$YOTI_ANDROID_OUT_PATH
cp results/$POSTOFFICE_ANDROID_IN_PATH android-repo/$POSTOFFICE_ANDROID_OUT_PATH
cp results/$YOTI_IOS_FILE_NAME ios-repo/$YOTI_IOS_FILE_NAME
cp results/$POSTOFFICE_IOS_FILE_NAME ios-repo/$POSTOFFICE_IOS_FILE_NAME

## Android
cd android-repo
git config user.email "ci@yoti.com"
git config user.name "yoti-ci"

git add $YOTI_ANDROID_OUT_PATH
git diff-index --quiet HEAD $YOTI_ANDROID_OUT_PATH || git commit -m "Update Yoti strings from spreadsheet merge"

git add $POSTOFFICE_ANDROID_OUT_PATH
git diff-index --quiet HEAD $POSTOFFICE_ANDROID_OUT_PATH || git commit -m "Update PostOffice strings from spreadsheet merge"

## iOS
cd ../ios-repo
git config user.email "ci@yoti.com"
git config user.name "yoti-ci"

git add $YOTI_IOS_FILE_NAME
git diff-index --quiet HEAD $YOTI_IOS_FILE_NAME || git commit -m "Update Yoti strings from spreadsheet merge"

git add $POSTOFFICE_IOS_FILE_NAME
git diff-index --quiet HEAD $POSTOFFICE_IOS_FILE_NAME || git commit -m "Update PostOffice strings from spreadsheet merge"
