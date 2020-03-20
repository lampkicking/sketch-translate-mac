#! /bin/bash
# Merge the result files from main.rb into the appropriate repos for processing (assumes strings in
# spreadsheet are for en)
#
# Required folders:
# results contains the result folder from a successful run of main.rb
# android-repo contains checked out mobile-localisation repo. New Android strings will be committed here.
# ios-repo contains checked out strings-merger repo. New iOS strings will be committed here.

cp results/en-strings.xml android-repo/en/Android/strings.xml
cp results/ios.strings ios-repo/new.strings

## Android
cd android-repo
git config user.email "ci@yoti.com"
git config user.name "yoti-ci"

git add en/Android/strings.xml

git diff-index --quiet HEAD en/Android/strings.xml || git commit -m "Update strings from spreadsheet merge"

## iOS
cd ../ios-repo
git config user.email "ci@yoti.com"
git config user.name "yoti-ci"

git add new.strings

git diff-index --quiet HEAD new.strings || git commit -m "Update strings from spreadsheet merge"