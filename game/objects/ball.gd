extends CharacterBody2D
class_name Ball

enum MovementState {
    MOVING,
    RETURNING
}

@export var return_proximity: float = 15.0
@export var is_colletible: bool = false

var direction: Vector2 = Vector2.ZERO
var move_state: MovementState = MovementState.MOVING
var animated_radius = 0
var collectible_tween: Tween

@onready var game_stats: GameStats = Utils.get_game_stats()
@onready var player_stats: PlayerStats = Utils.get_player_stats()
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready():
    velocity = Vector2.ZERO
    collision_shape_2d.shape.radius = game_stats.ball_radius

    if is_colletible:
        setup_collectible_ball()


func setup_collectible_ball():
    # Make it collide on the pickup layer
    set_collision_layer_value(4, true)
    collision_shape_2d.shape.radius = game_stats.pickup_ball_collision_radius
    animated_radius = game_stats.pickup_ball_animation_radius_start

    # Create a tween to animate a circle in and out
    collectible_tween = get_tree().create_tween()
    collectible_tween.tween_property(
        self, "animated_radius",
        game_stats.pickup_ball_animation_radius_end,
        game_stats.pickup_ball_animation_duration
    )
    collectible_tween.chain().tween_property(
        self, "animated_radius",
        game_stats.pickup_ball_animation_radius_start,
        game_stats.pickup_ball_animation_duration
    )
    collectible_tween.set_loops()  # Loops forever


func fire(dir: Vector2):
    move_state = MovementState.MOVING
    direction = dir


func collect():
    is_colletible = false
    collision_shape_2d.shape.radius = game_stats.ball_radius
    set_collision_layer_value(4, false)
    drop()
    player_stats.balls += 1


func drop():
    move_state = MovementState.MOVING
    direction = Vector2.DOWN
    set_collision_mask_value(2, false)


func _physics_process(delta):
    queue_redraw()

    if direction == Vector2.ZERO:
        return

    match move_state:
        MovementState.MOVING:
            move_ball(delta)
        MovementState.RETURNING:
            return_ball(delta)


func return_ball(delta):
    direction = global_position.direction_to(game_stats.launch_point_global_position)
    velocity = direction * game_stats.ball_speed * delta
    position += velocity
    if global_position.distance_to(game_stats.launch_point_global_position) <= return_proximity:
        queue_free()


func move_ball(delta):
    velocity = direction * game_stats.ball_speed
    var collision = move_and_collide(velocity * delta) as KinematicCollision2D
    if collision:
        var collider = collision.get_collider()
        if collider is Block:
            collider.hit()
        if collider.is_in_group("GameFloor"):
            move_state = MovementState.RETURNING
            return
        if collider.has_method("collect"):
            collider.collect()
            return

        var reflect = collision.get_remainder().bounce(collision.get_normal())
        direction = direction.bounce(collision.get_normal())
        move_and_collide(reflect)


func _draw():
    draw_circle(Vector2.ZERO, game_stats.ball_radius, game_stats.ball_color)
    if is_colletible:
        draw_arc(Vector2.ZERO, animated_radius, 0, deg_to_rad(360), 100, game_stats.ball_color, 3.5, true)
