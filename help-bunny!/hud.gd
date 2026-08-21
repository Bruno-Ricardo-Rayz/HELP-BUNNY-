extends CanvasLayer

# --- CONFIGURAÇÕES DA FASE ---
@export var tempo_restante: float = 60.0
@export var tamanho_minimo_palavra: int = 2
@export var tamanho_maximo_palavra: int = 5
var lista_palavras: Array[String] = []

# --- CONTROLE DA PENALIDADE PROGRESSIVA ---
var penalidade_atual: int = 5
const PENALIDADE_MAXIMA: int = 10

# --- VARIÁVEIS DE JOGO ---
var palavra_atual: String = ""
var texto_digitado: String = ""
var ativo: bool = false

# --- REFERÊNCIAS ---
@export var player_node: NodePath
var player: CharacterBody2D

@onready var richtext_palavra: RichTextLabel = $RichTextLabelPalavra
@onready var label_tempo: Label = $LabelTempo
@onready var label_feedback: Label = $LabelFeedback

func _ready():
	if player_node:
		player = get_node(player_node)
	label_feedback.text = ""
	richtext_palavra.text = ""
	
	carregar_dicionario("res://dicionario.txt")
	atualizar_ui_tempo()

func carregar_dicionario(caminho_arquivo: String):
	if FileAccess.file_exists(caminho_arquivo):
		var arquivo = FileAccess.open(caminho_arquivo, FileAccess.READ)
		while not arquivo.eof_reached():
			var linha = arquivo.get_line().strip_edges().to_upper()
			var tamanho = linha.length()
			
			if tamanho >= tamanho_minimo_palavra:
				if tamanho_maximo_palavra <= 0 or tamanho <= tamanho_maximo_palavra:
					lista_palavras.append(linha)
					
		arquivo.close()
		print("Dicionário carregado! Palavras de ", tamanho_minimo_palavra, " a ", tamanho_maximo_palavra, " letras: ", lista_palavras.size())
	else:
		print("ERRO: Arquivo 'dicionario.txt' não foi encontrado!")
		lista_palavras = ["BOM", "PULAR", "GATO", "CASA"]

func _process(delta):
	if tempo_restante > 0:
		tempo_restante -= delta
		atualizar_ui_tempo()
		if tempo_restante <= 0:
			tempo_restante = 0
			game_over_tempo()

	if player and player.estado_atual == player.Estado.PARADO and not ativo:
		iniciar_desafio_digitacao()

# --- CAPTURA DE TECLAS (ESC E DIGITAÇÃO COM ACENTO) ---
func _unhandled_input(event):
	# Pressionar ESC volta imediatamente para o Menu Principal
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://menu.tscn")
		return

	if not ativo:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.unicode != 0:
			var letra_digitada = String.chr(event.unicode).to_upper()
			if letra_digitada != "":
				validar_letra(letra_digitada)

func validar_letra(letra_digitada: String):
	var proxima_letra = palavra_atual[texto_digitado.length()]
	
	if letra_digitada == proxima_letra:
		texto_digitado += letra_digitada
		atualizar_ui_palavra()
		
		if texto_digitado == palavra_atual:
			sucesso_palavra()
	else:
		aplicar_erro()

func aplicar_erro():
	tempo_restante -= penalidade_atual
	if tempo_restante < 0:
		tempo_restante = 0
		
	exibir_feedback("- " + str(penalidade_atual) + "s!", Color.RED)
	
	if penalidade_atual < PENALIDADE_MAXIMA:
		penalidade_atual += 1
		
	gerar_nova_palavra()

func sucesso_palavra():
	ativo = false
	richtext_palavra.text = ""
	
	# Bonificação de 3 segundos
	tempo_restante += 3.0
	atualizar_ui_tempo()
	
	exibir_feedback("+3s! MUITO BEM!", Color.GREEN)
	
	penalidade_atual = 5
	
	if player:
		player.pular_obstaculo_automaticamente()

func iniciar_desafio_digitacao():
	ativo = true
	penalidade_atual = 5
	gerar_nova_palavra()

func gerar_nova_palavra():
	texto_digitado = ""
	if lista_palavras.size() > 0:
		palavra_atual = lista_palavras.pick_random()
	atualizar_ui_palavra()

# --- MONTAGEM DA PALAVRA COM QUADRADINHOS E CORES ---
func atualizar_ui_palavra():
	var texto_bbcode = "[center]"
	
	for i in range(palavra_atual.length()):
		var letra = palavra_atual[i]
		
		if i < texto_digitado.length():
			texto_bbcode += "[bgcolor=#33333388][color=#888888] " + letra + " [/color][/bgcolor] "
		else:
			texto_bbcode += "[bgcolor=#DDDDDD][color=#000000] " + letra + " [/color][/bgcolor] "
			
	texto_bbcode += "[/center]"
	richtext_palavra.text = texto_bbcode

func atualizar_ui_tempo():
	label_tempo.text = "Tempo: " + str(ceil(tempo_restante)) + "s"

func exibir_feedback(texto: String, cor: Color):
	label_feedback.text = texto
	label_feedback.modulate = cor
	
	var tween = create_tween()
	tween.tween_property(label_feedback, "modulate:a", 0.0, 1.0).from(1.0)

func game_over_tempo():
	ativo = false
	richtext_palavra.text = "[center][color=red]TEMPO ESGOTADO![/color][/center]"
