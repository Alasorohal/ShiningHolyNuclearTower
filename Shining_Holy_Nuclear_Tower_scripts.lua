local V = require("lib.klua.vector")
local v = V.v
local SU = require("script_utils")
local E = require("entity_db")
local S = require("sound_db")
local P = require("path_db")
local U = require("utils")

local cfg = require("Shining_Holy_Nuclear_Tower.Shining_Holy_Nuclear_Tower_config")
local scripts = require("tower_scripts")

local mod_scripts = {}

local function fts(v)
	return v / FPS
end

local function ready_to_attack(attack, store, factor)
	return store.tick_ts - attack.ts > attack.cooldown * factor
end

local function ready_to_use_power(power, power_attack, store, factor)
	return power.level > 0 and (store.tick_ts - power_attack.ts > power_attack.cooldown * (factor or 1)) and (not power_attack.silence_ts)
end

local function queue_insert(store, e)
	simulation:queue_insert_entity(e)
end

local function queue_remove(store, e)
	simulation:queue_remove_entity(e)
end

local function queue_damage(store, damage)
	store.damage_queue[#store.damage_queue + 1] = damage
end

mod_scripts.tower_holy_nuclear = {}

function mod_scripts.tower_holy_nuclear.insert(this, store)
	this._crystal_base_y = cfg.crystal_base_y
	this._crystal_amplitude = cfg.crystal_amplitude
	this._crystal_period = cfg.crystal_period
	this._crystal_phase = math.random() * math.pi * 2
	this._laser_active = false
	this._laser_start_ts = 0
	this._laser_duration = 0
	local SH = require("klove.shader_db")
	local crystal_shader = love.graphics.newShader(SH.path .. "/p_tint.c")
	this.render.sprites[3]._shader = crystal_shader
	this.render.sprites[3].shader_args = {
		tint_color = {1.0, 1.0, 1.0, 1.0},
		tint_factor = 0.0
	}
	-- 播放建造音效
	S:queue("ShiningHolyNuclearBuild")
	return true
end

function mod_scripts.tower_holy_nuclear.remove(this, store)
	local sprite = this.render.sprites[3]
	if sprite._shader then
		sprite._shader = nil
	end
	sprite.shader_args = nil
	return true
end

function mod_scripts.tower_holy_nuclear.update(this, store)
	local tw = this.tower
	local a = this.attacks
	local aa = this.attacks.list[1]
	local ab = this.attacks.list[2]
	local pow_b = this.powers.holy_blast
	local pow_nm = this.powers.nuclear_meltdown
	local sprites = this.render.sprites
	aa.ts = store.tick_ts
	local tpos = v(this.pos.x + this.tower.range_offset.x, this.pos.y + this.tower.range_offset.y)

	while true do
		if not tw.blocked then
			if pow_b.changed then
				pow_b.changed = nil
				ab.cooldown = pow_b.cooldown_config[pow_b.level]
				ab.damage_min = pow_b.damage_min_config[pow_b.level]
				ab.damage_max = pow_b.damage_max_config[pow_b.level]
				S:queue("ShiningHolyNuclearHolyBlastUp")
			end
			if pow_nm.changed then
				pow_nm.changed = nil
				S:queue("ShiningHolyNuclearNuclearUp")
			end
			if ready_to_attack(aa, store, tw.cooldown_factor) then
				local target = U.detect_foremost_enemy_in_range_filter_off(tpos, a.range, aa.vis_flags, aa.vis_bans)

				if target then
					aa.ts = store.tick_ts

					local crystal_offset = sprites[3].offset
					local b = E:create_entity(aa.bullet)
					b.bullet.damage_min = b.bullet.damage_min * tw.damage_factor_min
					b.bullet.damage_max = b.bullet.damage_max * tw.damage_factor_max
					b.bullet.to:copy(target.pos)
					if target.unit and target.unit.hit_offset then
						b.bullet.to:add(target.unit.hit_offset)
					end
					b.bullet.target_id = target.id
					b.bullet.from:set(this.pos.x + crystal_offset.x, this.pos.y + crystal_offset.y)
					b.pos:copy(b.bullet.from)
					if pow_nm.level > 0 then
						U.append_mod(b.bullet, "mod_holy_light_erosion")
						U.append_mod(b.bullet, "mod_holy_erosion_dps")
						b.bullet.level = pow_nm.level
					end
					queue_insert(store, b)
				else
					aa.ts = aa.ts + 0.1
				end
			end

			if ready_to_use_power(pow_b, ab, store, tw.cooldown_factor) then
				local enemy = U.find_biggest_enemy_in_range_filter_off(tpos, a.range, ab.vis_flags, ab.vis_bans)
				if enemy then
					ab.ts = store.tick_ts
					local b = E:create_entity("bullet_holy_nuclear_ultimate")
					b.bullet.target_id = enemy.id
					b.bullet.source_id = this.id
					b.bullet.from:copy(enemy.pos)
					b.bullet.to:copy(enemy.pos)
					b.pos:copy(enemy.pos)
					b.bullet.damage_factor_min = tw.damage_factor_min
					b.bullet.damage_factor_max = tw.damage_factor_max
					b.ray_duration = ab.duration
					b.bullet.damage_min = ab.damage_min
					b.bullet.damage_max = ab.damage_max

					if pow_nm.level > 0 then
						U.append_mod(b.bullet, "mod_holy_light_erosion")
						U.append_mod(b.bullet, "mod_holy_erosion_dps")
						b.bullet.level = pow_nm.level
					end

					queue_insert(store, b)

					this._laser_active = true
					this._laser_start_ts = store.tick_ts
					this._laser_duration = ab.duration
				else
					ab.ts = ab.ts + 0.1
				end
			end
		end

		if this._laser_active then
			local elapsed = store.tick_ts - this._laser_start_ts
			local duration = this._laser_duration

			-- 变红阶段：fade_in秒（tint_factor从0到tint_max）
			-- 持续红色：duration秒（激光持续时间，tint_factor保持tint_max）
			-- 恢复阶段：fade_out秒（tint_factor从tint_max回到0）
			local tint_factor = 0.0
			local tint_max = 0.8
			local fade_in_time = 0.5
			local fade_out_time = 0.5
			local hold_time = duration
			local fade_out_start = fade_in_time + hold_time
			local total_time = fade_in_time + hold_time + fade_out_time

			if elapsed < fade_in_time then
				-- 变红阶段
				tint_factor = (elapsed / fade_in_time) * tint_max
			elseif elapsed < fade_out_start then
				-- 持续红色阶段（激光持续时间）
				tint_factor = tint_max
			elseif elapsed < total_time then
				-- 恢复阶段
				tint_factor = tint_max * (1.0 - (elapsed - fade_out_start) / fade_out_time)
			else
				-- 完全恢复，结束效果
				this._laser_active = false
			end

			-- 直接修改表中的值，避免创建新表
			local color = sprites[3].shader_args.tint_color
			if not this._laser_active then
				color[1], color[2], color[3], color[4] = 1.0, 1.0, 1.0, 1.0
			else
				color[1], color[2], color[3], color[4] = 1.0, 0.4, 0.2, 1.0
			end
			sprites[3].shader_args.tint_factor = tint_factor
		end

		sprites[3].offset.y = this._crystal_base_y + math.sin(store.tick_ts * (2 * math.pi / this._crystal_period) + this._crystal_phase) * this._crystal_amplitude

		coroutine.yield()
	end
end

mod_scripts.mod_holy_erosion_dps = {}
function mod_scripts.mod_holy_erosion_dps.insert(this, store)
	local target = store.entities[this.modifier.target_id]
	if not target or target.health.dead then
		return false
	end
	if U.has_modifier(store, target, "mod_holy_erosion_dps") then
		-- 触发光爆
		local start_pos = v(target.pos.x, target.pos.y)
		if target.unit and target.unit.hit_offset then
			start_pos:add(target.unit.hit_offset)
		end

		local targets = U.find_enemies_in_range_filter_on(start_pos, cfg.light_explosion_range, E:get_template("ray_light_explosion").bullet.damage_flags, E:get_template("ray_light_explosion").bullet.damage_bans, function(e)
			return e.id ~= target.id
		end)

		if targets then
			for i = 1, cfg.light_explosion_ray_count_base + cfg.light_explosion_ray_count_per_level * this.modifier.level do
				local t = targets[math.random(#targets)]
				local ray = E:create_entity("ray_light_explosion")
				if not t._ray_light_explosion_count then
					t._ray_light_explosion_count = 0
				end
				t._ray_light_explosion_count = t._ray_light_explosion_count + 1
				ray.bullet.target_id = t.id
				ray.bullet.from:copy(start_pos)
				ray.bullet.to:copy(t.pos)
				if t.unit and t.unit.hit_offset then
					ray.bullet.to:add(t.unit.hit_offset)
				end
				ray.pos:copy(start_pos)
				ray.bullet.damage_factor = this.modifier.damage_factor / math.sqrt(t._ray_light_explosion_count) -- 光爆伤害衰减

				queue_insert(store, ray)
			end

			local m = E:create_entity("mod_slow_holy_light_explosion")
			m.modifier.target_id = target.id
			m.modifier.source_id = this.id
			m.modifier.level = this.modifier.level
			queue_insert(store, m)
		end
		return false
	end

	return true
end

mod_scripts.bullet_holy_nuclear_ultimate = {}

function mod_scripts.bullet_holy_nuclear_ultimate.update(this, store)
	local b = this.bullet
	local s = this.render.sprites[1]
	local target = b.target_id and store.entities[b.target_id]
	if not b.mods then
		if b.mod then
			b.mods = {b.mod}
		else
			b.mods = {}
		end
	end

	local dest = V.vclone(b.to)

	-- 初始化导航路径（参照原版 ultimate）
	if target and target.nav_path then
		local nearest = P:nearest_nodes(dest.x, dest.y, {target.nav_path.pi}, {1}, true)
		if nearest and nearest[1] then
			this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = unpack(nearest[1])
		end
	else
		local nearest = P:nearest_nodes(dest.x, dest.y)
		if nearest and nearest[1] then
			this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = unpack(nearest[1])
		end
	end

	b.to = P:node_pos(this.nav_path.pi, this.nav_path.spi, this.nav_path.ni)

	local start_loop_sound_ts = store.tick_ts + 1.8
	local last_damage_ts = 0
	local time_between_decals = fts(10) * (100 / this.motion.max_speed)
	local next_decal_ts = store.tick_ts
	local time_between_fire_fxs = fts(6) * (100 / this.motion.max_speed)
	local next_fire_fxs_ts = store.tick_ts

	-- 开场特效（参照原版 ultimate）
	local fx_in = E:create_entity(this.fx_in)
	fx_in.pos = V.vclone(dest)
	queue_insert(store, fx_in)

	local decal_in = E:create_entity(this.decal_in)
	decal_in.pos = V.vclone(dest)
	decal_in.render.sprites[1].ts = store.tick_ts
	queue_insert(store, decal_in)

	-- 播放光柱降临动画
	U.y_animation_play(this, "in", nil, store.tick_ts, 1, 1)
	U.animation_start(this, "loop", nil, store.tick_ts, true, 1, true)
	this.render.sprites[2].hidden = false

	-- 屏幕震动
	local shake = E:create_entity("aura_screen_shake")
	shake.aura.amplitude = cfg.holy_blast_shake_amplitude
	shake.aura.duration = this.ray_duration + cfg.holy_blast_shake_extra_duration
	shake.aura.freq_factor = cfg.holy_blast_shake_freq_factor
	queue_insert(store, shake)
	local shake_id = shake.id

	-- 以指定速度平滑移动到目标位置
	local function move_towards_target(target_pos, speed)
		local dx = target_pos.x - this.pos.x
		local dy = target_pos.y - this.pos.y
		local dist = V.len(dx, dy)

		local move_dist = speed * store.tick_length

		if move_dist >= dist then
			this.pos.x, this.pos.y = target_pos.x, target_pos.y
			return true
		end

		local ratio = move_dist / dist
		this.pos.x = this.pos.x + dx * ratio
		this.pos.y = this.pos.y + dy * ratio

		-- 更新导航路径
		local nearest = P:nearest_nodes(this.pos.x, this.pos.y)
		if nearest and nearest[1] then
			this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = unpack(nearest[1])
		end

		return false
	end

	-- 更新光柱位置（跟随敌人移动 - 追踪模式）
	local function update_position(current_enemy)
		-- 追踪目标地面位置（飞行单位瞄准地面）
		if current_enemy and current_enemy.pos and current_enemy.health and not current_enemy.health.dead then
			dest:copy(current_enemy.pos)
			-- 更新导航路径到新目标位置
			if current_enemy.nav_path then
				local nearest = P:nearest_nodes(dest.x, dest.y, {current_enemy.nav_path.pi}, {1}, true)
				if nearest and nearest[1] then
					this.nav_path.pi, this.nav_path.spi, this.nav_path.ni = unpack(nearest[1])
				end
			end
		end

		this.pos.x, this.pos.y = dest.x, dest.y
		local next = P:next_entity_node(this, store.tick_length)
		if next then
			U.set_destination(this, next)
		end
		U.walk_off__accel__unsnapped(this, store.tick_length)

		-- 地面贴花特效（参照原版 ultimate）
		if store.tick_ts > next_decal_ts then
			next_decal_ts = store.tick_ts + time_between_decals
			local pos = V.v(dest.x + math.random(-5, 5), dest.y + math.random(-5, 5))
			local fx = E:create_entity(this.decal)
			fx.pos = pos
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = table.random({true, false})
			queue_insert(store, fx)

			fx = E:create_entity(this.decal_2)
			fx.pos = pos
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = table.random({true, false})
			queue_insert(store, fx)
		end

		-- 火焰飞溅特效（参照原版 ultimate）
		if store.tick_ts > next_fire_fxs_ts then
			next_fire_fxs_ts = store.tick_ts + time_between_fire_fxs
			local fx = E:create_entity(this.fire_fx)
			fx.pos = V.v(dest.x, dest.y)
			fx.render.sprites[1].ts = store.tick_ts
			queue_insert(store, fx)
		end

		dest.x, dest.y = this.pos.x, this.pos.y

		-- 入场特效跟随光柱移动
		if fx_in then
			fx_in.pos:copy(this.pos)
		end
		if decal_in then
			decal_in.pos:copy(this.pos)
		end
	end

	-- 更新光柱位置（移动模式 - 保留视觉效果）
	local function update_position_transit()
		dest.x, dest.y = this.pos.x, this.pos.y

		-- 入场特效跟随光柱移动
		if fx_in then
			fx_in.pos:copy(this.pos)
		end
		if decal_in then
			decal_in.pos:copy(this.pos)
		end

		-- 地面贴花特效
		if store.tick_ts > next_decal_ts then
			next_decal_ts = store.tick_ts + time_between_decals
			local pos = V.v(dest.x + math.random(-5, 5), dest.y + math.random(-5, 5))
			local fx = E:create_entity(this.decal)
			fx.pos = pos
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = table.random({true, false})
			queue_insert(store, fx)

			fx = E:create_entity(this.decal_2)
			fx.pos = pos
			fx.render.sprites[1].ts = store.tick_ts
			fx.render.sprites[1].flip_x = table.random({true, false})
			queue_insert(store, fx)
		end

		-- 火焰飞溅特效
		if store.tick_ts > next_fire_fxs_ts then
			next_fire_fxs_ts = store.tick_ts + time_between_fire_fxs
			local fx = E:create_entity(this.fire_fx)
			fx.pos = V.v(dest.x, dest.y)
			fx.render.sprites[1].ts = store.tick_ts
			queue_insert(store, fx)
		end
	end

	-- 伤害处理：对当前追踪目标直接造成伤害，对范围内其他敌人通过索敌溅射
	local function handle_hits(current_enemy)
		-- 范围溅射：以光柱位置为中心搜索附近敌人
		local targets = U.find_enemies_in_range_filter_off(this.pos, b.damage_radius, b.damage_flags, b.damage_bans)
		if targets then
			for _, e in ipairs(targets) do
				local d = SU.create_bullet_damage(b, e.id, this.id)
				queue_damage(store, d)

				for _, mod_name in ipairs(b.mods) do
					if U.flags_pass(e.vis, E:get_template(mod_name).modifier) then
						local m = E:create_entity(mod_name)
						m.modifier.target_id = e.id
						m.modifier.source_id = this.id
						m.modifier.level = b.level
						m.modifier.damage_factor = b.damage_factor
						queue_insert(store, m)
					end
				end
			end
		end
	end

	-- 寻找新目标（优先血量上限最高的，血量相同选最近的）
	-- 索敌范围随等级增加：基础200 + 每等级50（Lv1=250, Lv2=300, Lv3=350）
	local function find_new_target()
		local tower_entity = this._tower_id and store.entities[this._tower_id]
		local tower_pos = tower_entity and tower_entity.pos or (b.from and V.vclone(b.from) or V.vclone(this.pos))
		local range = this._tower_range or 200

		local enemies = U.find_enemies_in_range_filter_off(this.pos, 200, b.damage_flags, b.damage_bans)
		if enemies then
			return table.find_best(enemies, function(e)
				return -this.pos:dist2(e.pos)
			end)
		end

		return nil
	end

	s.scale = s.scale or V.v(1, 1)
	s.ts = store.tick_ts

	local start_ts = store.tick_ts
	local current_target = target
	local is_in_transit = false -- 是否正在以80速度移动前往新目标

	-- 初始位置更新（直接闪现到首个目标）
	update_position(current_target)

	-- 主循环：持续伤害 + 追踪 + 移动切换目标
	while store.tick_ts - start_ts < this.ray_duration do
		-- 检查当前目标是否存活
		if current_target then
			if not current_target.health or current_target.health.dead then
				-- 当前目标已死亡，寻找新目标（优先血量上限最高）
				current_target = find_new_target()
				if current_target then
					b.target_id = current_target.id
					is_in_transit = true -- 开始以80速度移动前往新目标
				else
					break
				end
			end
		else
			current_target = find_new_target()
			if current_target then
				b.target_id = current_target.id
				is_in_transit = true
			else
				break
			end
		end

		-- 根据状态更新光柱位置
		if is_in_transit then
			-- 移动模式：以80速度前往新目标地面位置
			local arrived = move_towards_target(current_target.pos, this.motion.max_speed)

			if arrived then
				-- 到达目标附近，切换为追踪模式
				is_in_transit = false
				dest.x, dest.y = this.pos.x, this.pos.y
			end

			-- 移动期间保留视觉效果
			update_position_transit()

			-- 移动期间也可造成伤害
			if store.tick_ts - start_ts > this.hit_delay and store.tick_ts - last_damage_ts >= this.damage_every then
				last_damage_ts = store.tick_ts
				handle_hits(current_target)
			end

			-- 移动途中目标也可能死亡
			if current_target and (not current_target.health or current_target.health.dead) then
				current_target = find_new_target()
				if current_target then
					b.target_id = current_target.id
					is_in_transit = true
				else
					break
				end
			end
		else
			-- 追踪模式：跟随目标移动
			update_position(current_target)

			-- 持续伤害：每 damage_every 秒造成伤害
			if store.tick_ts - start_ts > this.hit_delay and store.tick_ts - last_damage_ts >= this.damage_every then
				last_damage_ts = store.tick_ts
				handle_hits(current_target)
			end
		end

		-- 循环音效
		if start_loop_sound_ts and start_loop_sound_ts < store.tick_ts then
			start_loop_sound_ts = nil
			S:queue(this.sound_loop)
		end

		-- 路径失效检查
		if not P:is_node_valid(this.nav_path.pi, this.nav_path.ni) then
			break
		end

		coroutine.yield()
	end

	-- 结束阶段（参照原版 ultimate）
	S:stop(this.sound_loop)
	S:queue(this.sound_end)

	-- 调整屏幕震动结束时间
	shake = store.entities[shake_id]
	if shake then
		shake.aura.duration = store.tick_ts - start_ts + 1
	end

	-- tween 淡出动画（sprite[2] 的 alpha 从255淡到0）
	this.tween.ts = store.tick_ts
	this.tween.disabled = false
	this.render.sprites[1].runs = 0

	-- 等待光柱结束动画
	while not U.animation_finished_default(this) do
		if is_in_transit and current_target then
			-- 淡出期间仍在移动中，继续移动（瞄准地面位置）
			move_towards_target(current_target.pos, this.motion.max_speed)
			dest.x, dest.y = this.pos.x, this.pos.y
		elseif current_target then
			update_position(current_target)
		end
		coroutine.yield()
	end

	-- 最后一个火焰飞溅
	local fx = E:create_entity(this.fire_fx)
	fx.pos = V.v(dest.x + math.random(-20, 20), dest.y + math.random(-20, 20))
	fx.render.sprites[1].ts = store.tick_ts
	fx.render.sprites[1].delay_start = fts(6)
	queue_insert(store, fx)

	queue_remove(store, this)
end

return mod_scripts
