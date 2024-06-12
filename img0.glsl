#[compute]
#version 460

const float PI = 3.141592653589793;


layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(binding = 0, std140) restrict uniform Time {
    float time;
};

layout(rgba8ui, binding = 1) restrict uniform uimage2D img;

void main() {
    ivec2 coords = ivec2(gl_GlobalInvocationID.xy);
    uint r = uint((sin(PI / 2.0 * time) * sin((float(coords.x) / 100.0) * PI) * sin((float(coords.y) / 100.0) * PI) + 1.0) / 2.0 * 255.0);
    uvec4 pixel = uvec4(r, r, r, 255);
    imageStore(img, coords, pixel);
}
