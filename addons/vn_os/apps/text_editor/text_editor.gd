extends OSApp

func get_app_name() -> String:
	return "TextEdit"

func set_data(data: Variant):
	var t: TextEdit = $MarginContainer/text
	t.get_menu().visibility_changed.connect(func(): t.get_menu().visible = false)
	t.set_text(str(data))
	# place caret at final line and column, as if the file was just written
	t.set_caret_line(t.get_line_count()-1)
	t.set_caret_column(len(t.get_line(t.get_line_count()-1)))
