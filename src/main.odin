package renderer

import "core:log"
import "core:os"
import "vendor:sdl2"

is_running: bool

fov_factor :: 640.0

previous_frame_time: u32 = 0

triangles_to_render: [dynamic]triangle_t

camera_position: vec3_t = {0, 0, 5}

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

	load_obj_file_data("assets/f22.obj")
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

	return vec2_t{point.x * fov_factor / point.z, point.y * fov_factor / point.z}
}

update :: proc() {
	// wait some time until we reach the target frame time in milliseconds
	time_to_wait := FRAME_TARGET_TIME - (sdl2.GetTicks() - previous_frame_time)

	// only delay execution if we are running too fast
	if time_to_wait > 0 && time_to_wait <= FRAME_TARGET_TIME {
		sdl2.Delay(time_to_wait)
	}

	previous_frame_time = sdl2.GetTicks()

	clear(&triangles_to_render)

	mesh.rotation.x += 0.01
	mesh.rotation.y += 0.00
	mesh.rotation.z += 0.00

	for mesh_face in mesh.faces {

		face_vertices: [3]vec3_t

		face_vertices[0] = mesh.vertices[mesh_face.a - 1]
		face_vertices[1] = mesh.vertices[mesh_face.b - 1]
		face_vertices[2] = mesh.vertices[mesh_face.c - 1]

		projected_triangle := triangle_t{}

		for j := 0; j < 3; j += 1 {
			transformed_vertex := face_vertices[j]

			transformed_vertex = vec3_rotate_x(transformed_vertex, mesh.rotation.x)
			transformed_vertex = vec3_rotate_y(transformed_vertex, mesh.rotation.y)
			transformed_vertex = vec3_rotate_z(transformed_vertex, mesh.rotation.z)

			transformed_vertex.z -= camera_position.z

			projected_point := project(transformed_vertex)

			projected_point.x += f32(rdr.window_width) / 2.0
			projected_point.y += f32(rdr.window_height) / 2.0

			projected_triangle.points[j] = projected_point
		}

		append(&triangles_to_render, projected_triangle)
	}

}

render :: proc() {
	draw_grid()

	for triangle in triangles_to_render {
		draw_rect(i32(triangle.points[0].x), i32(triangle.points[0].y), 3, 3, 0xFFFFFF00)
		draw_rect(i32(triangle.points[1].x), i32(triangle.points[1].y), 3, 3, 0xFFFFFF00)
		draw_rect(i32(triangle.points[2].x), i32(triangle.points[2].y), 3, 3, 0xFFFFFF00)

		draw_triangle(
			i32(triangle.points[0].x),
			i32(triangle.points[0].y),
			i32(triangle.points[1].x),
			i32(triangle.points[1].y),
			i32(triangle.points[2].x),
			i32(triangle.points[2].y),
			0xFF00FF00,
		)
	}

	render_color_buffer()
	clear_color_buffer(0xFF000000)

	sdl2.RenderPresent(rdr.renderer)
}

cleanup :: proc() {
	delete(rdr.color_buffer)
	sdl2.DestroyTexture(rdr.color_buffer_texture)
}

main :: proc() {
	context.logger = log.create_console_logger()

	if is_running = initialize_window(); !is_running {
		os.exit(1)
	}
	defer destroy_window()

	setup()
	defer cleanup()

	for is_running {
		process_input()
		update()
		render()
	}
}
