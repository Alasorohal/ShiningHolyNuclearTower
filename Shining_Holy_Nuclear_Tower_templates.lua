require("all.constants")
require("game_templates_utils")

local scripts = require("scripts")
local mod_scripts = require("Shining_Holy_Nuclear_Tower.Shining_Holy_Nuclear_Tower_scripts")
local E = require("entity_db")
local V = require("lib.klua.vector")
local vec_2 = V.v
local r = V.r

-- 加载配置
local cfg = require("Shining_Holy_Nuclear_Tower.Shining_Holy_Nuclear_Tower_config")

-- 注册塔模板（独立新建，继承自 "tower"）
local tt = RT("tower_holy_nuclear", "tower")
AC(tt, "attacks", "powers")
tt.tower.level = 1
tt.tower.type = "holy_nuclear"
tt.tower.kind = TOWER_KIND_MAGE
tt.tower.price = cfg.tower_price
tt.tower.size = TOWER_SIZE_LARGE
tt.tower.menu_offset = vec_2(0, 25)
tt.tower.damage_factor_min = cfg.damage_factor_min
tt.tower.damage_factor_max = cfg.damage_factor_max
tt.tower.cooldown_factor = cfg.cooldown_factor
tt.info.enc_icon = 15
tt.info.portrait = "info_portraits_towers_0008"
tt.render.sprites[1] = CC("sprite")
tt.render.sprites[1].animated = false
tt.render.sprites[1].name = "terrain_mage_0001"
tt.render.sprites[1].offset = vec_2(0, 13)
tt.render.sprites[1].z = Z_OBJECTS - 10
tt.render.sprites[2] = CC("sprite")
tt.render.sprites[2].animated = false
tt.render.sprites[2].name = "holy_nuclear_tower_base"
tt.render.sprites[2].offset = vec_2(0, 30)
tt.render.sprites[2].scale = vec_2(cfg.sprite_tower_scale, cfg.sprite_tower_scale)
tt.render.sprites[2].z = Z_OBJECTS
tt.render.sprites[3] = CC("sprite")
tt.render.sprites[3].animated = false
tt.render.sprites[3].name = "holy_nuclear_crystal"
tt.render.sprites[3].offset = vec_2(0, 30)
tt.render.sprites[3].z = Z_OBJECTS + 1
tt.attacks.range = cfg.attack_range
tt.attacks.list[1] = CC("bullet_attack")
tt.attacks.list[1].cooldown = cfg.attack_cooldown
tt.attacks.list[1].bullet = "bullet_holy_nuclear_crystal"
tt.powers.holy_blast = CC("power")
tt.powers.holy_blast.price_base = cfg.holy_blast_price_base
tt.powers.holy_blast.price_inc = cfg.holy_blast_price_inc
tt.powers.holy_blast.attack_idx = 2
tt.powers.holy_blast.max_level = 3
tt.powers.holy_blast.damage_min_config = cfg.holy_blast_damage_min
tt.powers.holy_blast.damage_max_config = cfg.holy_blast_damage_max
tt.powers.holy_blast.cooldown_config = cfg.holy_blast_cooldown
tt.powers.holy_blast.duration_config = cfg.holy_blast_duration
tt.attacks.list[2] = CC("bullet_attack")
tt.attacks.list[2].bullet = "bullet_holy_nuclear_ultimate"
tt.attacks.list[2].cooldown = cfg.holy_blast_cooldown[1]
tt.attacks.list[2].damage_min = cfg.holy_blast_damage_min[1]
tt.attacks.list[2].damage_max = cfg.holy_blast_damage_max[1]
tt.attacks.list[2].duration = cfg.holy_blast_duration[1]
tt.attacks.list[2].disabled = true
tt.attacks.list[2].level = 0
tt.attacks.list[2].power_name = "holy_blast"
tt.attacks.list[2].vis_flags = bor(F_ENEMY)
tt.attacks.list[2].vis_bans = 0
tt.attacks.list[2].damage_radius = cfg.holy_blast_damage_radius
tt.powers.nuclear_meltdown = CC("power")
tt.powers.nuclear_meltdown.price_base = cfg.nuclear_meltdown_price_base
tt.powers.nuclear_meltdown.price_inc = cfg.nuclear_meltdown_price_inc
tt.powers.nuclear_meltdown.max_level = 3
tt.main_script.insert = mod_scripts.tower_holy_nuclear.insert
tt.main_script.update = mod_scripts.tower_holy_nuclear.update
tt.main_script.remove = mod_scripts.tower_holy_nuclear.remove
-- 禁用原版建造音效，改用自定义建造音效（在 insert 脚本中播放）
tt.sound_events = {}
tt.sound_events.construction = ""
tt.ui.click_rect = r(-40, 0, 80, 86)

local bt = RT("bullet_holy_nuclear_crystal", "arrow")
bt.bullet.damage_min = cfg.attack_damage_min
bt.bullet.damage_max = cfg.attack_damage_max
bt.bullet.damage_type = DAMAGE_MAGICAL
bt.bullet.flight_time = fts(9)
bt.bullet.flight_time_factor = fts(0.009)
bt.bullet.g = 0
bt.bullet.hide_radius = 1
bt.bullet.hit_fx = "fx_lilith_ranged_hit"
bt.bullet.miss_fx = "fx_lilith_ranged_hit"
bt.bullet.miss_decal = nil
bt.bullet.particles_name = "ps_bullet_lilith_trail"
bt.render.sprites[1].name = "fallen_angel_hero_proy_0001-f"
bt.sound_events.insert = "ElvesHeroLilithRangeShoot"

-- 神圣冲击大招光柱子弹
local bult = RT("bullet_holy_nuclear_ultimate", "bullet")
AC(bult, "nav_path", "motion", "tween")
bult.render.sprites[1].z = Z_OBJECTS
bult.render.sprites[1].sort_y_offset = -30
bult.render.sprites[1].prefix = "hero_aurion_ulti"
bult.render.sprites[1].anchor = vec_2(0.5, 0.5)
bult.render.sprites[1].name = "in"
bult.render.sprites[1].loop = false
bult.render.sprites[1].animated = true
bult.render.sprites[1].scale = vec_2(1.2, 3)
bult.render.sprites[2] = E:clone_c("sprite")
bult.render.sprites[2].name = "hero_aurion_fire_base_ulti_run"
bult.render.sprites[2].ignore_start = true
bult.render.sprites[2].animated = true
bult.render.sprites[2].hidden = true
bult.render.sprites[2].loop = true
bult.render.sprites[2].scale = vec_2(1.2, 2)
bult.render.sprites[2].offset = vec_2(0, -30)
bult.render.sprites[2].z = Z_OBJECTS
bult.render.sprites[2].sort_y_offset = -30
bult.image_width = 146.25
bult.hit_delay = 0.033
bult.ray_duration = fts(11)
bult.nav_path.dir = -1
bult.bullet.damage_type = DAMAGE_MAGICAL
bult.bullet.damage_min = 12
bult.bullet.damage_max = 16
bult.bullet.damage_radius = cfg.holy_blast_damage_radius
bult.damage_every = cfg.ultimate_damage_every
bult.motion.max_speed = cfg.ultimate_max_speed
bult.bullet.damage_flags = F_AREA
bult.bullet.damage_bans = 0
bult.main_script.update = mod_scripts.bullet_holy_nuclear_ultimate.update
bult.fx_in = "fx_hero_dragon_sun_ultimate_in"
bult.decal_in = "decal_bullet_hero_dragon_sun_ultimate_base"
bult.decal = "decal_bullet_hero_dragon_sun_ultimate"
bult.decal_2 = "decal_bullet_hero_dragon_sun_ultimate_2"
bult.fire_fx = "fx_hero_dragon_sun_ultimate_back_fire"
bult.tween.disabled = true
bult.tween.remove = false
bult.tween.props[1] = E:clone_c("tween_prop")
bult.tween.props[1].name = "alpha"
bult.tween.props[1].keys = {{0, 255}, {0.25, 0}}
bult.tween.props[1].sprite_id = 2
bult.sound_events.insert = "HeroDragonSunUltimateBegin"
bult.sound_loop = "HeroDragonSunUltimateLoop"
bult.sound_end = "HeroDragonSunUltimateEnd"

-- 光爆射线特效（2层神圣侵蚀触发，日光塔射线视觉）
local ray_explosion = RT("ray_light_explosion", "bullet")
ray_explosion.bullet.damage_min = cfg.light_explosion_damage_min
ray_explosion.bullet.damage_max = cfg.light_explosion_damage_max
ray_explosion.bullet.damage_type = DAMAGE_MAGICAL
ray_explosion.bullet.hit_fx = "fx_light_explosion_hit"
ray_explosion.bullet.reduce_magic_armor = 0
ray_explosion.bullet.damage_flags = F_RANGED
ray_explosion.bullet.damage_bans = 0
ray_explosion.bullet.mods = {"mod_slow_holy_light_explosion"}
ray_explosion.image_width = 58
ray_explosion.track_target = true
ray_explosion.main_script.update = scripts.ray_simple.update
ray_explosion.render.sprites[1].anchor = vec_2(0, 0.5)
ray_explosion.render.sprites[1].name = "ray_sunray"
ray_explosion.render.sprites[1].loop = false
ray_explosion.render.sprites[1].z = Z_EFFECTS
ray_explosion.sound_events.insert = "InfernalMageAttack"
ray_explosion.ray_duration = cfg.light_explosion_ray_duration
ray_explosion.ray_y_scales = {0.4, 0.6, 0.8, 1}
ray_explosion.bullet.hit_time = cfg.light_explosion_hit_time

tt = RT("mod_slow_holy_light_explosion", "mod_slow")

-- 圣光侵蚀：视觉 + 护甲削减（持续，总削减上限，叠层计数触发光爆，护甲削减不受光爆重置）
local erosion = RT("mod_holy_light_erosion", "modifier")
AC(erosion, "render", "armor_buff")
erosion.modifier.duration = cfg.erosion_duration
erosion.modifier.vis_flags = F_MOD
erosion.modifier.use_mod_offset = true
erosion.main_script.insert = scripts.mod_armor_buff.insert
erosion.main_script.update = scripts.mod_track_target.update
erosion.main_script.remove = scripts.mod_armor_buff.remove
erosion.armor_buff.both = true
erosion.armor_buff.max_factor = -cfg.erosion_armor_reduction
-- 使用神圣打击的沉默特效，添加金黄色shader模拟圣光残留
erosion.render.sprites[1].prefix = "vanhelsing_silence"
erosion.render.sprites[1].size_names = {"small", "big", "big"}
erosion.render.sprites[1].name = "small"
erosion.render.sprites[1].loop = true
erosion.render.sprites[1].sort_y_offset = -2
erosion.render.sprites[1].shader = "p_tint"
erosion.render.sprites[1].shader_args = {
    tint_color = {1.0, 0.85, 0.2, 1.0},
    tint_factor = 0.75
}

local erosion_dps = RT("mod_holy_erosion_dps", "modifier")
-- AC(erosion_dps, "dps")
erosion_dps.modifier.duration = cfg.erosion_duration
erosion_dps.modifier.vis_flags = F_MOD
erosion_dps.modifier.allows_duplicates = true
-- erosion_dps.dps.damage_min = cfg.erosion_dps_damage
-- erosion_dps.dps.damage_max = cfg.erosion_dps_damage
-- erosion_dps.dps.damage_every = cfg.erosion_dps_damage_every
-- erosion_dps.dps.damage_type = DAMAGE_TRUE
erosion_dps.main_script.insert = mod_scripts.mod_holy_erosion_dps.insert
erosion_dps.main_script.update = scripts.mod_track_target.update
-- erosion_dps.main_script.update = scripts.mod_dps.update

-- 光爆击中特效
local fx_explosion_hit = RT("fx_light_explosion_hit", "fx")
fx_explosion_hit.render.sprites[1].name = "ember_lords_mage_tower_shooter_proyectile_hit"
