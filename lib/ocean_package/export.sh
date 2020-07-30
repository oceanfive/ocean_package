#!/bin/sh

set -e
set -u
set -o pipefail

set -x

echo 'export sh ==== 1'
echo $0
echo $1
echo $2
echo $3
echo $4
echo 'export sh ==== 1'
echo "$@"
echo 'export sh ==== 2'

# calls xcodebuild with all the arguments passed to this
xcodebuild "$@"
