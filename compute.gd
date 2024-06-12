class_name Compute extends Object

var rd: RenderingDevice = null


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			cleanup()


func init() -> bool:
	rd = RenderingServer.create_local_rendering_device()
	if rd == null:
		OS.alert("Couldn't create local RenderingDevice\nGPU: %s" % RenderingServer.get_video_adapter_name())
		return false
	
	print("UNIFORM_SET_MAX: ", rd.limit_get(RenderingDevice.LIMIT_MAX_BOUND_UNIFORM_SETS))
	print("UNIFORM_BUFFER_SIZE_MAX: ", rd.limit_get(RenderingDevice.LIMIT_MAX_UNIFORM_BUFFER_SIZE))
	print("COMPUTE_WORKGROUP_SIZE_MAX: ", Vector3i(
		rd.limit_get(RenderingDevice.LIMIT_MAX_COMPUTE_WORKGROUP_SIZE_X),
		rd.limit_get(RenderingDevice.LIMIT_MAX_COMPUTE_WORKGROUP_SIZE_Y),
		rd.limit_get(RenderingDevice.LIMIT_MAX_COMPUTE_WORKGROUP_SIZE_Z)
	))
	print("COMPUTE_WORKGROUP_COUNT_MAX: ", Vector3i(
		rd.limit_get(RenderingDevice.LIMIT_MAX_COMPUTE_WORKGROUP_COUNT_X),
		rd.limit_get(RenderingDevice.LIMIT_MAX_COMPUTE_WORKGROUP_COUNT_Y),
		rd.limit_get(RenderingDevice.LIMIT_MAX_COMPUTE_WORKGROUP_COUNT_Z)
	))
	
	return true


func new_compute_sum() -> ComputeSum:
	var cs := ComputeSum.new()
	cs.rd = rd
	return cs


func new_compute_wave() -> ComputeWave:
	var cw := ComputeWave.new()
	cw.rd = rd
	return cw


func new_cpt_fractal() -> CptFractal:
	var cpt := CptFractal.new()
	cpt.rd = rd
	return cpt


func cleanup() -> void:
	rd.free()
	rd = null
