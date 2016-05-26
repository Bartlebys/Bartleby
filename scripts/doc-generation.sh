#!/bin/sh

# Make the script to on error
set -e

jazzy --xcodebuild-arguments -scheme,bsync
