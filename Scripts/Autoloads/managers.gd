# Defines global access to managers, please set in root
extends Node

var self_management: SelfManagement
var bullet_manager: BulletManager
var sound_manager:SoundManager
var map_manager:MainMap

# These should go in another place, but we have a few hours left
var game_won = false
var game_won_ghosts = 60
