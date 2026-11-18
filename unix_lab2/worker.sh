#!/bin/sh

SHARED_DIR="/shared"
LOCK_FILE="${SHARED_DIR}/.lock"

CONTAINER_ID=$(hostname)

SEQ=1

while true; do
  (
  flock -x 9
  N=1
  while true; do
    if [ "$N" -lt 10 ]; then
      FILENAME="00${N}"
    elif [ "$N" -lt 100 ]; then
      FILENAME="0${N}"
    else
      FILENAME="${N}"
    fi
    
    FILEPATH="${SHARED_DIR}/${FILENAME}"
    if [ ! -e "$FILEPATH" ]; then
      ( set -C; echo "${CONTAINER_ID}:${SEQ}" > "$FILEPATH" ) 2>/dev/null && break
    fi
    N=$((N + 1))
  done
 ) 9>"$LOCK_FILE"
 
 sleep 1
 rm -f "$FILEPATH"
 SEQ=$((SEQ + 1))
 sleep 1
 
done

