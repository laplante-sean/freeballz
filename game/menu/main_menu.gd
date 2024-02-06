extends CenterContainer
class_name MainMenu


func start_game():
    get_tree().change_scene_to_file("res://game/game.tscn")


func _on_continue_button_pressed():
    # Load the save and then
    start_game()


func _on_new_game_button_pressed():
    start_game()


func _on_option_button_pressed():
    print("Options not implemented")
