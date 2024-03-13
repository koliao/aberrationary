extends Node2D

var letters = []
var Letter = load("res://Letter.tscn")

var selected_letters = []
var used_powers = []

enum GameMode {
	DRAW,
	ERASE,
	POWER,
	BONUS_INFO,
	FINAL,
	GAME_OVER,
}

enum Power {
	SWAP,
	COPY,
	MIRROR,
	FLIP,
	ERASE,
	FILL,
	PROTECT,
	RESET,
}

var current_round : int = 0
var current_mode : GameMode = GameMode.DRAW
var task_current_count: int = 0
var task_total_count: int = 5
var selected_power = null

func _ready():
	self._pass_round()
	$Dialog.set_ui(self)
	$EditBox.calculate_intersection($LettersContainer.selected_letters, self.current_mode)

func _process(delta):
	$Dialog.set_ui(self)
	$LettersContainer.can_select_letters = false

	if(self.current_mode == GameMode.POWER):
		$LettersContainer.can_select_letters = true
		self.current_power().handler.call()

	elif(self.current_mode == GameMode.BONUS_INFO):
		if(Input.is_action_just_pressed("enter")):
			self.current_mode = GameMode.FINAL
			$BonusRoundInfo.hide()
			$FinalScreen.reset()
			$FinalScreen.show()

	elif(self.current_mode == GameMode.FINAL):
		if($FinalScreen.game_over):
			self.current_mode = GameMode.GAME_OVER
			$FinalScreen.hide()
			var readability = self._total_readability()
			var accuracy = self._total_accuracy()
			var total = readability + accuracy

			$GameOver.readability = readability
			$GameOver.accuracy = accuracy
			$GameOver.total = total

			$GameOver.show()


	elif(self.current_mode == GameMode.GAME_OVER):
		if($GameOver.restart):
			GlobalFont.reset()
			$GameOver.hide()
			var main_nodes = get_tree().get_nodes_in_group("MainScreen")
			for node in main_nodes:
				node.show()

			self.current_round = 0
			self.current_mode = GameMode.DRAW
			self.task_current_count = 0
			self.task_total_count = 5
			self.selected_power = null

			self._pass_round()
			$Dialog.set_ui(self)
			$EditBox.calculate_intersection($LettersContainer.selected_letters, self.current_mode)


func _pass_round():
	self.task_current_count = 0
	self.task_total_count = 5
	match(self.current_round):
		0, 1, 5, 6, 10, 11:
			self.current_mode = GameMode.DRAW
			self.current_round += 1
			$EditBox.show()
			$LettersContainer.select_letters(self.current_round)
			$EditBox.calculate_intersection($LettersContainer.selected_letters, self.current_mode)
		2, 3, 7, 8, 12, 13:
			self.current_mode = GameMode.ERASE
			self.current_round += 1
			$EditBox.show()
			$LettersContainer.select_letters(self.current_round)
			$EditBox.calculate_intersection($LettersContainer.selected_letters, self.current_mode)
		4, 9, 14:
			# TODO: Maybe use available powers and remove from there
			self.selected_power = self.powers.pick_random().type
			var last_round = self.current_round == 14
			var last_round_banned_power = last_round and self.selected_power == Power.PROTECT
			while(self.selected_power in self.used_powers or last_round_banned_power):
				self.selected_power = self.powers.pick_random().type
				last_round_banned_power = last_round and self.selected_power == Power.PROTECT
			self.used_powers.append(self.selected_power)
			self.current_mode = GameMode.POWER
			self.current_round += 1
			$LettersContainer.set_power_round()
			$EditBox.hide()
		15:
			self.current_mode = GameMode.BONUS_INFO
			$BonusRoundInfo.show()
			var main_nodes = get_tree().get_nodes_in_group("MainScreen")
			for node in main_nodes:
				node.hide()
	
var powers = [
	{
		"type": Power.SWAP,
		"description": "SWAP 2 LETTERS",
		"handler": self._swap_letters_handler,
	},
	{
		"type": Power.COPY,
		"description": "COPY 1 LETTER TO ANOTHER ONE",
		"handler": self._copy_letter_handler,
	},
	{
		"type": Power.MIRROR,
		"description": "SELECT A LETTER TO MIRROR HORIZONTALLY",
		"handler": self._mirror_letter_handler,
	},
	{
		"type": Power.FLIP,
		"description": "SELECT A LETTER TO FLIP VERTICALLY",
		"handler": self._flip_letter_handler,
	},
	{
		"type": Power.ERASE,
		"description": "SELECT A LETTER TO ERASE",
		"handler": self._erase_letter_handler,
	},
	{
		"type": Power.FILL,
		"description": "SELECT A LETTER TO FILL",
		"handler": self._fill_letter_handler,
	},
	{
		"type": Power.PROTECT,
		"description": "SELECT A LETTER TO PROTECT",
		"handler": self._protect_letter_handler,
	},
	{
		"type": Power.RESET,
		"description": "SELECT A LETTER TO RESET",
		"handler": self._reset_letter_handler,
	}
]

func current_power():
	var power = self.powers.filter(
		func (p):
			return p.type == self.selected_power
	)

	if(power.size() > 0):
		return power[0]

func _swap_letters_handler():
	var selected_count = $LettersContainer.selected_letters.size()
	if(selected_count == 2):
		var a = $LettersContainer.selected_letters[0]
		var b = $LettersContainer.selected_letters[1]
		GlobalFont.swap_letters(a, b)

		self._pass_round()
	pass

func _copy_letter_handler():
	var selected_count = $LettersContainer.selected_letters.size()
	if(selected_count == 2):
		var src = $LettersContainer.selected_letters[0]
		var target = $LettersContainer.selected_letters[1]
		GlobalFont.copy_letter(src, target)

		self._pass_round()
	pass

func _mirror_letter_handler():
	var selected_count = $LettersContainer.selected_letters.size()
	if(selected_count == 1):
		var letter = $LettersContainer.selected_letters[0]
		GlobalFont.mirror_letter(letter)

		self._pass_round()
	pass

func _flip_letter_handler():
	var selected_count = $LettersContainer.selected_letters.size()
	if(selected_count == 1):
		var letter = $LettersContainer.selected_letters[0]
		GlobalFont.flip_letter(letter)

		self._pass_round()
	pass

func _erase_letter_handler():
	var selected_count = $LettersContainer.selected_letters.size()
	if(selected_count == 1):
		var letter = $LettersContainer.selected_letters[0]
		GlobalFont.erase_letter(letter)
		self._pass_round()
	pass

func _fill_letter_handler():
	var selected_count = $LettersContainer.selected_letters.size()
	if(selected_count == 1):
		var letter = $LettersContainer.selected_letters[0]
		GlobalFont.fill_letter(letter)

		self._pass_round()
	pass

func _protect_letter_handler():
	var selected_count = $LettersContainer.selected_letters.size()
	if(selected_count == 1):
		var letter = $LettersContainer.selected_letters[0]
		GlobalFont.protect_letter(letter)

		self._pass_round()
	pass

func _reset_letter_handler():
	var selected_count = $LettersContainer.selected_letters.size()
	if(selected_count == 1):
		var letter = $LettersContainer.selected_letters[0]
		GlobalFont.reset_letter(letter)

		self._pass_round()
	pass


func _on_edit_box_pixel_erased(x, y):
	$LettersContainer.on_edit_box_pixel_erased(x, y)
	self.task_current_count += 1
	
	if(self.task_current_count >= self.task_total_count):
		$Dialog.set_ui(self)
		self._pass_round()

func _on_edit_box_pixel_drawn(x, y):
	$LettersContainer.on_edit_box_pixel_drawn(x, y)
	self.task_current_count += 1
	
	if(self.task_current_count >= self.task_total_count):
		$Dialog.set_ui(self)
		self._pass_round()

func _total_readability():
	var letter_symbols = [
		"A", "B", "C", "D", "E",
		"F", "G", "H", "I", "J",
		"K", "L", "M", "N", "O",
		"P", "Q", "R", "S", "T",
		"U", "V", "W", "X", "Y",
		"Z"
	]

	var sum = 0
	for symbol in letter_symbols:
		sum += GlobalFont.readability(symbol)

	return sum

func _total_accuracy():
	var sum = 0

	for poem in $FinalScreen.completed_poems:
		sum += poem.accuracy

	return sum
