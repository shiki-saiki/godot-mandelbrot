extends Node2D

func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 300.0, 300.0), Color.BLACK)


func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_A):
		position.x -= 2.0
	if Input.is_key_pressed(KEY_D):
		position.x += 2.0
	if Input.is_key_pressed(KEY_W):
		position.y -= 2.0
	if Input.is_key_pressed(KEY_S):
		position.y += 2.0


#func _unhandled_input(event) -> void:
	#if event is InputEventKey:
		#match event.keycode:
			#KEY_A:
				#if event.pressed:
					#position.x -= 2.0
			#KEY_D:
				#if event.pressed:
					#position.x += 2.0
			#KEY_W:
				#if event.pressed:
					#position.y -= 2.0
			#KEY_S:
				#if event.pressed:
					#position.y += 2.0
