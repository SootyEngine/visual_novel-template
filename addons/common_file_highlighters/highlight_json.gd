@tool
extends "res://addons/common_file_highlighters/base_highlighter.gd"

const C_NORMAL := Color.WHITE
const C_KEY := Color.DEEP_SKY_BLUE

func _get_name() -> String:
	return "JSON"

func _highlight():
	var in_string := false
	var i := 0
	while i < len(text):
		match text[i]:
			":":
				c(i, C_SYMBOL)
				var end := _find_end(i+1, ',')
				if end != -1:
					var inner := text.substr(i+1, end-i-1).strip_edges()
					# bool
					if inner in ["true", "false"]:
						c_bold(i+1, C_BOOL)
					# null
					elif inner == "null":
						c_bold(i+1, C_NULL)
					# string
					elif inner.begins_with('"') and inner.ends_with('"'):
						c(i+2, C_SYMBOL)
						# color hex code
						if inner[1] == "#":
							c(i+4, Color(inner.substr(1, len(inner)-2)))
						else:
							c(i+3, C_STRING)
						c(end-1, C_SYMBOL)
					# int
					elif inner.is_valid_int():
						c(i+1, C_INT)
					# float
					elif inner.is_valid_float():
						c(i+1, C_FLOAT)
					else:
						prints(inner)
					# trailing comma
					c(end, C_SYMBOL)
					i = end
					
			"{", "}", "[", "]", ",":
				if not in_string:
					c(i, C_SYMBOL)
			
			'"':
				# open quotes
				c(i, C_SYMBOL)
				
				# is key head?
				var end := _find_end(i+1, '"')
				if end != -1:
					var inner := text.substr(i+1, end-i-2)
					if end+1 < len(text) and text[end+1] == ":":
						c(i+1, C_SECTION)
						# close quotes
						c(i+2+len(inner), C_SYMBOL)
						i = end-1
						continue
		
		i += 1
