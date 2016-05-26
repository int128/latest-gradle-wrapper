#!/bin/bash -e

function show_version () {
  ./gradlew -v | sed -ne '/^Gradle/s/^Gradle //p'
}

function bump_version () {
  local version="$1"
  if [ "$(show_version)" = "$version" ]; then
    echo "Gradle Wrapper is up-to-date $version, do nothing"
  else
    echo "Gradle Wrapper is out-of-date $version, updating"
    ./gradlew wrapper --gradle-version "$version"
    ./gradlew wrapper --gradle-version "$version"
    ./gradlew --version
    test "$(show_version)" = "$version"
    echo "Gradle Wrapper is now up-to-date $version, commit and push"
    hub add .
    hub commit -m "Gradle $version"
    hub push origin
  fi
  hub push origin --delete "$TRAVIS_BRANCH"
}

case "$TRAVIS_BRANCH" in
  bump-to-*)
    bump_version "${TRAVIS_BRANCH#bump-to-}";;
  bump-test-*)
    hub checkout -b "${TRAVIS_BRANCH}-result"
    bump_version "${TRAVIS_BRANCH#bump-test-}";;
  *)
    show_version;;
esac
