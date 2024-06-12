class_name ComputeSum extends RefCounted

const ELEM_SIZE: int = 4
const CPU_MAX: int = 2 ** 11
const WG_SIZE: int = 64

var rd: RenderingDevice
var shader: RID
var n_elem: int
var ub_pba: PackedByteArray
var ub: RID
var sb0: RID
var sb1: RID
var uniform_set0: RID
var uniform_set1: RID
var pipeline: RID


func init_arr_i32(list: PackedByteArray) -> void:
	var shader_file: RDShaderFile = load("res://sum.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	
	n_elem = list.size() / ELEM_SIZE
	
	ub_pba = PackedByteArray()
	ub_pba.resize(16)
	ub_pba.encode_u32(0, n_elem)
	ub = rd.uniform_buffer_create(16, ub_pba)
	var rdu_ub := RDUniform.new()
	rdu_ub.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	rdu_ub.binding = 0
	rdu_ub.add_id(ub)
	
	sb0 = rd.storage_buffer_create(list.size(), list)
	var rdu_sb0 := RDUniform.new()
	rdu_sb0.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	rdu_sb0.binding = 1
	rdu_sb0.add_id(sb0)
	
	sb1 = rd.storage_buffer_create(list.size() / WG_SIZE)
	var rdu_sb1 := RDUniform.new()
	rdu_sb1.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	rdu_sb1.binding = 2
	rdu_sb1.add_id(sb1)
	
	uniform_set0 = rd.uniform_set_create([rdu_ub, rdu_sb0, rdu_sb1], shader, 0)
	
	rdu_sb0 = RDUniform.new()
	rdu_sb0.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	rdu_sb0.binding = 2
	rdu_sb0.add_id(sb0)
	
	rdu_sb1 = RDUniform.new()
	rdu_sb1.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	rdu_sb1.binding = 1
	rdu_sb1.add_id(sb1)
	
	uniform_set1 = rd.uniform_set_create([rdu_ub, rdu_sb1, rdu_sb0], shader, 0)
	
	pipeline = rd.compute_pipeline_create(shader)


func set_arr_i32(list: PackedByteArray) -> void:
	n_elem = list.size() / ELEM_SIZE
	ub_pba.encode_u32(0, n_elem)
	rd.buffer_update(ub, 0, 16, ub_pba)
	rd.buffer_update(sb0, 0, list.size(), list)


func compute_v1() -> int:
	while maxi(CPU_MAX, WG_SIZE * 8 - 1) < n_elem:
		var compute_list: int = rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set0, 0)
		var n_wg: int = maxi(1, n_elem / (WG_SIZE * 8))
		rd.compute_list_dispatch(compute_list, n_wg, 1, 1)
		rd.compute_list_end()
		
		rd.submit()
		n_elem /= 8
		ub_pba.encode_u32(0, n_elem)
		rd.sync()
		rd.buffer_update(ub, 0, 16, ub_pba)
	
	var pba: PackedByteArray = rd.buffer_get_data(sb0, 0, ELEM_SIZE * n_elem)
	var result: int = 0
	for i in n_elem:
		result += pba.decode_s32(ELEM_SIZE * i)
	
	return result


func compute_v2() -> int:
	var even: bool = true
	while maxi(CPU_MAX, WG_SIZE * 2) <= n_elem:
		var compute_list: int = rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		var us: RID = uniform_set0 if even else uniform_set1
		rd.compute_list_bind_uniform_set(compute_list, us, 0)
		var n_wg: int = n_elem / (2 * WG_SIZE)
		rd.compute_list_dispatch(compute_list, n_wg, 1, 1)
		rd.compute_list_end()
		
		rd.submit()
		n_elem /= WG_SIZE * 2
		even = !even
		rd.sync()
	
	var sb_out: RID = sb0 if even else sb1
	var pba: PackedByteArray = rd.buffer_get_data(sb_out, 0, ELEM_SIZE * n_elem)
	var result: int = 0
	for i in n_elem:
		result += pba.decode_s32(ELEM_SIZE * i)
	
	return result


func compute_once() -> PackedInt32Array:
	var compute_list: int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set0, 0)
	rd.compute_list_dispatch(compute_list, maxi(1, n_elem/2/WG_SIZE), 1, 1)
	rd.compute_list_end()
	
	rd.submit()
	rd.sync()
	var data: PackedByteArray = rd.buffer_get_data(sb1, 0, ELEM_SIZE * WG_SIZE * 2)
	return data.to_int32_array()


func cleanup() -> void:
	if rd == null:
		return
	
	rd.free_rid(pipeline)
	pipeline = RID()
	
	rd.free_rid(uniform_set1)
	uniform_set1 = RID()
	
	uniform_set0 = RID()
	rd.free_rid(uniform_set0)
	
	rd.free_rid(sb1)
	sb1 = RID()
	
	rd.free_rid(sb0)
	sb0 = RID()
	
	rd.free_rid(ub)
	ub = RID()
	
	rd.free_rid(shader)
	shader = RID()
	
	rd = null
