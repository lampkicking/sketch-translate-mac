#! /bin/bash
# Merge the result files from main.rb into the appropriate repos for processing (assumes strings in
# spreadsheet are for en)
#
# Required folders:
# results contains the result folder from a successful run of main.rb
# android-repo contains checked out mobile-localisation repo. New Android strings will be committed here.
# ios-repo contains checked out strings-merger repo. New iOS strings will be committed here.

#Android paths
YOTI_ANDROID_FILE_NAME=strings.xml
YOTI_IOS_FILE_NAME=ios.strings
ANDROID_BASE_PATH=en/Android/

#Additional white label targets
TARGETS=("postofficeid" "smartid")

cp results/$YOTI_ANDROID_FILE_NAME android-repo/${ANDROID_BASE_PATH}${YOTI_ANDROID_FILE_NAME}
cp results/$YOTI_IOS_FILE_NAME ios-repo/$YOTI_IOS_FILE_NAME

for TARGET in "${TARGETS[@]}"; do
    cp results/strings_${TARGET}.xml android-repo/${ANDROID_BASE_PATH}strings_${TARGET}.xml
    cp results/ios_${TARGET}.strings ios-repo/ios_${TARGET}.strings
done

## Android
cd android-repo
git config user.email "ci@yoti.com"
git config user.name "yoti-ci"

git add ${ANDROID_BASE_PATH}${YOTI_ANDROID_FILE_NAME}
git diff-index --quiet HEAD ${ANDROID_BASE_PATH}${YOTI_ANDROID_FILE_NAME} || git commit -m "Update Yoti strings from spreadsheet merge"

for TARGET in "${TARGETS[@]}"; do
    git add en/Android/strings_${target}.xml
    git diff-index --quiet HEAD ${ANDROID_BASE_PATH}strings_${TARGET}.xml || git commit -m "Update "${TARGET}" strings from spreadsheet merge"
done

## iOS
cd ../ios-repo
git config user.email "ci@yoti.com"
git config user.name "yoti-ci"

git add $YOTI_IOS_FILE_NAME
git diff-index --quiet HEAD $YOTI_IOS_FILE_NAME || git commit -m "Update Yoti strings from spreadsheet merge"

for TARGET in "${TARGETS[@]}"; do
    git add ios_${TARGET}.strings
    git diff-index --quiet HEAD ios_${TARGET}.strings || git commit -m "Update "${TARGET}" strings from spreadsheet merge"
done
