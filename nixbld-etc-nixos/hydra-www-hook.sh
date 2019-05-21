#!/usr/bin/env bash

set -e

# Argument 1:
CONF=$1
# Argument 2: HTTP location
LOCATION=$2
# Argument 3: HTTP alias target within the derivation output
HTTP_PATH=$3
# Get path of first output
OUTPUT=$(jq -r '.outputs[0].path' < $HYDRA_JSON)
HASH=${OUTPUT:11:32}
ROOT="$OUTPUT/$HTTP_PATH"

cat > $CONF <<EOF
location $LOCATION {
         alias $ROOT;

         # Do not generate Etags from /nix/store's 1970 timestamps.
         etag off;
         add_header etag "\"$HASH\"";
}
EOF

/run/wrappers/bin/sudo systemctl reload nginx
