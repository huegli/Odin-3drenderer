package main

import "core:c"
import "core:log"
import "core:os"
import "vendor:sdl2"

RENDERER :: struct {
	is_running:           bool,
	window:               ^sdl2.Window,
	renderer:             ^sdl2.Renderer,
	color_buffer:         [dynamic]u32,
	color_buffer_texture: ^sdl2.Texture,
	window_width:         c.int,
	window_height:        c.int,
}

rdr := RENDERER{}

initialize_window :: proc() -> (ok: bool) {
	if sdl_res := sdl2.Init(sdl2.INIT_EVERYTHING); sdl_res != 0 {
		log.errorf("Error initializing SDL.")
		return false
	}

	// Use SDL to query what is the fullscreen max width and height
	display_mode: sdl2.DisplayMode
	sdl2.GetCurrentDisplayMode(0, &display_mode)

	rdr.window_width = display_mode.w
	rdr.window_height = display_mode.h

	// Create a SDL window
	rdr.window = sdl2.CreateWindow(
		nil,
		sdl2.WINDOWPOS_CENTERED,
		sdl2.WINDOWPOS_CENTERED,
		rdr.window_width,
		rdr.window_height,
		sdl2.WINDOW_BORDERLESS,
	)
	if (rdr.window == nil) {
		log.errorf("Error creating SDL Window")
		return false
	}

	// Create a SDL renderer
	rdr.renderer = sdl2.CreateRenderer(rdr.window, -1, {.SOFTWARE})
	if (rdr.renderer == nil) {
		log.errorf("Error creating SDL renderer")
		return false
	}

	// sdl2.SetWindowFullscreen(rdr.window, sdl2.WINDOW_FULLSCREEN)

	return true
}

setup :: proc() {
	// allocate the required memory in bytes to hold the color buffer
	rdr.color_buffer = make([dynamic]u32, size_of(u32) * rdr.window_width * rdr.window_height)

	// Creating a SDL Texture that is used to display the color buffer
	rdr.color_buffer_texture = sdl2.CreateTexture(
		rdr.renderer,
		u32(sdl2.PixelFormatEnum.ARGB8888),
		sdl2.TextureAccess.STREAMING,
		rdr.window_width,
		rdr.window_height,
	)

}

process_input :: proc() {
	event: sdl2.Event
	sdl2.PollEvent(&event)

	#partial switch (event.type) {
	case .QUIT:
		rdr.is_running = false
	case .KEYDOWN:
		if (event.key.keysym.sym == .ESCAPE) {
			rdr.is_running = false
		}

	}

}

update :: proc() {

}

render_color_buffer :: proc() {
	sdl2.UpdateTexture(
		rdr.color_buffer_texture,
		nil,
		raw_data(rdr.color_buffer),
		rdr.window_width * size_of(u32),
	)
	sdl2.RenderCopy(rdr.renderer, rdr.color_buffer_texture, nil, nil)
}

clear_color_buffer :: proc(color: u32) {
	for y: i32 = 0; y < rdr.window_height; y += 1 {
		for x: i32 = 0; x < rdr.window_width; x += 1 {
			rdr.color_buffer[(rdr.window_width * y) + x] = color
		}
	}

}

render :: proc() {
	sdl2.SetRenderDrawColor(rdr.renderer, 0, 0, 0, 255)
	sdl2.RenderClear(rdr.renderer)

	render_color_buffer()
	clear_color_buffer(0xFFFFFF00)

	sdl2.RenderPresent(rdr.renderer)
}

cleanup :: proc() {
	delete(rdr.color_buffer)
	sdl2.DestroyTexture(rdr.color_buffer_texture)
}

destroy_window :: proc() {
	sdl2.DestroyRenderer(rdr.renderer)
	sdl2.DestroyWindow(rdr.window)
	sdl2.Quit()
}

main :: proc() {
	context.logger = log.create_console_logger()

	if rdr.is_running = initialize_window(); !rdr.is_running {
		os.exit(1)
	}
	defer destroy_window()

	setup()
	defer cleanup()

	for rdr.is_running {
		process_input()
		update()
		render()
	}
}
