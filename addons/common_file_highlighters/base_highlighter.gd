@tool
extends EditorSyntaxHighlighter

const C_SYMBOL := Color(1, 1, 1, 0.33)
const C_COMMENT := Color(1, 1, 1, 0.33)
const C_STRING := Color.WHITE
const C_INT := Color.PALE_GREEN
const C_FLOAT := Color.PALE_GREEN
const C_BOOL := Color.PALE_GOLDENROD
const C_NULL := Color.MEDIUM_PURPLE
const C_SECTION := Color.LIGHT_SLATE_GRAY

var _out: Dictionary
var _line: int
var text: String

func c(index: int, color: Color):
	_out[index] = { color=color }

func c_bold(index: int, color: Color):
	_out[index] = { color=Color(color, 4.0) }

func begins_with(off: int, s: String) -> bool:
	for i in len(s):
		if off+i >= len(text) or text[off+i] != s[i]:
			return false
	return true

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	text = get_text_edit().get_line(line)
	_line = line
	_out = {}
	_highlight()
	return _out

func _highlight():
	pass

func _open(d: Dictionary, tag: String):
	d[tag] = d.get(tag, 0) + 1

func _close(d: Dictionary, tag: String):
	if tag in d:
		d[tag] -= 1
		if d[tag] <= 0:
			d.erase(tag)

func _find_end(from: int, end: String) -> int:
	var tags := {}
	var i := from
	while i < len(text):
		if len(tags) == 0 and begins_with(i, end):
			return i
		var tag := text[i]
		match tag:
			"'", '"':
				if tag in tags:
					_close(tags, tag)
				else:
					_open(tags, tag)
			"{": _open(tags, "{")
			"}": _close(tags, "{")
			"[": _open(tags, "[")
			"]": _close(tags, "]")
		i += 1
	return -1

func _find_cap(from: int, caps := " .,") -> int:
	var tags := {}
	var i := from
	while i < len(text):
		var tag := text[i]
		if len(tags) == 0:
			if tag in caps:
				return i
			elif i == len(text)-1:
				return i+1
		match tag:
			"'", '"':
				if tag in tags:
					_close(tags, tag)
				else:
					_open(tags, tag)
			"{": _open(tags, "{")
			"}": _close(tags, "{")
			"[": _open(tags, "[")
			"]": _close(tags, "]")
		i += 1
	return -1
