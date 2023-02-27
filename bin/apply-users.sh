#!/bin/sh
pushd ~/.dotfiles
nix build .#homeManagerConfigurations.andre.activationPackage
./result/activate
popd
