extends Node

@onready var icon: TextureButton = get_node("icon")
@onready var info: RichTextLabel2 = get_node("Button/info")

var contact: Variant

func _ready() -> void:
	icon.pressed.connect(_pressed)
	$Button.pressed.connect(_pressed)

func _pressed():
	print("Pressed contact ", contact)

func set_data(character: Variant):# Character):
	contact = character
	var text := "[120]%s[]\n%s\n[dim;75]%s" % ["Smith", "John", "1-341-513-4325"]
	info.set_bbcode(text)
