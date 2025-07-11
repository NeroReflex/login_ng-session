#!/bin/sh

set -e

new_version=${1}
version=$(grep -oP 'version\s*=\s*"\K[0-9]+\.[0-9]+\.[0-9]+' login_ng-session/Cargo.toml | head -n 1)
echo "Replacing version $version with $new_version"
find . -name "*.toml"  -type f -exec sed -i "s/\"$version\"/\"$new_version\"/g" {} +
cargo bitbake
git add .
git commit -m "Bump version to $new_version"
git tag $new_version