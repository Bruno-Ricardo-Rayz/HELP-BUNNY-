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
		get_tree().change_scene_to_file(caminho_ou_acao)
	elif caminho_ou_acao == "reiniciar":
		get_tree().reload_current_scene()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	await fade_in()
