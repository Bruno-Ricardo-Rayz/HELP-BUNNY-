extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -800.0

# Pega a gravidade configurada nas configurações do projeto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Aplica a gravidade se o personagem estiver no ar
	if not is_on_floor():
		velocity.y += gravity * delta

	# Pulo (usando a tecla Espaço por padrão)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimentação para os lados (Setas Esquerda/Direita ou A/D)
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Aplica o movimento na física do jogo
	move_and_slide()
