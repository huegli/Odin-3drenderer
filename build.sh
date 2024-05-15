#!/usr/bin/env bash

if [[ $1 == "debug" ]]
then
    shift

    odin build src -show-timings -o:minimal -out:renderer -vet -strict-style -debug
    exit 0
fi


odin build src -show-timings -o:speed -out:renderer -vet -strict-style -no-bounds-check
