package renderer

import "core:log"
import "core:os"
import "core:slice"
import "vendor:sdl2"

is_running: bool

fov_factor :: 640.0

previous_frame_time: u32 = 0

triangles_to_render: [dynamic]triangle_t
sorted_triangles: []triangle_t

camera_position: vec3_t

setup :: proc() {

	rdr.render_method = .RENDER_WIRE
	rdr.cull_method = .CULL_BACKFACE

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

	// load_obj_file_data("assets/f22.obj")
	load_cube_mesh_data()
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
		if (event.key.keysym.sym == .NUM1) {
			rdr.render_method = .RENDER_WIRE_VERTEX
		}
		if (event.key.keysym.sym == .NUM2) {
			rdr.render_method = .RENDER_WIRE
		}
		if (event.key.keysym.sym == .NUM3) {
			rdr.render_method = .RENDER_FILL_TRIANGLE
		}
		if (event.key.keysym.sym == .NUM4) {
			rdr.render_method = .RENDER_FILL_TRIANGLE_WIRE
		}
		if (event.key.keysym.sym == .C) {
			rdr.cull_method = .CULL_BACKFACE
		}
		if (event.key.keysym.sym == .D) {
			rdr.cull_method = .CULL_NONE
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
	mesh.rotation.y += 0.01
	mesh.rotation.z += 0.01

	for mesh_face in mesh.faces {

		face_vertices: [3]vec3_t

		face_vertices[0] = mesh.vertices[mesh_face.a - 1]
		face_vertices[1] = mesh.vertices[mesh_face.b - 1]
		face_vertices[2] = mesh.vertices[mesh_face.c - 1]

		transformed_vertices: [3]vec3_t

		for j in 0 ..< 3 {
			transformed_vertex := face_vertices[j]

			transformed_vertex = vec3_rotate_x(transformed_vertex, mesh.rotation.x)
			transformed_vertex = vec3_rotate_y(transformed_vertex, mesh.rotation.y)
			transformed_vertex = vec3_rotate_z(transformed_vertex, mesh.rotation.z)

			transformed_vertex.z += 5

			transformed_vertices[j] = transformed_vertex
		}

		// Back-face culling
		vector_a := transformed_vertices[0] //   A
		vector_b := transformed_vertices[1] //  / \
		vector_c := transformed_vertices[2] // B---C

		vector_ab := vector_b - vector_a
		vector_ac := vector_c - vector_a

		// Compute the normal of the triangle
		normal := vec3_cross(vector_ab, vector_ac)

		// Normalize the face normal vector_a
		normal = vec3_normalize(normal)

		// Find the vector between point A and the camera
		camera_ray := camera_position - vector_a

		if rdr.cull_method == .CULL_BACKFACE && vec3_dot(normal, camera_ray) < 0 {
			continue
		}

		projected_points: [3]vec2_t

		// Loop all three vertices to perform the projection
		for j in 0 ..< 3 {
			// Project the current point
			projected_points[j] = project(transformed_vertices[j])

			// scale and translate the projected point to the center of the screen
			projected_points[j].x += f32(rdr.window_width) / 2.0
			projected_points[j].y += f32(rdr.window_height) / 2.0

		}

		// Calculate the average depth for each face based on the vertices after transformation
		avg_depth :=
			(transformed_vertices[0].z + transformed_vertices[1].z + transformed_vertices[2].z) /
			3.0


		projected_triangle: triangle_t = {
			points    = {
				{projected_points[0].x, projected_points[0].y},
				{projected_points[1].x, projected_points[1].y},
				{projected_points[2].x, projected_points[2].y},
			},
			color     = mesh_face.color,
			avg_depth = avg_depth,
		}

		append(&triangles_to_render, projected_triangle)
	}

	// Sort the triangles to render by their avg depth
	sorted_triangles = triangles_to_render[:]
	slice.sort_by(sorted_triangles, proc(a, b: triangle_t) -> bool {
		return a.avg_depth < b.avg_depth
	})


}

render :: proc() {
	draw_grid()

	// draw_filled_triangle(100, 100, 400, 50, 500, 300, 0xFF00FF00)
	for triangle in sorted_triangles {


		if rdr.render_method == .RENDER_FILL_TRIANGLE ||
		   rdr.render_method == .RENDER_FILL_TRIANGLE_WIRE {
			draw_filled_triangle(
				i32(triangle.points[0].x),
				i32(triangle.points[0].y),
				i32(triangle.points[1].x),
				i32(triangle.points[1].y),
				i32(triangle.points[2].x),
				i32(triangle.points[2].y),
				triangle.color,
			)
		}

		if rdr.render_method == .RENDER_WIRE ||
		   rdr.render_method == .RENDER_WIRE_VERTEX ||
		   rdr.render_method == .RENDER_FILL_TRIANGLE_WIRE {
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

		if rdr.render_method == .RENDER_WIRE_VERTEX {
			draw_rect(
				i32(triangle.points[0].x - 3),
				i32(triangle.points[0].y - 3),
				6,
				6,
				0xFFFF0000,
			)
			draw_rect(
				i32(triangle.points[1].x - 3),
				i32(triangle.points[1].y - 3),
				6,
				6,
				0xFFFF0000,
			)
			draw_rect(
				i32(triangle.points[2].x - 3),
				i32(triangle.points[2].y - 3),
				6,
				6,
				0xFFFF0000,
			)
		}
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
