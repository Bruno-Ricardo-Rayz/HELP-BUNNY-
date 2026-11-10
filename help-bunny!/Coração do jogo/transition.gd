
extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim: AnimationPlayer = $AnimationPlayer

var transicao_em_andamento: bool = false

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


func ir_para(caminho_ou_acao) -> void:
	if transicao_em_andamento:
		return
	
	transicao_em_andamento = true
	
	await fade_out()
	
	if caminho_ou_acao is String and caminho_ou_acao != "reiniciar":
		
		var caminho_final: String = caminho_ou_acao
		
		# Verifica se o recurso existe no projeto exportado
		if not ResourceLoader.exists(caminho_final, "PackedScene"):
			
			var nome_arquivo = caminho_final.get_file()
			var caminho_alternativo = "res://Coração do jogo/" + nome_arquivo
			
			if ResourceLoader.exists(caminho_alternativo, "PackedScene"):
				caminho_final = caminho_alternativo
			else:
				push_error("Cena não encontrada ou não exportada: " + caminho_ou_acao)
				await fade_in()
				transicao_em_andamento = false
				return
		
		print("Carregando cena: ", caminho_final)
		
		var erro = get_tree().change_scene_to_file(caminho_final)
		
		if erro != OK:
			push_error("Erro ao carregar cena: " + caminho_final)
			await fade_in()
			transicao_em_andamento = false
			return
	
	elif caminho_ou_acao == "reiniciar":
		get_tree().reload_current_scene()
		return
	
	else:
		push_error("Ação de transição inválida.")
		await fade_in()
		transicao_em_andamento = false
		return
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	await fade_in()
	transicao_em_andamento = false
