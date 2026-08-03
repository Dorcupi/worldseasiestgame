extends Node2D
class_name Microgame

@export var game_name: String
var game_playing: bool = false
var level: int = 1

signal win_game
signal lose_game
