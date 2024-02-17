extends Resource
class_name GameStats

@export var ball_spawn_timer: float = 0.15

@export var ball_radius: float = 20.0
@export var ball_speed: float = 2000.0
@export var ball_color: Color = Color.WHITE
@export var fire_ball_color: Color = Color.RED
@export var fire_ball_speed: float = 3000.0

@export var pickup_ball_animation_radius_start: float = 25.0
@export var pickup_ball_animation_radius_end: float = 35.0
@export var pickup_ball_animation_duration: float = 0.75
@export var pickup_ball_collision_radius: float = 65.0

@export var coin_radius: float = 25.0
@export var coin_color: Color = Color.GOLD
@export var coin_line_thickness: float = 5.0
@export var coin_collision_radius: float = 65.0

@export var shot_line_color: Color = Color.WHITE
@export var shot_line_width: float = 8.0
@export var shot_line_antialiased: bool = true

@export var block_columns:  int = 7
@export var block_spacing: int = 2
@export var block_hue_start: float = 130.0
@export var block_saturation: float = 50.0
@export var block_brightness: float = 45.0
@export var bomb_block_color: Color = Color.ORANGE_RED
@export var bomb_block_laser_color: Color = Color.ORANGE_RED
@export var bomb_block_laser_max_width: float = 10.0

@export var launch_point_global_position: Vector2 = Vector2(540, 1720)


func save_stats():
    return {
        "ball_speed": ball_speed,
        "ball_color": var_to_str(ball_color),
        "fire_ball_color": var_to_str(fire_ball_color),
        "fire_ball_speed": fire_ball_speed,
        "coin_color": var_to_str(coin_color),
        "bomb_block_color": var_to_str(bomb_block_color),
        "shot_line_color": var_to_str(shot_line_color),
        "block_hue_start": block_hue_start,
        "block_saturation": block_saturation,
        "block_brightness": block_brightness,
        "bomb_block_laser_color": var_to_str(bomb_block_laser_color),
        "bomb_block_laser_max_width": bomb_block_laser_max_width
    }


func load_stats(obj: Dictionary):
    ball_speed = obj.ball_speed
    ball_color = str_to_var(obj.ball_color)
    fire_ball_color = str_to_var(obj.fire_ball_color)
    fire_ball_speed = obj.fire_ball_speed
    coin_color = str_to_var(obj.coin_color)
    shot_line_color = str_to_var(obj.shot_line_color)
    block_hue_start = obj.block_hue_start
    block_saturation = obj.block_saturation
    block_brightness = obj.block_brightness
    bomb_block_color = str_to_var(obj.bomb_block_color)
    bomb_block_laser_color = str_to_var(obj.bomb_block_laser_color)
    bomb_block_laser_max_width = obj.bomb_block_laser_max_width
