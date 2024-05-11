package main

import "core:log"
import "core:os"
import "renderer"
import "vendor:sdl2"

is_running: bool

fov_factor :: 640.0

N_POINTS :: 9 * 9 * 9


cube_points: [N_POINTS]renderer.vec3_t
projected_points: [N_POINTS]renderer.vec2_t

camera_position: renderer.vec3_t = { 0, 0, 5}
cube_rotation: renderer.vec3_t

setup :: proc() {
	using renderer

	// allocate the required memory in bytes to hold the color buffer
	rdr.color_buffer = make(
		[dynamic]u32,
		size_of(u32) * rdr.window_width * rdr.window_height,
	)

	// Creating a SDL Texture that is used to display the color buffer
	rdr.color_buffer_texture = sdl2.CreateTexture(
		rdr.renderer,
		u32(sdl2.PixelFormatEnum.ARGB8888),
		sdl2.TextureAccess.STREAMING,
		rdr.window_width,
		rdr.window_height,
	)

	point_count := 0

	for x: f32 = -1.0; x <= 1.0; x += 0.25 {
		for y: f32 = -1.0; y <= 1.0; y += 0.25 {
			for z: f32 = -1.0; z <= 1.0; z += 0.25 {
				cube_points[point_count] = renderer.vec3_t{x, y, z}
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

project :: proc(point: renderer.vec3_t) -> renderer.vec2_t {

	return renderer.vec2_t{
		point.x * fov_factor / point.z,
	    point.y * fov_factor / point.z,
	}
}

update :: proc() {

    cube_rotation.x += 0.01
    cube_rotation.y += 0.01
    cube_rotation.z += 0.01

	for i: u32 = 0; i < N_POINTS; i += 1 {
		point := cube_points[i]

		using renderer

        transformed_point := vec3_rotate_x(point, cube_rotation.x)
        transformed_point = vec3_rotate_y(transformed_point, cube_rotation.y)
        transformed_point = vec3_rotate_z(transformed_point, cube_rotation.z)

		transformed_point.z -= camera_position.z
		
		projected_point := project(transformed_point)

		projected_points[i] = projected_point
	}
}

render :: proc() {
	using renderer

	draw_grid()

	for i: u32 = 0; i < N_POINTS; i += 1 {
		point := projected_points[i]
		draw_rect(
			i32(point.x) + rdr.window_width / 2,
			i32(point.y) + rdr.window_height / 2,
			4,
			4,
			0xFFFFFF00,
		)
	}

	render_color_buffer()
	clear_color_buffer(0xFF000000)

	sdl2.RenderPresent(rdr.renderer)
}

cleanup :: proc() {
	delete(renderer.rdr.color_buffer)
	sdl2.DestroyTexture(renderer.rdr.color_buffer_texture)
}

main :: proc() {
	context.logger = log.create_console_logger()

	if is_running = renderer.initialize_window(); !is_running {
		os.exit(1)
	}
	defer renderer.destroy_window()

	setup()
	defer cleanup()

	for is_running {
		process_input()
		update()
		render()
	}
}
