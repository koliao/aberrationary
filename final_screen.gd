extends Node2D

var horizontal_space : int = 2
var vertical_space : int = 2
var font_scale : int = 1
var game_over = false

var cursor_pos = Vector2(0, 0)

var completed_poems = []

func reset():
	game_over = false
	$TimerDraw.reset()

func _ready():
	$Poem.text = self.generate_poem()
	pass

func _process(delta):
	var t = 0.003 * Time.get_ticks_msec()
	var a = abs(sin(t))
	$Submit.color.a = a

	queue_redraw()

func _input(event):
	if event is InputEventKey:
		var enter_key = event.keycode == KEY_ENTER
		var pressed = event.pressed and not event.echo
		if(enter_key and pressed):
			self._submit_poem()

var adjectives = [
	# Colors
	"RED",
	"ORANGE",
	"YELLOW",
	"GREEN",
	"BLUE",
	"PURPLE",

	# Sizes
	"BIG",
	"LARGE",
	"SMALL",
	"TINY",
	"SHORT",
	"TALL",

	# Speed
	"FAST",
	"SLOW",

	# Others
	"EVIL",
	"KIND",
	"LAZY",
]

var animals = [
	# Animals
	"FROG",
	"CAT",
	"DOG",
	"FISH",
	"BIRD",
	"COW",
	"PIG",
	"DUCK",
	"GOAT",
	"SHEEP",
	"TURTLE",
	"RABBIT",
	"MONKEY",
	"CRAB",
	"SHARK",
	"OCTOPUS",
	"ANT",
	"BEE",
	"MOUSE",
	"ELEPHANT",
	"OWL",
	"FOX",
	"WIZARD",
]

var verbs = [
	"JUMPED",
	"SWIMMED",
	"SLEPT",
	"TALKED",
	"STARTED A BAND",
	"PLAYED",
	"WROTE A SONG",
	"WROTE A COOKING BOOK",
	"MADE A GAME IN TWO WEEKS",
	"DESTROYED THE UNIVERSE",
	"OPENED A JAR",
	"CREATED A NEW RELIGION ABOUT FROGS",
	"WAITED TO THE END OF TIME",
	"SUGGESTED SOME POEMS",
	"DECIDED TO CHILL",
]

func generate_poem() -> String:
	var adjective = self.adjectives.pick_random()
	var animal = self.animals.pick_random()
	var verb1 = self.verbs.pick_random()
	var verb2 = self.verbs.pick_random()
	while(verb2 == verb1):
		verb2 = self.verbs.pick_random()

	var poem = "THE " + adjective + " " + animal + " " + verb1 + " AND " + verb2

	return poem

func _submit_poem():
	self.completed_poems.append( {
		"poem": $Poem.text,
		"accuracy": self._string_accuracy($Poem.text, $Input.current_string) 
	} )
	$Poem.text = self.generate_poem()
	$Input.current_string = ""


func _string_accuracy(original_poem: String, typed_poem: String):
	return 1.0 - float(self._string_distance(original_poem, typed_poem)) / float(original_poem.length())

# Levenstein distance 
func _string_distance(a: String, b: String):
	var v0 = []
	var v1 = []

	for i in range(b.length() + 1):
		v0.append(0)
		v1.append(0)

	for i in range(b.length()):
		v0[i] = i

	for i in range(a.length() - 1):
		v1[0] = i + 1

		for j in range(b.length()):
			var deletion_cost = v0[j + 1] + 1
			var insertion_cost = v1[j] + 1
			var subst_cost = 0
			if a[i] == b[j]:
				subst_cost = v0[j]
			else:
				subst_cost = v0[j] + 1

			v1[j + 1] = min(deletion_cost, insertion_cost, subst_cost)

		var tmp = v0.duplicate()
		v0 = v1.duplicate()
		v1 = tmp.duplicate()

	return v0[b.length()]


func _on_timer_draw_out_of_time():
	self.game_over = true
