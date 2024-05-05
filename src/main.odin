package main

import "core:c"
import "core:fmt"
import "core:os"
import "vendor:sdl2"

is_running: bool

window: ^sdl2.Window
renderer: ^sdl2.Renderer

color_buffer: [dynamic]u32
color_buffer_texture: ^sdl2.Texture

window_width: c.int
window_height: c.int

initialize_window :: proc() -> bool {
	if (sdl2.Init(sdl2.INIT_EVERYTHING) != 0) {
		fmt.fprint(os.stderr, "Error initializing SDL.")
		return false
	}

	// Use SDL to query what is the fullscreen max width and height
	display_mode: sdl2.DisplayMode
	sdl2.GetCurrentDisplayMode(0, &display_mode)

	window_width = display_mode.w
	window_height = display_mode.h

	// Create a SDL window
	window = sdl2.CreateWindow(
		nil,
		sdl2.WINDOWPOS_CENTERED,
		sdl2.WINDOWPOS_CENTERED,
		window_width,
		window_height,
		sdl2.WINDOW_BORDERLESS,
	)
	if (window == nil) {
		fmt.fprintln(os.stderr, "Error creating SDL Window")
		return false
	}

	// Create a SDL renderer
	renderer = sdl2.CreateRenderer(window, -1, sdl2.RENDERER_SOFTWARE)
	if (renderer == nil) {
		fmt.fprintln(os.stderr, "Error creating SDL renderer")
		return false
	}

	sdl2.SetWindowFullscreen(window, sdl2.WINDOW_FULLSCREEN)

	return true
}

setup :: proc() {
	// allocate the required memory in bytes to hold the color buffer
	color_buffer = make([dynamic]u32, size_of(u32) * window_width * window_height)

	// Creating a SDL Texture that is used to display the color buffer
	color_buffer_texture = sdl2.CreateTexture(
		renderer,
		u32(sdl2.PixelFormatEnum.ARGB8888),
		sdl2.TextureAccess.STREAMING,
		window_width,
		window_height,
	)

}

process_input :: proc() {
	event: sdl2.Event
	sdl2.PollEvent(&event)

	#partial switch (event.type) {
	case .QUIT:
		is_running = false
	case .KEYDOWN:
		if (event.key.keysym.sym == .ESCAPE) {
			is_running = false
		}

	}

}

update :: proc() {

}

render_color_buffer :: proc() {
	sdl2.UpdateTexture(color_buffer_texture, nil, raw_data(color_buffer), window_width * size_of(u32))
	sdl2.RenderCopy(renderer, color_buffer_texture, nil, nil)
}

clear_color_buffer :: proc(color: u32) {
	for y: i32 = 0; y < window_height; y += 1 {
		for x: i32 = 0; x < window_width; x += 1 {
			color_buffer[(window_width * y) + x] = color
		}
	}

}

render :: proc() {
	sdl2.SetRenderDrawColor(renderer, 0, 0, 0, 255)
	sdl2.RenderClear(renderer)

	render_color_buffer()
	clear_color_buffer(0xFFFFFF00)

	sdl2.RenderPresent(renderer)
}

destroy_window :: proc() {
	delete(color_buffer)
	sdl2.DestroyTexture(color_buffer_texture)
	sdl2.DestroyRenderer(renderer)
	sdl2.DestroyWindow(window)
	sdl2.Quit()
}

main :: proc() {
	is_running = initialize_window()

	setup()

	for is_running {
		process_input()
		update()
		render()
	}

	destroy_window()

}
