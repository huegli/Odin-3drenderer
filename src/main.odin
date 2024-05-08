package main

import "core:log"
import "core:os"
import "display"
import "vendor:sdl2"

is_running: bool

fov_factor :: 100.0

N_POINTS :: 9 * 9 * 9

vec2_t :: [2]f32
vec3_t :: [3]f32

cube_points: [N_POINTS]vec3_t
projected_points: [N_POINTS]vec2_t

setup :: proc() {
	// allocate the required memory in bytes to hold the color buffer
	display.rdr.color_buffer = make(
		[dynamic]u32,
		size_of(u32) * display.rdr.window_width * display.rdr.window_height,
	)

	// Creating a SDL Texture that is used to display the color buffer
	display.rdr.color_buffer_texture = sdl2.CreateTexture(
		display.rdr.renderer,
		u32(sdl2.PixelFormatEnum.ARGB8888),
		sdl2.TextureAccess.STREAMING,
		display.rdr.window_width,
		display.rdr.window_height,
	)

	point_count := 0

	for x: f32 = -1.0; x <= 1.0; x += 0.25 {
		for y: f32 = -1.0; y <= 1.0; y += 0.25 {
			for z: f32 = -1.0; z <= 1.0; z += 0.25 {
				new_point := vec3_t{x, y, z}
				cube_points[point_count] = new_point
				point_count += 1
			}
		}
	}
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

project :: proc(point: vec3_t) -> vec2_t {

	projected_point := vec2_t{point.x * fov_factor, point.y * fov_factor}

	return projected_point
}

update :: proc() {
	for i: u32 = 0; i < N_POINTS; i += 1 {
		point := cube_points[i]

		projected_point := project(point)

		projected_points[i] = projected_point
	}
}

render :: proc() {
	display.draw_grid()

	for i: u32 = 0; i < N_POINTS; i += 1 {
		point := projected_points[i]
		display.draw_rect(
			i32(point.x) + display.rdr.window_width / 2,
			i32(point.y) + display.rdr.window_height / 2,
			4,
			4,
			0xFFFFFF00,
		)
	}

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

