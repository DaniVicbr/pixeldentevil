extends CharacterBody2D

# ===============================================================
#                   VARIÁVEIS DE MOVIMENTO E GRÁFICOS
# ===============================================================
@export var speed = 600.0
@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Guarda o lado atual do personagem (true = esquerda)
var facing_left = false

# ===============================================================
#                   VARIÁVEIS DE TIRO
# ===============================================================
const BulletScene: PackedScene = preload("res://Scenes/bullet.tscn")
@export var fire_rate = 0.5
var can_shoot = true

# ===============================================================
#                   CICLO DE VIDA
# ===============================================================

func _physics_process(_delta):
	var input_direction = get_input()
	velocity = input_direction * speed
	move_and_slide()

	# Atualiza lado virado apenas com base na tecla apertada
	if Input.is_action_pressed("left"):
		facing_left = true
	elif Input.is_action_pressed("right"):
		facing_left = false

	_animated_sprite.flip_h = facing_left

func _process(_delta):
	handle_animation()

	if Input.is_action_just_pressed("shootMouse") and can_shoot:
		shoot()

# ===============================================================
#                   FUNÇÕES DE JOGABILIDADE
# ===============================================================

func get_input() -> Vector2:
	var input_direction = Vector2.ZERO

	if Input.is_action_pressed("right"):
		input_direction.x += 1
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
	#if Input.is_action_pressed("up"):
		#input_direction.y -= 1
	#if Input.is_action_pressed("down"):
		#input_direction.y += 1

	return input_direction.normalized()

func handle_animation():
	if not _animated_sprite:
		return

	if velocity.length() > 0.1:
		_animated_sprite.play("run")
	else:
		_animated_sprite.play("idle")

func shoot():
	var new_bullet_root = BulletScene.instantiate()
	if new_bullet_root == null:
		print("ERRO: O arquivo da bala não foi carregado!")
		return

	var bullet_instance: Area2D = new_bullet_root.get_node("Area2D")
	if bullet_instance == null:
		print("ERRO: Não encontrei o nó Area2D dentro da cena de bala!")
		return

	new_bullet_root.global_position = global_position

	# Direção baseada no lado virado (não em velocity)
	bullet_instance.direction = Vector2.LEFT if facing_left else Vector2.RIGHT


	get_parent().add_child(new_bullet_root)

	can_shoot = false
	get_tree().create_timer(fire_rate).timeout.connect(reset_cooldown)

func reset_cooldown():
	can_shoot = true
