extends Resource
class_name GameStats

@export var ball_spawn_timer: float = 0.15

@export var ball_radius: float = 15.0
@export var ball_speed: float = 1500.0
@export var ball_color: Color = Color.WHITE

@export var shot_line_color: Color = Color.WHITE
@export var shot_line_width: float = 5.0
@export var shot_line_antialiased: bool = true

@export var block_columns:  int = 8
@export var block_spacing: int = 2

@export var launch_point_global_position: Vector2 = Vector2(540, 1705)
