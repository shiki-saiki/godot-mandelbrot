extends Node2D

var uf_position_x: float = 0.0
var uf_position_y: float = 0.0
var uf_scale: float = 2.0
var uf_iteration: int = 40


func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 900.0, 900.0), Color.BLACK)


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("zoom_out"):
		uf_scale *= 1.0 + 1.0/64.0
	if Input.is_action_pressed("zoom_in"):
		uf_scale /= 1.0 + 1.0/64.0
	if Input.is_action_pressed("iter+"):
		if uf_iteration < 200:
			uf_iteration += 1
	if Input.is_action_pressed("iter-"):
		if 0 < uf_iteration:
			uf_iteration -= 1
	
	if Input.is_action_pressed("ui_left"):
		uf_position_x -= uf_scale/64.0
	if Input.is_action_pressed("ui_right"):
		uf_position_x += uf_scale/64.0
	if Input.is_action_pressed("ui_up"):
		uf_position_y -= uf_scale/64.0
	if Input.is_action_pressed("ui_down"):
		uf_position_y += uf_scale/64.0
	
	material.set_shader_parameter("iteration", uf_iteration)
	material.set_shader_parameter("position", Vector2(uf_position_x, uf_position_y))
	material.set_shader_parameter("scale", uf_scale)
	
	queue_redraw()
