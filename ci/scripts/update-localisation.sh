#! /bin/bash
# Merge the result files from main.rb into the mobile-localisation repo (assumes strings in
# spreadsheet are for en)
#
# Required folders:
# results contains the result folder from a successful run of main.rb
# localisation contains checked out mobile-localisation repo. New strings will be committed here.

cp results/en-strings.xml localisation/en/Android/strings.xml
cp results/ios.strings localisation/en/iOS/Localizable.strings

cd localisation
git config user.email "ci@yoti.com"
git config user.name "yoti-ci"

git add en/Android/strings.xml
git add en/iOS/Localizable.strings

git commit -m "Update strings from spreadsheet merge"
