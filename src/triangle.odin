package renderer

face_t :: struct {
	a: i32,
	b: i32,
	c: i32,
	color: u32,
}

triangle_t :: struct {
	points: [3]vec2_t,
	color: u32,
	avg_depth: f32,
}

///////////////////////////////////////////////////////////////////////////////////
// Draw a filled triangle wih a flat bottom
///////////////////////////////////////////////////////////////////////////////////
//
//              (x0,y0)
//                / \
//               /   \
//              /     \
//             /       \
//          (x1,y1)---(x2,y2)
//
///////////////////////////////////////////////////////////////////////////////////

fill_flat_bottom_triangle :: proc(x0, y0, x1, y1, x2, y2: i32, color: u32) {
	// find the two slopes (two triangle legs)
	inv_slope_1 := f32(x1 - x0) / f32(y1 - y0)
	inv_slope_2 := f32(x2 - x0) / f32(y2 - y0)

	// Start x_start and x_end from the top vertex (x0)
	x_start := f32(x0)
	x_end := f32(x0)

	// loop all the scanlines from top to bottom
	for y := y0; y <= y2; y += 1 {
		draw_line(i32(x_start), y, i32(x_end), y, color)
		x_start += inv_slope_1
		x_end += inv_slope_2
	}
}

///////////////////////////////////////////////////////////////////////////////////
// Draw a filled triangle wih a flat top
///////////////////////////////////////////////////////////////////////////////////
//
//          (x0,y0)---(x1,y1)
//             \       /
//              \     /
//               \   /
//                \ /
//              (x2,y2)
//
///////////////////////////////////////////////////////////////////////////////////
fill_flat_top_triangle :: proc(x0, y0, x1, y1, x2, y2: i32, color: u32) {
	// find the two slopes (two triangle legs)
	inv_slope_1 := f32(x2 - x0) / f32(y2 - y0)
	inv_slope_2 := f32(x2 - x1) / f32(y2 - y1)

	// Start x_start and x_end from the top vertex (x2)
	x_start := f32(x2)
	x_end := f32(x2)

	// loop all the scanlines from top to bottom
	for y := y2; y >= y0; y -= 1 {
		draw_line(i32(x_start), y, i32(x_end), y, color)
		x_start -= inv_slope_1
		x_end -= inv_slope_2
	}
}

///////////////////////////////////////////////////////////////////////////////////
// Draw a filled rectanble with the flat top/flat bottom method
// We split the original triangle in two, half flat-bottom and half flat-top
///////////////////////////////////////////////////////////////////////////////////
//
//            (x0,y0)
//              / \
//               /   \
//              /     \
//             /       \
//          (x1,y1)---(Mx,My)
//             \         \
//                \       \
//                   \     \
//                      \   \
//                         \ \
//                            \
//                          (x2,y2)
//
///////////////////////////////////////////////////////////////////////////////////
draw_filled_triangle :: proc(x0, y0, x1, y1, x2, y2: i32, color: u32) {
	x0 := x0
	x1 := x1
	x2 := x2
	y0 := y0
	y1 := y1
	y2 := y2

	if y0 > y1 {
		y1, y0 = y0, y1
		x1, x0 = x0, x1
	}
	if y1 > y2 {
		y2, y1 = y1, y2
		x2, x1 = x1, x2
	}
	if y0 > y1 {
		y1, y0 = y0, y1
		x1, x0 = x0, x1
	}

	if (y1 == y2) {
		fill_flat_bottom_triangle(x0, y0, x1, y1, x2, y2, color)
	} else if (y0 == y1) {
		fill_flat_top_triangle(x0, y0, x1, y1, x2, y2, color)
	} else {
		Mx := i32(f32(x0) + (f32(x2 - x0) * f32(y1 - y0)) / f32(y2 - y0))
		My := y1
		fill_flat_bottom_triangle(x0, y0, x1, y1, Mx, My, color)
		fill_flat_top_triangle(x1, y1, i32(Mx), My, x2, y2, color)
	}
}
