#!/usr/bin/env bash

docker image tag "${IMAGEID:-${CONTAINER}:${SRCTAG}}" "$HANDLE" || exit 1
docker image push "$HANDLE" || exit 1
