extends CharacterBody2D
class_name Ball

enum MovementState {
    MOVING,
    RETURNING
}

@export var return_proximity: float = 15.0

var direction: Vector2 = Vector2.ZERO
var move_state: MovementState = MovementState.MOVING

@onready var game_stats: GameStats = Utils.get_game_stats()
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready():
    velocity = Vector2.ZERO
    collision_shape_2d.shape.radius = game_stats.ball_radius


func fire(dir: Vector2):
    move_state = MovementState.MOVING
    direction = dir


func drop():
    move_state = MovementState.MOVING
    direction = Vector2.DOWN


func _physics_process(delta):
    if direction == Vector2.ZERO:
        return

    match move_state:
        MovementState.MOVING:
            move_ball(delta)
        MovementState.RETURNING:
            return_ball(delta)

    queue_redraw()


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

        var reflect = collision.get_remainder().bounce(collision.get_normal())
        direction = direction.bounce(collision.get_normal())
        move_and_collide(reflect)


func _draw():
    draw_circle(Vector2.ZERO, game_stats.ball_radius, game_stats.ball_color)
