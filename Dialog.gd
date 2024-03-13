extends Node2D

# TODO: preload or class
enum GameMode {
	DRAW,
	ERASE,
	POWER
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_ui(game_state):
	self._set_title("ROUND %s" % game_state.current_round + "/15")
	self._set_task(game_state)
		
func _set_title(title: String):
	$Title.text = title
	
func _set_task(game_state):
	if(game_state.current_mode == GameMode.DRAW):
		$Task.text = "- DRAW %s PIXELS" % game_state.task_total_count
		$Progress.text = "%s / %s" % [game_state.task_current_count, game_state.task_total_count]
	if(game_state.current_mode == GameMode.ERASE):
		$Task.text = "- ERASE %s PIXELS" % game_state.task_total_count
		$Progress.text = "%s / %s" % [game_state.task_current_count, game_state.task_total_count]		
	if(game_state.current_mode == GameMode.POWER):
		$Task.text = "- %s" % game_state.current_power().description
		$Progress.text = ""
