#!/bin/bash -xe
test "$TRAVIS_BRANCH"

function update-gradle-template () {
  local version_tobe="${TRAVIS_BRANCH#*-}"
  local version_asis="$(sed -ne 's,gradleVersion=,,p' gradle.properties)"

  if [ "$version_tobe" != "$version_asis" ]; then
    echo "gradleVersion=$version_tobe" > gradle.properties
    ./gradlew wrapper
    ./gradlew wrapper
    git add .
    git commit -m "Gradle $version_tobe"
    git push origin master
  fi

  git push origin --delete "$TRAVIS_BRANCH"
}

function update-gradle-of-user-repository () {
  local repo="${TRAVIS_BRANCH#*-}"
  local version_tobe="$(sed -ne 's,gradleVersion=,,p' gradle.properties)"
  test "$version_tobe"

  git clone "https://github.com/gradleupdate/${repo}.git" forked
  cd forked
  git checkout -b "gradle-$version_tobe"
  sed -i -e "s,gradleVersion *= *['\"][0-9a-z\.\-]\+['\"],gradleVersion = '$version_tobe',g" build.gradle
  cp -a ../gradle ../gradlew ../gradlew.bat .
  git add .
  git commit -m "Gradle $version_tobe"
  git push origin "gradle-$version_tobe"

  cd ..
  git push origin --delete "$TRAVIS_BRANCH"
}

case "$TRAVIS_BRANCH" in
  build-*)  update-gradle-template;;
  pr-*)     update-gradle-of-user-repository;;
esac
