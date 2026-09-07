extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Esconde o CanvasLayer no início para não bloquear a tela nem cliques do mouse
	visible = false
	if color_rect:
		color_rect.modulate.a = 0.0

func fade_out() -> void:
	visible = true
	if anim and anim.has_animation("fade_out"):
		anim.play("fade_out")
		await anim.animation_finished
	else:
		# Fallback usando Tween
		var t = create_tween()
		t.tween_property(color_rect, "modulate:a", 1.0, 0.5)
		await t.finished

func fade_in() -> void:
	if anim and anim.has_animation("fade_in"):
		anim.play("fade_in")
		await anim.animation_finished
	else:
		var t = create_tween()
		t.tween_property(color_rect, "modulate:a", 0.0, 0.5)
		await t.finished
	
	# Oculta novamente após terminar o fade in
	visible = false

# --- FUNÇÃO UNIVERSAL PARA NAVEGAÇÃO ---
func ir_para(caminho_ou_acao) -> void:
	# 1. Executa a tela ficando preta/escura
	await fade_out()
	
	# 2. Faz a troca da cena
	if caminho_ou_acao is String and caminho_ou_acao != "reiniciar":
		get_tree().change_scene_to_file(caminho_ou_acao)
	elif caminho_ou_acao == "reiniciar":
		get_tree().reload_current_scene()
	
	# 3. Aguarda o sinal 'node_added' ou 2 frames processados para garantir que a nova cena carregou na árvore
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 4. Executa a revelação da nova cena
	await fade_in()
