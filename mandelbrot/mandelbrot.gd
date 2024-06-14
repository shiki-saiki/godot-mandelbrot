extends Node2D

var uf_position: Vector2 = Vector2.ZERO
var uf_scale: Vector2 = Vector2(2.0, 2.0) # radius
var uf_iteration: int = 40

var window_size: Vector2i = Vector2i(800, 450)
var view_size: Vector2 = Vector2(4.0, 4.0 * (16.0 / 9.0))
var zoom_factor: float = 2.0 / (window_size.x / 2.0)


func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, window_size.x, window_size.y), Color.BLACK)


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("zoom_out"):
		zoom_factor *= 1.0 + 1.0/64.0
	if Input.is_action_pressed("zoom_in"):
		zoom_factor /= 1.0 + 1.0/64.0
	if Input.is_action_pressed("iter+"):
		if uf_iteration < 200:
			uf_iteration += 1
	if Input.is_action_pressed("iter-"):
		if 0 < uf_iteration:
			uf_iteration -= 1
	
	var window: Window = get_window()
	window_size = window.size
	view_size = window_size * zoom_factor
	
	if Input.is_action_pressed("ui_left"):
		uf_position.x -= view_size.x / 128.0
	if Input.is_action_pressed("ui_right"):
		uf_position.x += view_size.x / 128.0
	if Input.is_action_pressed("ui_up"):
		uf_position.y -= view_size.x / 128.0
	if Input.is_action_pressed("ui_down"):
		uf_position.y += view_size.x / 128.0
	
	material.set_shader_parameter("iteration", uf_iteration)
	material.set_shader_parameter("position", uf_position)
	material.set_shader_parameter("scale", window_size * zoom_factor)
	
	queue_redraw()


func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					pass
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					zoom_factor *= 1.0 + 1.0/32.0
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					zoom_factor /= 1.0 + 1.0/32.0
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			print("move: ", event.relative)
			var d: Vector2 = event.relative * Vector2(-1.0, -1.0)
			uf_position += d * zoom_factor
