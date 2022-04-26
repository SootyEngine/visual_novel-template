@tool
extends RefCounted
class_name Grammar

const THEM := 	{m="him",		s="her",		n="them"}
const THEIR := 	{m="his", 		s="her", 		n="their"}
const THEYRE := {m="he's", 		s="she's", 		n="they're"}
const THEY := 	{m="he", 		s="she", 		n="they"}
const THEYD := 	{m="he'd", 		s="she'd", 		n="they'd"}
const THEYLL := {m="he'll", 	s="she'll", 	n="they'll"}
const PRONOUNS := { they=THEY, theyll=THEYLL, theyd=THEYD, theyre=THEYRE, their=THEIR, them=THEM }

static func get_pronoun(id: String, gender: String) -> String:
	var lower := id.to_lower()
	if lower in PRONOUNS:
		if gender in PRONOUNS[lower]:
			if UString.is_capitalized(id):
				return PRONOUNS[lower][gender].capitalized()
			else:
				return PRONOUNS[lower][gender]
	return id
