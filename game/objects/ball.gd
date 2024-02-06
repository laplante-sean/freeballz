extends CharacterBody2D
class_name Ball

@export var speed = 1500.0
@export var ball_radius = 15.0
@export var ball_color = Color.WHITE

var direction: Vector2 = Vector2.ZERO

@onready var collision_shape_2d = $CollisionShape2D


func _ready():
    velocity = Vector2.ZERO
    collision_shape_2d.shape.radius = ball_radius


func fire(dir: Vector2):
    direction = dir


func _physics_process(delta):
    velocity = direction * speed

    var collision = move_and_collide(velocity * delta) as KinematicCollision2D
    if collision:
        var collider = collision.get_collider()
        var reflect = collision.get_remainder().bounce(collision.get_normal())
        direction = direction.bounce(collision.get_normal())
        move_and_collide(reflect)
        if collider is Block:
            collider.hit()

    queue_redraw()


func _draw():
    draw_circle(Vector2.ZERO, ball_radius, ball_color)
