package main

import "core:os"
import "core:log"
import "vendor:sdl2"
import "display"

is_running: bool

setup :: proc() {
	// allocate the required memory in bytes to hold the color buffer
	display.rdr.color_buffer = make([dynamic]u32, size_of(u32) * display.rdr.window_width * display.rdr.window_height)

	// Creating a SDL Texture that is used to display the color buffer
	display.rdr.color_buffer_texture = sdl2.CreateTexture(
		display.rdr.renderer,
		u32(sdl2.PixelFormatEnum.ARGB8888),
		sdl2.TextureAccess.STREAMING,
		display.rdr.window_width,
		display.rdr.window_height,
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

render :: proc() {
	sdl2.SetRenderDrawColor(display.rdr.renderer, 0, 0, 0, 255)
	sdl2.RenderClear(display.rdr.renderer)

	display.draw_grid()

	display.draw_rect(100,100, 300, 200, 0xFFFF0000)
	display.draw_pixel(150, 150, 0xFFFFFF00)

	display.render_color_buffer()
	display.clear_color_buffer(0xFF000000)

	sdl2.RenderPresent(display.rdr.renderer)
}

cleanup :: proc() {
	delete(display.rdr.color_buffer)
	sdl2.DestroyTexture(display.rdr.color_buffer_texture)
}

main :: proc() {
	context.logger = log.create_console_logger()

	if is_running = display.initialize_window(); !is_running {
		os.exit(1)
	}
	defer display.destroy_window()

	setup()
	defer cleanup()

	for is_running {
		process_input()
		update()
		render()
	}
}
