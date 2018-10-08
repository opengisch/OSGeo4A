#!/usr/bin/env bash

# see https://stackoverflow.com/a/26082445/1548052

RECIPE=$1
COMMAND=$2

export PING_SLEEP=60s
export CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export BUILD_OUTPUT=${RECIPES_PATH}/${RECIPE}/build.out

touch ${BUILD_OUTPUT}

dump_output() {
   echo Tailing the last 500 lines of output:
   tail -500 ${BUILD_OUTPUT}
}
error_handler() {
  echo ERROR: An error was encountered with the build.
  dump_output
  exit 1
}

# If an error occurs, run our error handler to output a tail of the build
trap 'error_handler' ERR

Set up a repeating loop to send some output to Travis.

bash -c "count=0; while true; do echo -ne \"building for \${count} minutes\\r\"; sleep $PING_SLEEP; (( count++ )); done" &
PING_LOOP_PID=$!

# My build is using maven, but you could build anything with this, E.g.
$(${COMMAND}) >> $BUILD_OUTPUT 2>&1

# The build finished without returning an error so dump a tail of the output
dump_output

# nicely terminate the ping output loop
kill $PING_LOOP_PID