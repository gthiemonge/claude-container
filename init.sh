#!/bin/sh

workdir="$1"
shift
cd $workdir

exec /home/claude/.local/bin/claude "$@"
