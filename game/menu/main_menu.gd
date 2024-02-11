extends CenterContainer
class_name MainMenu

@onready var continue_button = $Menu/CenterContainer/VBoxContainer/ContinueButton


func _ready():
    if not Utils.has_save_file():
        continue_button.disabled = true


func start_game():
    get_tree().change_scene_to_file("res://game/game.tscn")


func _on_continue_button_pressed():
    # Load the save and then
    start_game()


func _on_new_game_button_pressed():
    start_game()


func _on_option_button_pressed():
    get_tree().change_scene_to_file("res://game/menu/options.tscn")
