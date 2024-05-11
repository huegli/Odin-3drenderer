package renderer

import "core:math"

vec2_t :: [2]f32
vec3_t :: [3]f32

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

