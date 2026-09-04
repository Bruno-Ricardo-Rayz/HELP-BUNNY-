extends Node

# --- SISTEMA DE VIDA ---
var vida_maxima: int = 3
var vida_atual: int = 3

# --- VARIÁVEIS GLOBAIS DE SALVAMENTO ---
var fase_atual: String = "res://LEVEL 1.tscn"
var pos_checkpoint: Vector2 = Vector2.ZERO
var tem_checkpoint: bool = false

func _ready():
	resetar_vida()

func resetar_vida():
	vida_atual = vida_maxima

func salvar_checkpoint(fase: String, posicao: Vector2):
	fase_atual = fase
	pos_checkpoint = posicao
	tem_checkpoint = true
	print("Checkpoint salvo em: ", fase, " na posição ", posicao)

func resetar_checkpoint_para_nova_fase(nova_fase: String):
	fase_atual = nova_fase
	pos_checkpoint = Vector2.ZERO
	tem_checkpoint = false
	resetar_vida()
