#!/bin/bash
set -ex

IMAGE=akeylimepie/nginx

NGINX_VERSIONS=(
  1.19.5
)

function build() {
  NGINX_VERSION=$1

  if [[ $1 =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    MAJOR=${BASH_REMATCH[1]}
    MINOR=${BASH_REMATCH[2]}
    PATCH=${BASH_REMATCH[3]}
  else
    exit 1
  fi

  TAG_LATEST="${MAJOR}.${MINOR}-latest"

  docker build \
    --build-arg NGINX_VERSION="$NGINX_VERSION" \
    -t $IMAGE:"$TAG_LATEST" .

  TAG_SPECIAL="${MAJOR}.${MINOR}.${PATCH}"
  tag "$TAG_LATEST" "$TAG_SPECIAL"

  TAGS+=("$TAG_LATEST")
  TAGS+=("$TAG_SPECIAL")
}

function tag() {
  docker tag $IMAGE:"$1" $IMAGE:"$2"
}

for NGINX_VERSION in "${NGINX_VERSIONS[@]}"; do
  build "$NGINX_VERSION"
done

for TAG in "${TAGS[@]}"; do
  docker push $IMAGE:"$TAG"
done
