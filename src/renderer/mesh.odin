package renderer

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
