extends Node
class_name GoBackHandlerComponent

# A component to handle the back button so that we go back
# to the correct scene/menu/etc. from wherever we are
var go_back_map = {
    "res://game/menu/main_menu.tscn": "close",
    "res://game/menu/options.tscn": "res://game/menu/main_menu.tscn",
    "res://game/game.tscn": "res://game/menu/main_menu.tscn"
}

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_WM_GO_BACK_REQUEST:
            # Handle Android back button
            _on_go_back()


func _on_go_back():
    var path = get_tree().current_scene.scene_file_path
    if not path in go_back_map:
        push_warning(path, " is not in the go_back_map - quit instead.")
        get_tree().quit(0)

    if path == "res://game/game.tscn":
        #Utils.save_game()
        pass

    var dest = go_back_map[path]
    if dest == "close":
        get_tree().quite(0)
    else:
        get_tree().change_scene_to_file(dest)
