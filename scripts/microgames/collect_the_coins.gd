extends Microgame

@export var player: CharacterBody2D
@export var coin: PackedScene
@export var coin_spawner: Node2D
@export var tile_map: TileMapLayer
@export var coin_pickup_player: AudioStreamPlayer

func spawn_coins() -> void:
	var safe_pos: bool = false
	var x_pos: int = randi_range(-9, 8)
	var y_pos: int = randi_range(-5, 4)
	var co = coin.instantiate()
	co.global_position = tile_map.to_global(tile_map.map_to_local(Vector2i(x_pos, y_pos)))
	coin_spawner.add_child(co)

func _ready() -> void:
	player.connect("coin_picked_up", coin_pick_up)
	for i in range(randi_range(level + 1, level + 5)):
		spawn_coins()

func _process(delta: float) -> void:
	if game_playing and player.can_move == false:
		player.can_move = true

func coin_pick_up() -> void:
	coin_pickup_player.play()
	await get_tree().physics_frame
	await get_tree().physics_frame
	if get_tree().get_node_count_in_group("coins") <= 0:
		win_game.emit()
