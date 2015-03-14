#!/bin/bash -xe
test "$TRAVIS_BRANCH"

function update-gradle-template () {
  local GRADLE_VERSION="${TRAVIS_BRANCH##*-}"

  ./gradlew -PgradleVersion="$GRADLE_VERSION" wrapper
  ./gradlew -PgradleVersion="$GRADLE_VERSION" wrapper

  git checkout -b "$GRADLE_VERSION"
  git add gradle/wrapper gradlew gradlew.bat
  git commit -m "Gradle $GRADLE_VERSION"
  git push origin "$GRADLE_VERSION"
  git push origin --delete "$TRAVIS_BRANCH"
}

case "$TRAVIS_BRANCH" in
  build-*)  update-gradle-template;;
esac
