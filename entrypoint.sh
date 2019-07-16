#!/usr/bin/env bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback
set -x

USER_ID=${LOCAL_USER_ID:-1001}
GROUP_ID=${LOCAL_GROUP_ID:-1001}

echo "Starting with UID : $USER_ID, GID : $GROUP_ID"

addgroup --gid $GROUP_ID user
adduser  --shell /bin/bash --no-create-home --disabled-password \
          --gid $GROUP_ID --uid $USER_ID --gecos '' user

export HOME=/home/user

exec /usr/local/bin/gosu user "$@"
