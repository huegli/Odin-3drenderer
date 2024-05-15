@echo off

setlocal enabledelayedexpansion
if "%1" == "debug" (
    odin build src -show-timings -out:renderer.exe -o:minimal -strict-style -vet -no-bounds-check -debug
) else (
    odin build src -show-timings -out:renderer.exe -o:speed -strict-style -vet -no-bounds-check
)
