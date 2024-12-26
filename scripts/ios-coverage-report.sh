#!/usr/bin/env bash

set -o pipefail

# shellcheck disable=SC2125
XCRESULT=../build/derived-data-ios/Logs/Test/*.xcresult
REPORT_DIR=build/reports/ios

echo "Generating iOS Coverage Report"

mkdir -p $REPORT_DIR

# shellcheck disable=SC2086
(cd ios && xcrun xccov view --report --json $XCRESULT > ../$REPORT_DIR/coverage.json)
