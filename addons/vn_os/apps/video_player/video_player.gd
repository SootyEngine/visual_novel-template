extends OSApp

@export var _player: NodePath
@onready var player: VideoStreamPlayer = get_node(_player)

@export var _slider: NodePath
@onready var slider: HSlider = get_node(_slider)

@export var _label_current: NodePath
@export var _label_left: NodePath
@onready var label_current: Label = get_node(_label_current)
@onready var label_left: Label = get_node(_label_left)

var finished := false
var video_length := 0.0
var update_ticker := 0.0

func get_app_name() -> String:
	return "Video Player"

func _ready() -> void:
	player.finished.connect(_finished)

func _finished():
	if not finished:
		finished = true
		slider.max_value = video_length
	player.play()

func _process(delta: float) -> void:
	update_ticker -= delta
	
	if not finished:
		video_length = player.stream_position
		slider.max_value = video_length
		slider.value = video_length * .5
	
	if finished and update_ticker <= 0.0:
		# update slider position
		var current_sec := player.stream_position
		slider.value = current_sec
		
		# left text: time that's past
		var min := current_sec / 60
		var sec := int(current_sec) % 60
		label_current.text = "%0d:%0d" % [min, sec]
		
		# right text: time left till complete
		var sec_left := video_length - current_sec
		min = sec_left / 60
		sec = int(sec_left) % 60
		label_left.text = "%0d:%0d" % [min, sec]
		
		# don't update for 0.25 seconds
		update_ticker = 0.25
		

func set_data(data: Variant):
	match (data as String).get_extension():
		"ogv":
			var stream := VideoStreamTheora.new()
			stream.set_file(data)
			player.stream = stream
			player.play()
			video_length = 0.0
		
		_:
			push_error("Can't play file %s." % data)
