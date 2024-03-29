#!/bin/bash
set -ex

IMAGE=akeylimepie/nginx

NGINX_VERSIONS=(
  1.23.2
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
  TAG_SPECIAL="${MAJOR}.${MINOR}.${PATCH}"

  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg NGINX_VERSION="$NGINX_VERSION" \
    --tag $IMAGE:"latest" \
    --tag $IMAGE:"$TAG_LATEST" \
    --tag $IMAGE:"$TAG_SPECIAL" \
    --push \
    .
}

for NGINX_VERSION in "${NGINX_VERSIONS[@]}"; do
  build "$NGINX_VERSION"
done
