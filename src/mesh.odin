package renderer

import "core:os"
import "core:strconv"
import "core:strings"

mesh_t :: struct {
	vertices: [dynamic]vec3_t,
	faces:    [dynamic]face_t,
	rotation: vec3_t,
}

mesh: mesh_t

N_CUBE_VERTICES :: 8
N_CUBE_FACES :: (6 * 2)

cube_vertices: [N_CUBE_VERTICES]vec3_t = {
	vec3_t{-1, -1, -1},
	vec3_t{-1, 1, -1},
	vec3_t{1, 1, -1},
	vec3_t{1, -1, -1},
	vec3_t{1, 1, 1},
	vec3_t{1, -1, 1},
	vec3_t{-1, 1, 1},
	vec3_t{-1, -1, 1},
}

cube_faces: [N_CUBE_FACES]face_t = {
	// front
	{a = 1, b = 2, c = 3},
	{a = 1, b = 3, c = 4},
	// right
	{a = 4, b = 3, c = 5},
	{a = 4, b = 5, c = 6},
	// back
	{a = 6, b = 5, c = 7},
	{a = 6, b = 7, c = 8},
	// left
	{a = 8, b = 7, c = 2},
	{a = 8, b = 2, c = 1},
	// top
	{a = 2, b = 7, c = 5},
	{a = 2, b = 5, c = 3},
	// bottom
	{a = 6, b = 8, c = 1},
	{a = 6, b = 1, c = 4},
}

load_cube_mesh_data :: proc() {
	for cube_vertex in cube_vertices {
		append(&mesh.vertices, cube_vertex)
	}
	for cube_face in cube_faces {
		append(&mesh.faces, cube_face)
	}
}

load_obj_file_data :: proc(filename: string) {
	data, ok := os.read_entire_file(filename)
	if !ok {
		return
	}
	defer delete(data)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if strings.has_prefix(line, "v ") {
			words := strings.split(line, " ")
			x, _ := strconv.parse_f32(words[1])
			y, _ := strconv.parse_f32(words[2])
			z, _ := strconv.parse_f32(words[3])
			append(&mesh.vertices, vec3_t{x, y, z})
		} else if strings.has_prefix(line, "f ") {
			words := strings.split(line, " ")
			vertices := strings.split(words[1], "/")
			a, _ := strconv.parse_int(vertices[0])
			vertices = strings.split(words[2], "/")
			b, _ := strconv.parse_int(vertices[0])
			vertices = strings.split(words[3], "/")
			c, _ := strconv.parse_int(vertices[0])
			append(&mesh.faces, face_t{a, b, c})
		}
	}
}
