mkdir ./machApp/fastlane/lint_output/ &
cd ./machApp &&
fastlane update_fastlane &&
fastlane linter_validation