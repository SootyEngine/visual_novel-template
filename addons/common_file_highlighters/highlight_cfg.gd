@tool
extends "res://addons/common_file_highlighters/base_highlighter.gd"

func _get_name() -> String:
	return "Config File"

func _highlight():
	var string_opened := false
	for i in len(text):
		match text[i]:
			";":
				if not string_opened:
					c(i, C_COMMENT)
					break
			
			"[", "]":
				if not string_opened:
					c(i, C_SYMBOL)
					c(i+1, C_SECTION)
			
			"=":
				c(i, C_SYMBOL)
				var prop := text.substr(i+1).strip_edges()
				# bool
				if prop in ["true", "false"]:
					c_bold(i+1, C_BOOL)
				
				# null
				elif prop == "null":
					c_bold(i+1, C_NULL)
				
				# string
				elif prop.begins_with('"'):
					# opening quote
					c(i+2, C_SYMBOL)
					var stripped := UString.unwrap(prop, '"')
					# Colorize html colors.
					if stripped.begins_with('#') and stripped.is_valid_html_color():
						c(i+3, Color(stripped))
					else:
						c(i+2, C_STRING)
					# closing quote
					c(i+2+len(stripped), C_SYMBOL)
				
				# is number
				else:
					c(i+1, C_INT)
			'"':
				string_opened = not string_opened
