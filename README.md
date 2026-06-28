# 圣核法术阵列（Shining Holy Nuclear Tower）

> KR1（Dove）四级塔扩展
> 主题：神圣光柱 + 侵蚀减甲 + 光爆连锁

---

## 简介

本 Mod 为 **Kingdom Rush Dove（KR1）** 新增一座四级法术塔——**圣核法术阵列**，拥有独特的漂浮水晶视觉和两大核心技能。，使用需保证自己的游戏版本为最新版本。

- **神圣冲击**：召唤追踪光柱持续灼烧敌人，目标死亡后自动切换下一个目标。
- **折射阵列**：普攻削减敌人双抗并附加真伤，叠层触发光爆向周围敌人发射魔法光束。

---

## 塔基础属性

| 属性 | 数值 |
|------|------|
| 价格 | 300 |
| 类型 | 法术塔（Mage） |
| 攻击范围 | 200 |
| 攻击冷却 | 1.0秒 |
| 普攻伤害 | 44~66（魔法） |
| 伤害倍率 | 1.0 |
| 冷却倍率 | 1.0 |

---

## 技能详解

### 神圣冲击（Holy Blast）

**核心机制：追踪光柱 + 目标切换**

发射一道从天而降的光柱，持续对范围内敌人造成魔法伤害。光柱会追踪目标移动，目标死亡后以80像素/秒的速度移动到下一个敌人位置。

- 光柱伤害范围：40像素
- 伤害间隔：0.25秒
- 目标选择：优先血量最高的敌人
- 目标切换：死亡后自动寻找新目标（优先血量上限最高），无目标则结束
- 飞行单位：光柱瞄准地面位置

| 等级 | 价格 | 冷却 | 持续时间 | 每次伤害 | 索敌范围 |
|------|------|------|----------|----------|----------|
| 1 | 200 | 28秒 | 4秒 | 16~20 | 250 |
| 2 | 160 | 26秒 | 5秒 | 20~24 | 300 |
| 3 | 160 | 24秒 | 6秒 | 24~28 | 350 |

---

### 折射阵列（Nuclear Meltdown）

**核心机制：减甲 + 真伤 + 叠层光爆**

升级后，普攻和光柱伤害都会为敌人附加 **神圣侵蚀** modifier，同时附加真伤效果。

#### 神圣侵蚀

- 持续时间：5秒
- 每次命中削减 10% 物理抗性和魔法抗性（上限10%）
- 叠层独立于减甲，不因光爆触发而重置

#### 神圣侵蚀真伤

- 每1秒造成9点真实伤害
- 可叠加2层
- 持续时间与神圣侵蚀相同（5秒）

#### 光爆（叠层触发）

同一敌人叠满2层神圣侵蚀后触发光爆：
- 向180像素范围内随机敌人发射魔法光束
- 每道光束造成20~35魔法伤害
- 射线数随等级增加：Lv1=3道、Lv2=4道、Lv3=5道
- 触发后叠层清零

| 等级 | 价格 | 减甲 | 真伤 | 光爆射线数 |
|------|------|------|------|-----------|
| 1 | 250 | 10%双抗 | 9/秒×2层 | 3 |
| 2 | 170 | 10%双抗 | 9/秒×2层 | 4 |
| 3 | 170 | 10%双抗 | 9/秒×2层 | 5 |

**与神圣冲击的联动**：升级折射阵列后，神圣冲击的光柱伤害也会附加神圣侵蚀和真伤modifier，加速叠层触发光爆。

---

## 视觉系统

### 漂浮水晶

塔顶水晶持续上下漂浮，参数可配置：
- 基础Y位置：75像素
- 漂浮幅度：6像素
- 漂浮周期：3秒
- 随机初始相位（每座塔不同）

### 水晶变色

释放神圣冲击时，水晶通过 `p_tint` shader 渐变为红色：
- 变红阶段：0.5秒（tint_factor 0→0.8）
- 持续红色：光柱持续时间
- 恢复阶段：0.5秒（tint_factor 0.8→0）

每座塔拥有独立的 shader 对象和 shader_args，确保多座塔的水晶颜色互不干扰。

---

## 配置说明

配置文件 `Shining_Holy_Nuclear_Tower_config.lua`，支持游戏内热修改。

### 塔基础属性

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `tower_price` | 300 | 塔价格 |
| `damage_factor` | 1.0 | 伤害倍率 |
| `cooldown_factor` | 1.0 | 冷却倍率 |
| `attack_range` | 200 | 攻击范围（像素） |
| `attack_cooldown` | 1.0 | 普攻冷却时间（秒） |
| `attack_damage_min` | 44 | 普攻最小伤害 |
| `attack_damage_max` | 66 | 普攻最大伤害 |

### 神圣冲击技能

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `holy_blast_price_base` | 200 | 基础价格 |
| `holy_blast_price_inc` | 160 | 每级价格增量 |
| `holy_blast_cooldown_1/2/3` | 28/26/24 | 各级冷却（秒） |
| `holy_blast_damage_min_1/2/3` | 16/20/24 | 各级最小伤害 |
| `holy_blast_damage_max_1/2/3` | 20/24/28 | 各级最大伤害 |
| `holy_blast_duration_1/2/3` | 4/5/6 | 各级持续时间（秒） |
| `holy_blast_damage_radius` | 40 | 伤害范围（像素） |
| `ultimate_damage_every` | 0.25 | 光柱伤害间隔（秒） |
| `ultimate_max_speed` | 80 | 光柱移动速度（像素/秒） |

### 折射阵列技能

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `nuclear_meltdown_price_base` | 250 | 基础价格 |
| `nuclear_meltdown_price_inc` | 170 | 每级价格增量 |
| `erosion_duration` | 5 | 神圣侵蚀持续时间（秒） |
| `erosion_armor_reduction` | 0.1 | 每次减甲比例（10%） |
| `erosion_dps_damage` | 9 | 真伤每秒伤害 |
| `erosion_dps_damage_every` | 1 | 真伤间隔（秒） |
| `light_explosion_damage_min` | 20 | 光爆最小伤害 |
| `light_explosion_damage_max` | 35 | 光爆最大伤害 |
| `light_explosion_ray_count_base` | 3 | 光爆基础射线数 |
| `light_explosion_ray_count_per_level` | 1 | 光爆每级增加射线数 |

### 视觉参数

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `crystal_base_y` | 75 | 水晶漂浮基础Y位置（像素） |
| `crystal_amplitude` | 6 | 水晶漂浮幅度（像素） |
| `crystal_period` | 3.0 | 水晶漂浮周期（秒） |
| `holy_blast_shake_amplitude` | 0.35 | 神圣冲击震动幅度 |
| `holy_blast_shake_extra_duration` | 0.5 | 神圣冲击震动额外时长（秒） |
| `holy_blast_shake_freq_factor` | 4 | 神圣冲击震动频率因子 |
| `sprite_tower_scale` | 0.62 | 主塔缩放比例 |

---

## 技术说明

- 塔模板继承自 `tower`，注册为 `tower_holy_nuclear`，类型 `holy_nuclear`
- 普攻子弹使用 `arrow` 类型（莉莉丝弹道视觉），飞行时间0.333秒
- 光柱子弹使用 `bullet` 类型，复用龙阳大招视觉资源（`hero_aurion_ulti`）
- 光爆射线使用 `bullet` 类型（`ray_sunray` 日光塔射线视觉）
- 神圣侵蚀 modifier（`mod_holy_light_erosion`）自定义 insert/update/remove 脚本，管理叠层计数和护甲削减
- 神圣侵蚀真伤 modifier（`mod_holy_erosion_dps`）使用引擎内置 `scripts.mod_dps` 脚本
- 每座塔实例创建独立的 `p_tint` shader 对象，避免多塔水晶颜色状态共享
- 通过 hook `entity_db.load` 注入模板，hook `animation_db.load` 注册动画
- 注入天赋系统（`kr1.upgrades`）的 `mage_towers`、`mage_tower_bolts`、`bolts` 列表，支持法术塔通用加成
- 普攻优先攻击有神圣侵蚀叠层的敌人（叠层最多优先）

---

## 文件结构

```
Shining_Holy_Nuclear_Tower/
├── config.lua                              # Mod元数据（名称、版本、作者）
├── Shining_Holy_Nuclear_Tower.lua          # 入口文件（hook注册、菜单注入、天赋注入）
├── Shining_Holy_Nuclear_Tower_config.lua   # 配置文件（所有数值参数）
├── Shining_Holy_Nuclear_Tower_scripts.lua  # 脚本文件（modifier逻辑、光柱行为）
├── Shining_Holy_Nuclear_Tower_templates.lua# 模板文件（塔/子弹/modifier实体定义）
└── _assets/image/
    ├── Shining_Holy_Nuclear_Tower_game.lua # 贴图定义
    ├── achievement_icons_0015.png          # 建造按钮图标
    ├── crystal.png                         # 漂浮水晶贴图
    ├── power_icon1.png                     # 神圣冲击技能图标
    ├── power_icon2.png                     # 折射阵列技能图标
    └── tower.png                           # 塔主体贴图
```

---

## 兼容性

- 适用于 Kingdom Rush Dove（KR1）
- 复用本体资源：`go_hero_lilith`（普攻弹道）、`go_hero_dragon_sun`（光柱视觉）
- 与其他修改法术塔菜单的 mod 可能存在冲突

## 更新日志
- **1.0.1**：
- 资源引用优化
- **1.0.0**：
- 正式版发布，代码优化（滴答干的）
- 补全游戏内音效
- **0.0.6**：
 - 修复一些大型怪物无法被神圣冲击攻击的问题
- **0.0.5**：
- 三个神圣冲击的震动参数已从硬编码改为配置文件
- amplitude = 0.35 — 震动幅度
- duration = this.ray_duration + 0.5 — 震动持续时间（光柱时长 + 0.5秒余量）
- freq_factor = 4 — 震动频率因子

-略微上调了部分技能数值
- 神圣冲击伤害：min 12/16/20 → 16/20/24，max 16/20/24 → 20/24/28
- 神圣侵蚀真伤：7 → 9

- **0.0.4**：
- 更新菜单位置，防止冲突
- **0.0.3**：
- 更改图集名称，防冲突
- **0.0.2**：
  - 修复一些大型怪物无法被神圣冲击攻击的问题