package main

import "core:log"
import "core:os"
import "display"
import "vendor:sdl2"

is_running: bool

setup :: proc() 
{
	// bring rdr struct into this namespace
	using display.rdr

    // allocate the required memory in bytes to hold the color buffer
    color_buffer = make(
        [dynamic]u32,
        size_of(u32) * window_width * window_height,
    )

    // Creating a SDL Texture that is used to display the color buffer
    color_buffer_texture = sdl2.CreateTexture(
        renderer,
        u32(sdl2.PixelFormatEnum.ARGB8888),
        sdl2.TextureAccess.STREAMING,
        window_width,
        window_height,
    )

}

process_input :: proc() 
{
    event: sdl2.Event
    sdl2.PollEvent(&event)

    #partial switch (event.type) 
    {
    case .QUIT:
        is_running = false
    case .KEYDOWN:
        if (event.key.keysym.sym == .ESCAPE) {
            is_running = false
        }

    }

}

update :: proc() 
{

}

render :: proc() 
{
    // bring rdr struct into this namespace
	using display.rdr

	sdl2.SetRenderDrawColor(renderer, 0, 0, 0, 255)
    sdl2.RenderClear(renderer)

    display.draw_grid()

    display.draw_rect(100, 100, 300, 200, 0xFFFF0000)
    display.draw_pixel(150, 150, 0xFFFFFF00)

    display.render_color_buffer()
    display.clear_color_buffer(0xFF000000)

    sdl2.RenderPresent(renderer)
}

cleanup :: proc() 
{
	// bring rdr struct into this namespace
	using display.rdr

    delete(color_buffer)
    sdl2.DestroyTexture(color_buffer_texture)
}

main :: proc() 
{
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
