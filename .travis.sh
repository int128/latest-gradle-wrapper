#!/bin/bash -xe
test "$TRAVIS_BRANCH"

function update-gradle-template () {
  local GRADLE_VERSION="${TRAVIS_BRANCH#*-}"

  ./gradlew -PgradleVersion="$GRADLE_VERSION" wrapper
  ./gradlew -PgradleVersion="$GRADLE_VERSION" wrapper
  echo "$GRADLE_VERSION" > gradle-version

  git checkout -b "$GRADLE_VERSION"
  git add gradle/wrapper gradlew gradlew.bat gradle-version
  git commit -m "Gradle $GRADLE_VERSION"
  git push origin "$GRADLE_VERSION"
  git push origin --delete "$TRAVIS_BRANCH"
}

function update-gradle-of-user-repository () {
  local REPO="${TRAVIS_BRANCH#*-}"
  local TEMPLATE_DIR="$PWD"
  local GRADLE_VERSION="$(cat gradle-version)"
  test "$GRADLE_VERSION"

  git clone "https://github.com/gradleupdate/${REPO}.git" "$HOME/$REPO"
  cd "$HOME/$REPO"
  git checkout -b "gradle-$GRADLE_VERSION"
  mkdir -p gradle/wrapper
  cp -a "$TEMPLATE_DIR/gradle/wrapper" ./gradle
  cp -a "$TEMPLATE_DIR/gradlew" .
  cp -a "$TEMPLATE_DIR/gradlew.bat" .
  sed -i -e "s,gradleVersion *= *['\"][0-9a-z\.\-]\+['\"],gradleVersion = '$GRADLE_VERSION',g" build.gradle
  git add gradle/wrapper gradlew gradlew.bat build.gradle
  git commit -m "Gradle $GRADLE_VERSION"
  git push origin "gradle-$GRADLE_VERSION"

  cd "$TEMPLATE_DIR"
  git push origin --delete "$TRAVIS_BRANCH"
}

case "$TRAVIS_BRANCH" in
  build-*)  update-gradle-template;;
  pr-*)     update-gradle-of-user-repository;;
esac
