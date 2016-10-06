#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

scriptreplay -t $DIR/timing.gz $DIR/typescript.gz
