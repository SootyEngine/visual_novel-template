@tool
extends Control

@export var texture: Texture:
	set(t):
		texture = t
		if icon:
			icon.set_texture(t)

@export var file_path: String = "":
	set(s):
		file_path = s
		_update_label()

@export var file_name_from_file := true:
	set(t):
		file_name_from_file = t
		_update_label()

@export var file_name: String:
	set(t):
		file_name = t
		_update_label()

@export var selected := false:
	set(s):
		selected = s
		if label:
			if selected:
				label.autowrap_mode = Label.AUTOWRAP_WORD_SMART
				label.text_overrun_behavior = Label.OVERRUN_NO_TRIMMING
			else:
				label.autowrap_mode = Label.AUTOWRAP_OFF
				label.text_overrun_behavior = Label.OVERRUN_TRIM_ELLIPSIS
		visible = false
		visible = true
		update()

@export_range(0.0, 8.0) var icon_blur := 0.0:
	set(b):
		icon_blur = b
		if not icon:
			icon = get_node(_icon)
		if icon_blur > 0:
			if not icon.material:
				icon.material = ShaderMaterial.new()
				icon.material.shader = load("res://addons/sim_os/icon_blur.gdshader")
				icon.texture_filter = TEXTURE_FILTER_NEAREST_WITH_MIPMAPS if icon_blur_pixely else TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			icon.material.set_shader_param("blur", icon_blur)
		elif icon_blur == 0 and icon.material:
			icon.material = null

@export var icon_blur_pixely := false:
	set(b):
		icon_blur_pixely = b
		if not icon:
			icon = get_node(_icon)
		icon.texture_filter = TEXTURE_FILTER_NEAREST_WITH_MIPMAPS if icon_blur_pixely else TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

@export var _icon: NodePath
@onready var icon: TextureRect = get_node(_icon)
@export var _label: NodePath
@onready var label: Label = get_node(_label)

func _ready() -> void:
	icon.set_texture(texture)
	_update_label()

func _update_label():
	label = get_node(_label)
	if label:
		if file_name_from_file:
			var fname := file_path.rsplit("/", true, 1)[-1]
			
			# turns "my_file" into "My File"
			if not "." in fname:
				fname = fname.capitalize()
			
			# turns "game.exe" into "Game"
			elif fname.ends_with(".exe"):
				fname = fname.rsplit(".", true, 1)[0].capitalize()
			
			label.set_text(fname)
		
		else:
			label.set_text(file_name)

func _draw() -> void:
	if selected:
		draw_rect(Rect2(Vector2.ZERO, $items.size), Color(0,0,1,0.25), true)

func set_data(file: Variant):
	pass
