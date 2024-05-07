package display

import "core:c"
import "core:log"
import "core:os"
import "vendor:sdl2"

RENDERER :: struct {
    window:               ^sdl2.Window,
    renderer:             ^sdl2.Renderer,
    color_buffer:         [dynamic]u32,
    color_buffer_texture: ^sdl2.Texture,
    window_width:         c.int,
    window_height:        c.int,
}

rdr := RENDERER{}

initialize_window :: proc() -> (ok: bool) 
{
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
    rdr.renderer = sdl2.CreateRenderer(
        rdr.window,
        -1,
        {.SOFTWARE, .PRESENTVSYNC},
    )
    if (rdr.renderer == nil) {
        log.errorf("Error creating SDL renderer")
        return false
    }

    // sdl2.SetWindowFullscreen(rdr.window, sdl2.WINDOW_FULLSCREEN)

    return true
}

draw_grid :: proc() 
{
    for y: i32 = 0; y < rdr.window_height; y += 10 {
        for x: i32 = 0; x < rdr.window_width; x += 10 {
            rdr.color_buffer[(rdr.window_width * y) + x] = 0xFF333333
        }
    }
}

draw_pixel :: proc(x: i32, y: i32, color: u32) 
{
    if (x < rdr.window_width && y < rdr.window_height) {
        rdr.color_buffer[(rdr.window_width * y) + x] = color
    }
}

draw_rect :: proc(x: i32, y: i32, width: i32, height: i32, color: u32) 
{
    for i: i32 = 0; i < height; i += 1 {
        for j: i32 = 0; j < width; j += 1 {
            draw_pixel(x + j, y + i, color)
        }
    }
}

render_color_buffer :: proc() 
{
    sdl2.UpdateTexture(
        rdr.color_buffer_texture,
        nil,
        raw_data(rdr.color_buffer),
        rdr.window_width * size_of(u32),
    )
    sdl2.RenderCopy(rdr.renderer, rdr.color_buffer_texture, nil, nil)
}

clear_color_buffer :: proc(color: u32) 
{
    for y: i32 = 0; y < rdr.window_height; y += 1 {
        for x: i32 = 0; x < rdr.window_width; x += 1 {
            rdr.color_buffer[(rdr.window_width * y) + x] = color
        }
    }

}

destroy_window :: proc() 
{
    sdl2.DestroyRenderer(rdr.renderer)
    sdl2.DestroyWindow(rdr.window)
    sdl2.Quit()
}
