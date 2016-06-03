#!/bin/sh

# Make the script to on error
set -e

xcodebuild -workspace Bartleby.xcworkspace -scheme "BsyncXPC" $1 build test
xcodebuild -workspace Bartleby.xcworkspace -scheme "bsync" $1 build test
xcodebuild -workspace Bartleby.xcworkspace -scheme "Bartleby OSX" $1 build test
xcodebuild -workspace Bartleby.xcworkspace -scheme "Bartleby iOS" $1 build
xcodebuild -workspace Bartleby.xcworkspace -scheme "bartleby" $1 build
