#!/usr/bin/env bash

handle="${REGISTRY}/${NAMESPACE}/${CONTAINER}:${VERSION}"

docker image tag "${IMAGEID:-${CONTAINER}:${SRCTAG}}" "$handle" || exit 1
docker image push "$handle" || exit 1

echo "name=$handle" >> $GITHUB_OUTPUT
