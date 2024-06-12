class_name Fractal extends Node2D

var uf_position_x: float = 0.0
var uf_position_y: float = 0.0
var uf_scale: float = 2.0
var uf_iteration: int = 40

var cpt_fr: CptFractal
var texture: ImageTexture
var image: Image


func init(cpt: Compute) -> void:
	cpt_fr = cpt.new_cpt_fractal()
	cpt_fr.init(self)
	image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(image)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			cpt_fr.cleanup()
			cpt_fr = null


func _draw() -> void:
	draw_texture(texture, Vector2())


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("key_a"):
		uf_scale *= 1.0 + 1.0/32.0
	if Input.is_action_pressed("key_s"):
		uf_scale /= 1.0 + 1.0/32.0
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
	
	var t0: int = Time.get_ticks_usec()
	cpt_fr.compute()
	var t1: int = Time.get_ticks_usec()
	if get_tree().get_frame() % 30 == 0:
		print("Time: ", t1 - t0)
	
	image.set_data(512, 512, false, Image.FORMAT_RGBA8, cpt_fr.get_image_data())
	texture.update(image)
	queue_redraw()
