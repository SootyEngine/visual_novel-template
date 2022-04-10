extends Control

@export var _rtl_from: NodePath = ""
@export var _rtl_text: NodePath = ""
@export var _indicator: NodePath = ""
@onready var rtl_from: RichTextLabel2 = get_node(_rtl_from) 
@onready var rtl_text: RichTextAnimation = get_node(_rtl_text) 
@onready var indicator: TextureRect = get_node(_indicator)

# optional choice menu this caption will use
@export var _option_menu: NodePath = ""
@onready var option_menu: Node = get_node(_option_menu)
var _waiting_for_option := false

@export var enabled := true
var hiding := false
var _can_skip := true
var _tween: Tween
var _tween_indicator: Tween

var show_indicator := false:
	set = set_show_indicator

func _init() -> void:
	add_to_group("@.show_caption")
	add_to_group("@.hide_caption")
	add_to_group("@.captioner")

func _ready() -> void:
	rtl_from.clear()
	rtl_text.clear()
	rtl_text.faded_in.connect(set_show_indicator.bind(true))
	rtl_text.started.connect(set_show_indicator.bind(false))
	Dialogue.reloaded.connect(_hide)
	Dialogue.ended.connect(_hide)
	visible = false
	indicator.modulate.a = 0.0

func captioner(id: String):
	enabled = name == id

func show_caption(from: String, text: String, kwargs := {}):
	if enabled:
		Dialogue.wait(self)
		_delay_action()
		
		if not visible:
			visible = true
			var tween := _create_tween()
			tween.tween_property(self, "modulate:a", 1.0, 0.25).from(0.0)
			tween.tween_callback(_show_line.bind(from, text, kwargs))
		else:
			_stop_tween()
			_show_line(from, text, kwargs)

func hide_caption():
	if enabled:
		Dialogue.unwait(self)

func _delay_action():
	_can_skip = false
	get_tree().create_timer(0.25).timeout.connect(set.bind("_can_skip", true))

func set_show_indicator(s):
	if show_indicator != s:
		if s and _waiting_for_option:
			return
		
		show_indicator = s
		if _tween_indicator:
			_tween_indicator.stop()
		_tween_indicator = get_tree().create_tween()
		if s:
			# wait half a second before showing indicator
			_tween_indicator.tween_interval(0.5)
			_tween_indicator.tween_property(indicator, "modulate:a", 1.0, 0.125)
		else:
			_tween_indicator.tween_property(indicator, "modulate:a", 0.0, 0.0125)

func _show_line(from: String, text: String, line := {}):
	if from:
		rtl_from.visible = true
		rtl_from.set_bbcode(from)
		rtl_text.set_bbcode(text)
		rtl_text.fade_out = false
	else:
		rtl_from.visible = false
		rtl_text.set_bbcode(text)
		rtl_text.fade_out = false
	
	# show choices?
	_waiting_for_option = false
	indicator.visible = true
	if Dialogue.line_has_options(line):
		if option_menu:
			option_menu.set_options(line)
			if option_menu.has_options():
				_waiting_for_option = true
				indicator.visible = false
				rtl_text.faded_in.connect(option_menu._show_options, CONNECT_ONESHOT)
				Dialogue.selected.connect(_option_selected, CONNECT_ONESHOT)
		else:
			push_error("No options_menu setup %s." % [name])
	
	# skip text animation?
	if Settings.instant_text_animation:
		rtl_text.advance()

func _option_selected(option: String):
	_waiting_for_option = false
	indicator.visible = true
	Dialogue.unwait(self)

# wait a period of time before hiding, in case there will be another text showing up.
func _hide_eventually():
	if visible:
		var tw := _create_tween()
		tw.tween_interval(0.25)
		tw.tween_callback(_hide)
		tw.tween_property(self, "modulate:a", 0.0, 0.25)
		tw.tween_callback(set_visible.bind(false))
		rtl_text.fade_out = true

func _hide():
	visible = false
	show_indicator = false
	rtl_from.clear()
	rtl_text.clear()

func _stop_tween():
	if _tween:
		_tween.stop()

func _create_tween() -> Tween:
	if _tween:
		_tween.stop()
	_tween = get_tree().create_tween()
	_tween.bind_node(self)
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return _tween
