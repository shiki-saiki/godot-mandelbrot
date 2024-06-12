class_name ComputeWave extends RefCounted

var rd: RenderingDevice
var shader: RID
var bytes: PackedByteArray
var buffer: RID
var texture: RID
var uniform_set: RID
var pipeline: RID


func init():
	var shader_file: RDShaderFile = load("res://img0.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	
	bytes = PackedByteArray()
	bytes.resize(16)
	buffer = rd.uniform_buffer_create(bytes.size(), bytes)
	
	var uniform_buffer := RDUniform.new()
	uniform_buffer.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	uniform_buffer.binding = 0
	uniform_buffer.add_id(buffer)
	
	var format := RDTextureFormat.new()
	format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UINT
	format.width = 512
	format.height = 512
	format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT \
		| RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT \
		| RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	texture = rd.texture_create(format, RDTextureView.new())
	
	var uniform_tex := RDUniform.new()
	uniform_tex.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform_tex.binding = 1
	uniform_tex.add_id(texture)
	
	uniform_set = rd.uniform_set_create([uniform_buffer, uniform_tex], shader, 0)
	
	pipeline = rd.compute_pipeline_create(shader)


func compute() -> PackedByteArray:
	bytes.encode_float(0, Time.get_ticks_msec() * 0.001)
	rd.buffer_update(buffer, 0, bytes.size(), bytes)
	
	var compute_list: int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 512, 512, 1)
	rd.compute_list_end()
	
	rd.submit()
	rd.sync()
	
	return rd.texture_get_data(texture, 0)


func cleanup() -> void:
	if rd == null:
		return
	
	rd.free_rid(pipeline)
	pipeline = RID()
	
	rd.free_rid(uniform_set)
	uniform_set = RID()
	
	rd.free_rid(texture)
	texture = RID()
	
	rd.free_rid(buffer)
	buffer = RID()
	
	rd.free_rid(shader)
	shader = RID()
	
	rd = null
