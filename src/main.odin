package main

import "core:fmt"
import "vendor:sdl2"

main :: proc() {
	sdl2.Init(sdl2.INIT_EVERYTHING)
	fmt.println("Hello, world")
}
