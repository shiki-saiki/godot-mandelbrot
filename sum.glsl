#[compute]
#version 460

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

layout(binding = 0, std140) restrict uniform NElem {
    uint n_elem;
};

layout(binding = 1, std430) restrict buffer InputData {
    int data_i[];
};

layout(binding = 2, std430) restrict writeonly buffer OutputData {
    int data_o[];
};


void main() {
    //uint offset = n_elem >> 2U;
    //uint offset = n_elem * 4U;
    uint offset = gl_NumWorkGroups.x * (gl_WorkGroupSize.x / 8U);
    data_i[gl_GlobalInvocationID.x] += (
        data_i[gl_GlobalInvocationID.x + offset]
        + data_i[gl_GlobalInvocationID.x + offset * 2U]
        + data_i[gl_GlobalInvocationID.x + offset * 3U]
        + data_i[gl_GlobalInvocationID.x + offset * 4U]
        + data_i[gl_GlobalInvocationID.x + offset * 5U]
        + data_i[gl_GlobalInvocationID.x + offset * 6U]
        + data_i[gl_GlobalInvocationID.x + offset * 7U]);
}
/*
void main() {
    uint giid2 = gl_GlobalInvocationID.x * 2U;
    for (uint offset = 1U; offset <= gl_WorkGroupSize.x; offset *= 2U) {
        if (gl_LocalInvocationID.x % offset == 0U) {
            data_i[giid2] += data_i[giid2 + offset];
        }
        memoryBarrierBuffer();
        barrier();
    }
    if (gl_LocalInvocationID.x == 0U) {
        data_o[gl_WorkGroupID.x] = data_i[giid2];
    }
}
*/