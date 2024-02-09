extends Resource
class_name GameStats

@export var ball_spawn_timer: float = 0.15

@export var ball_radius: float = 15.0
@export var ball_speed: float = 1500.0
@export var ball_color: Color = Color.WHITE

@export var pickup_ball_animation_radius_start = 20.0
@export var pickup_ball_animation_radius_end = 30.0
@export var pickup_ball_animation_duration = 0.75
@export var pickup_ball_collision_radius = 45.0

@export var coin_radius: float = 20.0
@export var coin_color: Color = Color.GOLD
@export var coin_line_thickness: float = 5.0

@export var shot_line_color: Color = Color.WHITE
@export var shot_line_width: float = 5.0
@export var shot_line_antialiased: bool = true

@export var block_columns:  int = 8
@export var block_spacing: int = 2
@export var block_hue_start: float = 130.0
@export var block_saturation: float = 50.0
@export var block_brightness: float = 45.0

@export var launch_point_global_position: Vector2 = Vector2(540, 1705)
