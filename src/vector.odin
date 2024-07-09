package renderer

import "core:math"

vec2_t :: distinct [2]f32
vec3_t :: distinct [3]f32
vec4_t :: distinct [4]f32

vec2_dot :: proc(a: vec2_t, b: vec2_t) -> f32 {
	i := a * b
	return i.x + i.y
}

vec2_length :: proc(v: vec2_t) -> f32 {
	return math.sqrt(vec2_dot(v, v))
}

vec2_normalize :: proc(v: vec2_t) -> vec2_t {
	return v / vec2_length(v)
}

vec3_dot :: proc(a: vec3_t, b: vec3_t) -> f32 {
	i := a * b
	return i.x + i.y + i.z
}

vec3_length :: proc(v: vec3_t) -> f32 {
	return math.sqrt(vec3_dot(v, v))
}

vec3_cross :: proc(a: vec3_t, b: vec3_t) -> vec3_t {
	i := a.yzx * b.zxy
	j := a.zxy * b.yzx
	return i - j
}

vec3_normalize :: proc(v: vec3_t) -> vec3_t {
	return v / vec3_length(v)
}

vec3_rotate_x :: proc(v: vec3_t, angle: f32) -> vec3_t {
	return vec3_t {
		v.x,
		v.y * math.cos(angle) - v.z * math.sin(angle),
		v.y * math.sin(angle) + v.z * math.cos(angle),
	}
}

vec3_rotate_y :: proc(v: vec3_t, angle: f32) -> vec3_t {
	return vec3_t {
		v.x * math.cos(angle) - v.z * math.sin(angle),
		v.y,
		v.x * math.sin(angle) + v.z * math.cos(angle),
	}
}

vec3_rotate_z :: proc(v: vec3_t, angle: f32) -> vec3_t {
	return vec3_t {
		v.x * math.cos(angle) - v.y * math.sin(angle),
		v.x * math.sin(angle) + v.y * math.cos(angle),
		v.z,
	}
}

vec4_from_vec3 :: proc(v: vec3_t) -> vec4_t {
	return vec4_t{v.x, v.y, v.z, 1.0}
}

vec3_from_vec4 :: proc(v: vec4_t) -> vec3_t {
	return vec3_t{v.x, v.y, v.z}
}
