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
| 价格 | 280 |
| 类型 | 法术塔（Mage） |
| 攻击范围 | 200 |
| 攻击冷却 | 1.0秒 |
| 普攻伤害 | 54~66（魔法） |
| 伤害倍率 | 1.0 |
| 冷却倍率 | 1.0 |

---

## 技能详解

### 神圣冲击（Holy Blast）

**核心机制：追踪光柱 + 目标切换**

发射一道从天而降的光柱，持续对范围内敌人造成魔法伤害。光柱会追踪目标移动，目标死亡后以80像素/秒的速度移动到下一个敌人位置。

- 光柱伤害范围：50像素
- 伤害间隔：0.25秒
- 目标选择：优先血量最高的敌人
- 目标切换：死亡后自动寻找新目标（优先血量上限最高），无目标则结束
- 飞行单位：光柱瞄准地面位置

| 等级 | 价格 | 冷却 | 持续时间 | 每次伤害 | 索敌范围 |
|------|------|------|----------|----------|----------|
| 1 | 250 | 30秒 | 4秒 | 12~16 | 200 |
| 2 | 200 | 26秒 | 5秒 | 16~20 | 200 |
| 3 | 200 | 22秒 | 6秒 | 20~24 | 200 |

---

### 折射阵列（Nuclear Meltdown）

**核心机制：减甲 + 叠层光爆**

升级后，普攻和光柱伤害都会为敌人附加 **神圣侵蚀** modifier

#### 神圣侵蚀

- 持续时间：5秒
- 每次命中削减 10% 物理抗性和魔法抗性（上限10%）
- 叠层独立于减甲，不因光爆触发而重置


#### 光爆（叠层触发）

同一敌人叠满2层神圣侵蚀后触发光爆：
- 向200像素范围内随机敌人发射魔法光束
- 每道光束造成20~35魔法伤害
- 射线数随等级增加：Lv1=2道、Lv2=3道、Lv3=4道
- 触发后叠层清零

| 等级 | 价格 | 减甲 | 光爆射线数 |
|------|------|------|-----------|
| 1 | 225 | 10%双抗 | 2 |
| 2 | 150 | 10%双抗 | 3 |
| 3 | 150 | 10%双抗 | 4 |

**与神圣冲击的联动**：升级折射阵列后，神圣冲击的光柱伤害也会附加神圣侵蚀modifier，加速叠层触发光爆。

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
| `tower_price` | 280 | 塔价格 |
| `damage_factor` | 1.0 | 伤害倍率 |
| `cooldown_factor` | 1.0 | 冷却倍率 |
| `attack_range` | 200 | 攻击范围（像素） |
| `attack_cooldown` | 1.0 | 普攻冷却时间（秒） |
| `attack_damage_min` | 54 | 普攻最小伤害 |
| `attack_damage_max` | 66 | 普攻最大伤害 |

### 神圣冲击技能

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `holy_blast_price_base` | 250 | 基础价格 |
| `holy_blast_price_inc` | 200 | 每级价格增量 |
| `holy_blast_cooldown_1/2/3` | 30/26/22 | 各级冷却（秒） |
| `holy_blast_damage_min_1/2/3` | 12/16/20 | 各级最小伤害 |
| `holy_blast_damage_max_1/2/3` | 16/20/24 | 各级最大伤害 |
| `holy_blast_duration_1/2/3` | 4/5/6 | 各级持续时间（秒） |
| `holy_blast_damage_radius` | 50 | 伤害范围（像素） |
| `ultimate_damage_every` | 0.25 | 光柱伤害间隔（秒） |
| `ultimate_max_speed` | 80 | 光柱移动速度（像素/秒） |

### 折射阵列技能

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `nuclear_meltdown_price_base` | 225 | 基础价格 |
| `nuclear_meltdown_price_inc` | 150 | 每级价格增量 |
| `erosion_duration` | 5 | 神圣侵蚀持续时间（秒） |
| `erosion_armor_reduction` | 0.1 | 每次减甲比例（10%） |
| `light_explosion_damage_min` | 20 | 光爆最小伤害 |
| `light_explosion_damage_max` | 35 | 光爆最大伤害 |
| `light_explosion_ray_count_base` | 1 | 光爆基础射线数 |
| `light_explosion_ray_count_per_level` | 1 | 光爆每级增加射线数 |

### 视觉参数

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `crystal_base_y` | 75 | 水晶漂浮基础Y位置（像素） |
| `crystal_amplitude` | 6 | 水晶漂浮幅度（像素） |
| `crystal_period` | 3.0 | 水晶漂浮周期（秒） |
| `holy_blast_shake_amplitude` | 0 | 神圣冲击震动幅度 |
| `holy_blast_shake_extra_duration` | 0.5 | 神圣冲击震动额外时长（秒） |
| `holy_blast_shake_freq_factor` | 4 | 神圣冲击震动频率因子 |
| `sprite_tower_scale` | 0.62 | 主塔缩放比例 |

---
## 文件结构

```
Shining_Holy_Nuclear_Tower/
├── config.lua                              # Mod元数据（名称、版本、作者）
├── Shining_Holy_Nuclear_Tower.lua          # 入口文件（hook注册、菜单注入、天赋注入）
├── Shining_Holy_Nuclear_Tower_config.lua   # 配置文件（所有数值参数）
├── Shining_Holy_Nuclear_Tower_scripts.lua  # 脚本文件（modifier逻辑、光柱行为）
├── Shining_Holy_Nuclear_Tower_templates.lua# 模板文件（塔/子弹/modifier实体定义）
├── animations.lua                          # 动画定义（当前为空）
└── assets/
    ├── images/
    │   ├── Shining_Holy_Nuclear_Tower_game.lua # 贴图定义
    │   ├── achievement_icons_0015.png          # 建造按钮图标
    │   ├── crystal.png                         # 漂浮水晶贴图
    │   ├── holy_nuclear_tower.png              # 塔主体贴图
    │   ├── power_icon1.png                     # 神圣冲击技能图标
    │   └── power_icon2.png                     # 折射阵列技能图标
    ├── sounds/
    │   └── sounds.lua                          # 音效定义
    └── strings/
        └── zh-Hans.lua                         # 中文本地化
```

---
## 更新日志
- **1.0.3**：
- 删除无用配置项
- **1.0.2**：
- 文本修复
- **1.0.1**：
- 资源引用优化
- **1.0.0**：
- 正式版发布，代码优化（滴答干的）
- 补全游戏内音效
