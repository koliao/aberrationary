extends Node2D

@export var selected_letters : Array
var can_select_letters : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for letter in self.letters():
		if(letter.letter in self.selected_letters):
			letter.selected = true
		else:
			letter.selected = false
		
	var readability = self.hovered_readability()	
	if(readability):
		$CardSmall/Label.show()
		$CardSmall/Label.set_text(str(readability).pad_decimals(2))
	else:
		$CardSmall/Label.hide()
		
		

func letters() -> Array:
	return $Card.get_children()

func selected_letters_nodes() -> Array:
	return self.letters().filter(
		func(l): return l.letter in self.selected_letters
	)
	
func select_letters(round: int):
	var count = 0
	if(round < 5):
		count = 2
	elif(round < 10):
		count = 4
	elif(round < 15):
		count = 6
	self.selected_letters = []
	var letters = self.letters()
	
	for i in range(count):
		var random_letter = letters[randi() % letters.size()]
		# TODO: Save infinite loop chance
		while(random_letter.letter in self.selected_letters or GlobalFont.is_symbol_protected(random_letter.letter)):
			random_letter = letters[randi() % letters.size()]
		self.selected_letters.append(random_letter.letter)
	

func _hovered_letter():
	for letter in self.letters():
		if(letter.hovered):
			return letter

func hovered_readability():
	var hovered = self._hovered_letter()
	if(hovered):
		return hovered.readability()
	else:
		return null

func on_edit_box_pixel_drawn(x, y):
	for letter in self.letters():
		if(letter.letter in self.selected_letters):
			GlobalFont.draw_pixel(letter.letter, x, y)


func on_edit_box_pixel_erased(x, y):
	for letter in self.letters():
		if(letter.letter in self.selected_letters):
			GlobalFont.erase_pixel(letter.letter, x, y)
			
func on_edit_box_pixel_hovered(x, y):
	for letter in self.letters():
		if(letter.letter in self.selected_letters):
			letter.set_show_preview_pixel(x, y)

func letter_clicked(letter):
	if(self.can_select_letters):
		self.selected_letters.append(letter)

func set_power_round():
	self.selected_letters = []
