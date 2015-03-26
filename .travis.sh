#!/bin/bash -xe
test "$TRAVIS_BRANCH"

function update-gradle-template () {
  local version_tobe="$1"
  local version_asis="$(sed -ne 's,gradleVersion=,,p' gradle.properties)"

  if [ "$version_tobe" != "$version_asis" ]; then
    echo "gradleVersion=$version_tobe" > gradle.properties
    ./gradlew wrapper
    ./gradlew wrapper
    hub add .
    hub commit -m "Gradle $version_tobe"
    hub push origin master
  fi
}

function update-gradle-of-user-repository () {
  local repo="$1"
  local version_tobe="$(sed -ne 's,gradleVersion=,,p' gradle.properties)"
  test "$version_tobe"

  hub clone "$repo" _
  cd _
  hub checkout -b "gradle-$version_tobe"
  sed -i -e "s,gradleVersion *= *['\"][0-9a-z\.\-]\+['\"],gradleVersion = '$version_tobe',g" build.gradle
  cp -a ../gradle ../gradlew ../gradlew.bat .
  hub add .
  hub commit -m "Gradle $version_tobe"
  hub fork
  hub push -f "$GH_USER" "gradle-$version_tobe"

  sed -i -e "s,GRADLE_VERSION,$version_tobe,g" ../pull-request.md
  hub pull-request -F ../pull-request.md
  cd ..
}

case "$TRAVIS_BRANCH" in
  update-gradle-template-*)
    update-gradle-template "${TRAVIS_BRANCH#update-gradle-template-}"
    ;;
  update-gradle-of-*)
    update-gradle-of-user-repository "${TRAVIS_BRANCH#update-gradle-of-}"
    ;;
esac
