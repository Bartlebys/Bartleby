#!/bin/sh

# Make the script to on error
set -e

xcodebuild -workspace Bartleby.xcworkspace -scheme "BsyncXPC" clean build test
xcodebuild -workspace Bartleby.xcworkspace -scheme "bsync" clean build test
xcodebuild -workspace Bartleby.xcworkspace -scheme "Bartleby OSX" clean build test
xcodebuild -workspace Bartleby.xcworkspace -scheme "Bartleby iOS" clean build test
xcodebuild -workspace Bartleby.xcworkspace -scheme "bartleby" clean build
