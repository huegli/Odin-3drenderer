#!/usr/bin/env bash

if [[ $1 == "debug" ]]
then
    shift

    odin build src/ -collection:src=src -out:renderer -use-separate-modules -debug $@
    exit 0
fi


odin build src/ -collection:src=src -out:renderer -o:speed $@
