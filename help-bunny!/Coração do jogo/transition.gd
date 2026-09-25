extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	visible = false
	if color_rect:
		color_rect.modulate.a = 0.0
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out() -> void:
	visible = true
	if color_rect:
		color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		
	if anim and anim.has_animation("fade_out"):
		anim.play("fade_out")
		await anim.animation_finished
	else:
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
	
	if color_rect:
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

# --- FUNÇÃO UNIVERSAL PARA NAVEGAÇÃO ---
func ir_para(caminho_ou_acao) -> void:
	await fade_out()
	
	if caminho_ou_acao is String and caminho_ou_acao != "reiniciar":
		var caminho_final: String = caminho_ou_acao
		
		# Se o arquivo não existir no caminho passado, tenta procurar dentro da pasta 'Coração do jogo'
		if not FileAccess.file_exists(caminho_final):
			var nome_arquivo = caminho_final.get_file() # Pega apenas o nome ex: "creditos.tscn"
			var caminho_alternativo = "res://Coração do jogo/" + nome_arquivo
			
			if FileAccess.file_exists(caminho_alternativo):
				caminho_final = caminho_alternativo
		
		# Tenta carregar a cena com o caminho corrigido
		var erro = get_tree().change_scene_to_file(caminho_final)
		if erro != OK:
			push_error("Transition Error: Não foi possível carregar a cena em: " + caminho_final)
			
	elif caminho_ou_acao == "reiniciar":
		get_tree().reload_current_scene()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	await fade_in()
