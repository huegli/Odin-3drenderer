@echo off

setlocal enabledelayedexpansion
if "%1" == "debug" (
    odin build src\ -show-timings  -collection:src=src  -microarch:native -out:renderer.exe -o:minimal  -no-bounds-check -use-separate-modules -debug
) else (
    odin build src\ -show-timings -microarch:native -collection:src=src -out:renderer.exe -o:speed  -no-bounds-check
)