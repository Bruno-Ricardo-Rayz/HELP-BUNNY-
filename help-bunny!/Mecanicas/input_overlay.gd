extends Control

var cor_solta: Color = Color(0.15, 0.15, 0.2, 0.7)       # Cinza escuro
var cor_pressionada: Color = Color(0.0, 0.6, 1.0, 0.9)  # Azul brilhante

# Dicionário que guarda [ColorRect] -> Tecla
var teclas_map: Dictionary = {}

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_mapear_nos_teclas(self)

func _mapear_nos_teclas(no_atual: Node) -> void:
	for filho in no_atual.get_children():
		if filho is ColorRect:
			var nome_no = filho.name.to_upper()
			
			_arredondar_quadrado(filho)
			
			if nome_no in ["Ç", "CCEDILLA", "CEDILLA"]:
				var codigo_cedilha = OS.find_keycode_from_string("Ç")
				if codigo_cedilha == KEY_NONE:
					codigo_cedilha = OS.find_keycode_from_string("SEMICOLON")
				teclas_map[filho] = codigo_cedilha
			
			elif nome_no in ["ESPACO", "ESPAÇO", "SPACE"]:
				teclas_map[filho] = KEY_SPACE
			
			elif nome_no.length() == 1:
				var codigo_key = OS.find_keycode_from_string(nome_no)
				if codigo_key != KEY_NONE:
					teclas_map[filho] = codigo_key
		
		if filho.get_child_count() > 0:
			_mapear_nos_teclas(filho)

func _arredondar_quadrado(rect: ColorRect) -> void:
	rect.color = Color(0, 0, 0, 0)
	
	var style = StyleBoxFlat.new()
	style.bg_color = cor_solta
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	
	rect.set_meta("stylebox", style)
	
	if not rect.has_node("FundoArredondado"):
		var panel = Panel.new()
		panel.name = "FundoArredondado"
		panel.show_behind_parent = true
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.set_anchors_preset(PRESET_FULL_RECT)
		panel.add_theme_stylebox_override("panel", style)
		rect.add_child(panel)

func _process(_delta: float) -> void:
	for rect in teclas_map.keys():
		var tecla = teclas_map[rect]
		if rect.has_node("FundoArredondado"):
			var panel = rect.get_node("FundoArredondado") as Panel
			var style = rect.get_meta("stylebox") as StyleBoxFlat
			
			if style:
				if Input.is_physical_key_pressed(tecla):
					style.bg_color = cor_pressionada
				else:
					style.bg_color = cor_solta
				panel.add_theme_stylebox_override("panel", style)
