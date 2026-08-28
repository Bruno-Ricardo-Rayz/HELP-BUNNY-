extends Node2D

# Arraste o arquivo 'projectile.tscn' aqui no Inspetor da Godot
@export var cena_projetil: PackedScene 

# Lista de projéteis desta fase. Exemplo no Inspetor: ["normal", "fogo", "fogo"]
@export var sequencia_projeteis: Array[String] = ["normal"]
@export var embaralhar_ordem: bool = false
@export var tempo_entre_spawns: float = 8.0

@onready var timer: Timer = Timer.new()
var indice_atual: int = 0

func _ready():
	add_to_group("spawner")
	
	if embaralhar_ordem:
		sequencia_projeteis.shuffle()
		
	add_child(timer)
	timer.wait_time = tempo_entre_spawns
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	if indice_atual >= sequencia_projeteis.size():
		timer.stop()
		return

	var tipo = sequencia_projeteis[indice_atual]
	spawnar(tipo)
	indice_atual += 1

func spawnar(tipo: String):
	if cena_projetil:
		var novo_p = cena_projetil.instantiate()
		
		if tipo == "fogo" and "eh_fogo" in novo_p:
			novo_p.eh_fogo = true
		
		# Adiciona o projétil na cena principal
		get_tree().current_scene.add_child(novo_p)
		
		# Define a posição global exatamente na posição do nó Spawner
		novo_p.global_position = global_position
