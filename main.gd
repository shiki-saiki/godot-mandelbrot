extends Node2D

var compute: Compute
var fractal: Fractal


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SCENE_INSTANTIATED:
			compute = Compute.new()
			compute.init()
			
			fractal = $Fractal
			fractal.init(compute)


func _draw() -> void:
	pass


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("key_a"):
		pass
	var t0: int = Time.get_ticks_usec()
	#var sum: PackedInt32Array = cpt_sum.compute_once()
	var t1: int = Time.get_ticks_usec()
