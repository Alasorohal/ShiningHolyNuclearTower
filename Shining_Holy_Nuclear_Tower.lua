local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
local hook = hook_utils:new()
local A = require("animation_db")
local E = require("entity_db")
local S = require("sound_db")
local i18n = require("i18n")
local cached_mod_data = nil

local function register_textures_and_sounds()
	local game = require("game")
	-- 插件自己管理的美术资源
	game.plugin_required_textures["Shining_Holy_Nuclear_Tower_game"] = {
		-- 不使用 bytecode 方式加载
		use_bytecode = false,
		-- 加载路径
		path = "Shining_Holy_Nuclear_Tower/assets/images"
	}

	table.arrayensure(game.required_textures, "go_hero_lilith")
	table.arrayensure(game.required_textures, "go_hero_dragon_sun")

	-- 声音资源
	table.arrayensure(game.required_sounds, "hero_lilith")
	table.arrayensure(game.required_sounds, "hero_dragon_sun")
	table.arrayensure(game.required_sounds, "hero_priest")

    -- 注册音效
	local S = require("sound_db")
	local sounds = require("Shining_Holy_Nuclear_Tower.assets.sounds.sounds")
	-- clear up
	package.loaded["Shining_Holy_Nuclear_Tower.assets.sounds.sounds"] = nil

	-- 新接口写法
	-- S:register_sounds(sounds)

	-- 兼容性写法
	for k, v in pairs(sounds) do
		S.sounds[k] = v
		S:_precache_sound(k, v)
	end
end

local function register_upgrades()
	local UP = require("kr1.upgrades")
	table.arrayensure(UP.mage_towers, "tower_holy_nuclear")
	table.arrayensure(UP.mage_tower_bolts, "bullet_holy_nuclear_crystal")
	table.arrayensure(UP.bolts, "bullet_holy_nuclear_crystal")
end

local function register_tower_menus()
	local tower_menus_data = require("kr1.data.tower_menus_data")
	local tower_menus_scripts = require("kr1.data.tower_menus_data_scripts")
	local tpl = require("kr1.data.tower_menus_data_templates")
	local i18n = require("i18n")
	local M = tower_menus_scripts.merge
	tower_menus_scripts.clever_add(tower_menus_data.mage[3], M(tpl.upgrade, {
		action_arg = "tower_holy_nuclear",
		image = "holy_nuclear_tower_icon",
		tt_title = _("TOWER_HOLY_NUCLEAR_NAME"),
		tt_desc = _("TOWER_HOLY_NUCLEAR_DESCRIPTION")
	}))
	tower_menus_data.holy_nuclear = {{M(tpl.upgrade_power, {
		action_arg = "holy_blast",
		image = "holy_nuclear_power1",
		place = 1,
		tt_phrase = _("TOWER_HOLY_NUCLEAR_HOLY_BLAST_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_HOLY_NUCLEAR_HOLY_BLAST_NAME_1"),
			tt_desc = _("TOWER_HOLY_NUCLEAR_HOLY_BLAST_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_HOLY_NUCLEAR_HOLY_BLAST_NAME_2"),
			tt_desc = _("TOWER_HOLY_NUCLEAR_HOLY_BLAST_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_HOLY_NUCLEAR_HOLY_BLAST_NAME_3"),
			tt_desc = _("TOWER_HOLY_NUCLEAR_HOLY_BLAST_DESCRIPTION_3")
		}}
	}), M(tpl.upgrade_power, {
		action_arg = "nuclear_meltdown",
		image = "holy_nuclear_power2",
		place = 2,
		tt_phrase = _("TOWER_HOLY_NUCLEAR_NUCLEAR_MELTDOWN_NOTE"),
		tt_list = {{
			tt_title = _("TOWER_HOLY_NUCLEAR_NUCLEAR_MELTDOWN_NAME_1"),
			tt_desc = _("TOWER_HOLY_NUCLEAR_NUCLEAR_MELTDOWN_DESCRIPTION_1")
		}, {
			tt_title = _("TOWER_HOLY_NUCLEAR_NUCLEAR_MELTDOWN_NAME_2"),
			tt_desc = _("TOWER_HOLY_NUCLEAR_NUCLEAR_MELTDOWN_DESCRIPTION_2")
		}, {
			tt_title = _("TOWER_HOLY_NUCLEAR_NUCLEAR_MELTDOWN_NAME_3"),
			tt_desc = _("TOWER_HOLY_NUCLEAR_NUCLEAR_MELTDOWN_DESCRIPTION_3")
		}}
	}), tpl.sell}}
end

local function merge_locales(locale)
	if locale == "zh-Hans" then
		local strings = require("Shining_Holy_Nuclear_Tower.assets.strings.zh-Hans")
		for k, v in pairs(strings) do
			i18n.msgs["zh-Hans"][k] = v
		end
	end
end

-- 注册动画资源
function hook.A.load(load, self)
	load(self)
	local animations = require("Shining_Holy_Nuclear_Tower.animations")
	package.loaded["Shining_Holy_Nuclear_Tower.animations"] = nil
	for k, v in pairs(animations) do
		A.db[k] = A.extract_frame_from(v)
	end
end

-- 注册模板
function hook.E.load(load, self)
	load(self)

	require("Shining_Holy_Nuclear_Tower.Shining_Holy_Nuclear_Tower_templates")
	require("Shining_Holy_Nuclear_Tower.Shining_Holy_Nuclear_Tower_scripts")

	-- clear up
	package.loaded["Shining_Holy_Nuclear_Tower.Shining_Holy_Nuclear_Tower_templates"] = nil
	package.loaded["Shining_Holy_Nuclear_Tower.Shining_Holy_Nuclear_Tower_scripts"] = nil
end

function hook.i18n.load_locale(next, locale)
	next(locale)
	merge_locales(locale)
end

function hook:init(mod_data)
	self.mod_data = mod_data
	cached_mod_data = mod_data

	-- i18n 的 load_locale 事件在 插件初始前就调用过了，所以这里要手动调用一次
	merge_locales(i18n.current_locale)
	register_textures_and_sounds()
	register_upgrades()
	register_tower_menus()

	HOOK(A, "load", self.A.load)
	HOOK(E, "load", self.E.load)
	HOOK(i18n, "load_locale", self.i18n.load_locale)
end

return hook
