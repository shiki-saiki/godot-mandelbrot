class_name CptFractal extends RefCounted

var rd: RenderingDevice
var shader: RID
var ub_pba: PackedByteArray
var ub: RID
var texture: RID
var uniform_set: RID
var pipeline: RID
var fractal: Fractal


func init(fractal: Fractal) -> void:
	self.fractal = fractal
	
	var shader_file: RDShaderFile = load("res://fractal.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	
	ub_pba = PackedByteArray()
	ub_pba.resize(32)
	ub = rd.uniform_buffer_create(ub_pba.size(), ub_pba)
	var rdu_ub := RDUniform.new()
	rdu_ub.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	rdu_ub.binding = 0
	rdu_ub.add_id(ub)
	
	var format := RDTextureFormat.new()
	format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UINT
	format.width = 512
	format.height = 512
	format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT \
		| RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT \
		| RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	
	texture = rd.texture_create(format, RDTextureView.new())
	
	var rdu_tex := RDUniform.new()
	rdu_tex.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	rdu_tex.binding = 1
	rdu_tex.add_id(texture)
	
	uniform_set = rd.uniform_set_create([rdu_ub, rdu_tex], shader, 0)
	
	pipeline = rd.compute_pipeline_create(shader)


func compute() -> void:
	ub_pba.encode_float(0, Time.get_ticks_msec() / 1000.0)
	ub_pba.encode_float(8, fractal.uf_position_x)
	ub_pba.encode_float(12, fractal.uf_position_y)
	ub_pba.encode_float(16, fractal.uf_scale)
	ub_pba.encode_s32(20, fractal.uf_iteration)
	rd.buffer_update(ub, 0, ub_pba.size(), ub_pba)
	
	var compute_list: int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 512, 512, 1)
	rd.compute_list_end()
	
	rd.submit()
	rd.sync()


func get_image_data() -> PackedByteArray:
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
	
	rd.free_rid(ub)
	ub = RID()
	
	rd.free_rid(shader)
	shader = RID()
	
	rd = null
	
	fractal = null
