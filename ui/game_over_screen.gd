extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# 隐藏的时候，希望Godot不要管我的输入事件
	hide()
	set_process_input(false)

func _input(event: InputEvent) -> void:
	# 阻止事件传播
	get_window().set_input_as_handled()
	
	if animation_player.is_playing():
		return
	
	if (
		event is InputEventKey or
		event is InputEventMouseButton or 
		event is InputEventJoypadButton
	):
		if event.is_pressed() and not event.is_echo():
			if Game.has_save():
				Game.load_game()
			else:
				Game.back_to_title()

func show_game_over() -> void:
	show()
	set_process_input(true)
	animation_player.play("enter")
