extends Control

@onready var password_input: LineEdit = $"VBoxContainer/MarginContainer/VBoxContainer/password_input"
@onready var message: Label = $"VBoxContainer/MarginContainer/VBoxContainer/message"
@onready var locked_message: Label = $"VBoxContainer/MarginContainer/VBoxContainer/locked"

func _ready() -> void:
	password_input.text_submitted.connect(_submitted)
	message.modulate.a = 0.0
	await get_tree().process_frame
	if get_parent().password == "":
		unlock()

func unlock():
	locked_message.text = "Unlocked"
	# TODO: play sound
	var t := get_tree().create_tween().set_parallel()
	t.tween_property(self, "modulate:a", 0.0, 0.5)
	t.tween_property(self, "position:y", -32.0, 0.5)
	t.chain().tween_callback(set_visible.bind(false))

func _submitted(text: String):
	if text == get_parent().password:
		unlock()
	
	else:
		var t := get_tree().create_tween()
		t.tween_property(message, "modulate:a", 1.0, 0.125).from(0.0)
		t.tween_method(_shake, 0.0, 1.0, 1.0)
		t.tween_callback(password_input.clear)
		t.tween_property(message, "modulate:a", 0.0, 0.5)

func _shake(t: float):
	var x = 1.0 - (abs(t - .5) * 2.0)
	x *= x
	password_input.position.x = sin(t * TAU * 4.0) * x * 16.0
