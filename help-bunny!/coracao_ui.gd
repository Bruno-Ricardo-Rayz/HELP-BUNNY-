extends AnimatedSprite2D

var visivel_atual: bool = true

func _ready():
	play("idle")
	scale = Vector2(2.5, 2.5) # Aumenta o tamanho base do coração no jogo

func sumir_com_efeito():
	if not visivel_atual:
		return
	visivel_atual = false
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(3.5, 3.5), 0.15)
	tween.tween_property(self, "modulate", Color(2.0, 0.2, 0.2, 1.0), 0.15)
	
	await tween.finished
	
	var tween_sumir = create_tween().set_parallel(true)
	tween_sumir.tween_property(self, "scale", Vector2(0.0, 0.0), 0.2)
	tween_sumir.tween_property(self, "modulate:a", 0.0, 0.2)
	
	await tween_sumir.finished
	visible = false

func aparecer_com_efeito():
	visible = true
	visivel_atual = true
	scale = Vector2(0.0, 0.0)
	modulate = Color(0.2, 2.0, 0.2, 0.0)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(3.2, 3.2), 0.2)
	tween.tween_property(self, "modulate", Color(0.2, 2.0, 0.2, 1.0), 0.2)
	
	await tween.finished
	
	var tween_reset = create_tween().set_parallel(true)
	tween_reset.tween_property(self, "scale", Vector2(2.5, 2.5), 0.15)
	tween_reset.tween_property(self, "modulate", Color.WHITE, 0.15)
