#!/bin/sh
pushd ~/.dotfiles
home-manager switch -f ./users/andre/home.nix
popd
