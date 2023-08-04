#!/bin/sh -e

VERSION=1.0

# Navigate to the directory of this script
cd $(dirname $(readlink -f $0))
cd ..

build() {
    if [ "$(uname)" == "Darwin" ]; then
       darwin-rebuild switch --flake .# $@
    elif [ "$(uname)" == "Linux" ]; then
       sudo nixos-rebuild switch --flake .# $@
    else
       echo "Unknown platform"
    fi
}

build
