@tool
extends "res://addons/common_file_highlighters/base_highlighter.gd"

const C_TEXT := Color.WHITE
const C_KEY := Color.DEEP_SKY_BLUE
const C_PROPERTY := Color.DEEP_PINK

const C_CHECKBOX := Color.LIGHT_GREEN
const C_QUOTE := Color.LIGHT_CORAL
const C_CODE := Color.LIGHT_GREEN
const C_URL_TEXT := Color.NAVAJO_WHITE
const C_URL := Color.PLUM
const C_EMOJI := Color.LIGHT_GREEN
const C_AT := Color.LIGHT_GREEN
const C_TABLE_HEAD := Color.LIGHT_GREEN

func _get_name() -> String:
	return "Markdown"

func _highlight():
	var stripped := text.strip_edges()
	var clr := C_TEXT
	c(0, clr)
	
	if stripped == "":
		return
	
	# dividers
	if stripped in ["---", "***", "___", "- - -", "* * *", "_ _ _"]:
		c(0, C_SYMBOL)
		return
	
	var i := 0
	while i < len(text):
		match text[i]:
			# header
			"#":
				var end := text.find(" ", i)
				if end != -1:
					c(0, C_SYMBOL)
					c_bold(end+1, C_SECTION)
					i = end+1
			
			# strikethrough
			"~":
				if begins_with(i, "~~"):
					c(i, C_SYMBOL)
					c(i+2, C_TEXT)
					i += 2
			
			# markdown italics
			"_":
				c(i, C_SYMBOL)
				i += 1
				while i < len(text) and text[i] == "_":
					i += 1
				c(i, C_TEXT)
			
			# list
			"-", "+", "*":
				# list heads
				if i+1 < len(text) and text[i+1] == " ":
					# checkbox style
					if begins_with(i, "- [x]") or begins_with(i, "- [X]"):
						c(i, C_SYMBOL)
						c_bold(i+3, C_CHECKBOX)
						c(i+4, C_SYMBOL)
						c(i+5, C_TEXT)
						i += 5
					elif begins_with(i, "- [ ]"):
						c(i, C_SYMBOL)
						c(i+5, C_TEXT)
						i += 5
					else:
						c(i, C_SYMBOL)
						c(i+1, C_TEXT)
						i += 1
				
				elif text[i] == "*":
					c(i, C_SYMBOL)
					c(i+1, C_TEXT)
			
			"<":
				# html style comments
				if begins_with(i, "<!--"):
					c(i, C_SYMBOL)
					c(i+len("<!--"), C_COMMENT)
					i += len("<!--")
					var end := _find_end(i, "-->")
					if end != -1:
						c(end, C_SYMBOL)
						c(end+len("-->"), clr)
						i = end
				
				# html tags
				else:
					var end := _find_end(i+1, ">")
					if end != -1:
						c(i, C_SYMBOL)
						c(end+1, C_TEXT)
						i = end
			
			# blockquote
			">":
				c(i, C_SYMBOL)
				var end := _find_end(i+1, " ")
				if end != -1:
					c(end, C_QUOTE)
					clr = C_QUOTE
					i = end
			
			# tables
			"|":
				# TODO
				# alignment row
				if "|-" in text:
					c(i, C_SYMBOL)
				# header row
				elif _line==0 or not "|" in get_text_edit().get_line(_line-1):
					for j in len(text):
						match text[j]:
							"|":
								c(j, C_SYMBOL)
								c_bold(j+1, C_TABLE_HEAD)
				# normal row
				else:
					var row_clr = C_TEXT if _line%2==0 else C_TEXT.darkened(.33)
					for j in len(text):
						match text[j]:
							"|":
								c(j, C_SYMBOL)
								c(j+1, row_clr)
				break
			
			# links and images
			"[":
				var end := _find_end(i+1, "]")
				if end != -1:
					# images start with a ![
					if i > 0 and text[i-1] == "!":
						c(i-1, C_SYMBOL)
					else:
						c(i, C_SYMBOL)
					c(i+1, C_URL_TEXT)
					c(end, C_SYMBOL)
					if begins_with(end, "]("):
						var end2 := _find_end(end+2, ")")
						c(end, C_SYMBOL)
						c(end+2, C_URL)
						c(end2, C_SYMBOL)
						c(end2+1, C_TEXT)
						i = end2+1
			
			# inline code
			"`":
				c(i, C_SYMBOL)
				c(i+1, C_CODE)
				var end := _find_end(i+1, "`")
				if end != -1:
					c(end, C_SYMBOL)
					c(end+1, C_TEXT)
					i = end
			
			# emoji
			":":
				var end := _find_end(i+1, ":")
				if end != -1:
					c(i, C_EMOJI)
					c(end+1, C_TEXT)
					i = end
			
			# @mention
			"@":
				var end := _find_cap(i+1)
				if end != -1:
					c(i, C_AT)
					c(end, C_TEXT)
					i = end
			
			_:
				# list starting with number
				if text[i] in "1234567890":
					var end := _find_end(i+1, ". ")
					if end != -1:
						c(i, C_SYMBOL)
						c(end+2, C_TEXT)
						i = end
				
				# auto url
				elif begins_with(i, "https://"):
					c(i, C_URL)
					i += len("https://")
					var end := _find_cap(i, " ,")
					if end != -1:
						c(end, C_TEXT)
						i = end
		i += 1
