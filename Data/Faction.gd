extends Node2D

var AI = false

var max_soldiers = 20
var soldier_kia = 0
#var total_soldiers_remaining = 20
#
#var wave_force = 0
#var wave_force_remainder = 0
#var soldiers_remaining = 0


var soldiers = 0


var faction = "Army"
var player_list = []
var build_list = []
var defence_list = []
var vehicle_list = []
var attacker_list = []
var builder_list = []

var building_list = []
var side = "allies"
var enemyside = "enemies"
var sidenumber = 1
var enemynumber = 2
var enemynumberval = 4
var points = 300

var flipped = false