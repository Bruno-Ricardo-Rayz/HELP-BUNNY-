extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	# Toda vez que qualquer cena carrega, garante que a transição fica invisível
	if color_rect:
		color_rect.modulate.a = 0.0

func fade_out() -> void:
	if anim and anim.has_animation("fade_out"):
		anim.play("fade_out")
		await anim.animation_finished
	else:
		# Fallback com Tween caso o AnimationPlayer falhe
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

# --- FUNÇÃO UNIVERSAL PARA NAVEGAÇÃO ---
func ir_para(caminho_ou_acao) -> void:
	await fade_out()
	
	if caminho_ou_acao is String and caminho_ou_acao != "reiniciar":
		get_tree().change_scene_to_file(caminho_ou_acao)
	elif caminho_ou_acao == "reiniciar":
		get_tree().reload_current_scene()
		
	# Espera 1 frame para garantir que a nova cena carregou
	await get_tree().process_frame
	await fade_in()
