# 代码问题清单（静态审查）

## 1) 子弹可能对同一敌人造成双重命中
- 文件：`scripts/bullet.gd`
- 位置：`_physics_process()` 中每帧调用 `_check_manual_hit()`，同时在 `_ready()` 里又连接了 `body_entered/area_entered`。
- 问题：同一帧内既可能触发手动距离检测命中，也可能触发碰撞信号命中。虽然 `_hit_enemy_ids` 有去重，但去重是在 `_hit_enemy()` 内，逻辑上存在重复检测成本，且会造成行为调试困难。
- 建议：二选一（仅用碰撞信号，或仅用手动检测），避免两套命中路径并存。

## 2) `area_entered` 分支在当前敌人实现下基本无效
- 文件：`scripts/bullet.gd` 与 `scripts/enemy.gd`
- 位置：`_on_area_entered(area: Area2D)` 与敌人脚本 `extends CharacterBody2D`。
- 问题：敌人不是 `Area2D`，通常不会走 `area_entered` 回调，导致这段逻辑在当前工程里几乎不可达。
- 建议：删除无效分支，或将敌人碰撞模型改为 `Area2D`（二选一并保持一致）。

## 3) 分裂子弹的穿透值会被额外扣减，可能与设计不符
- 文件：`scripts/bullet.gd`
- 位置：`_spawn_split_bullets()` 中 `max(pierce_left - 1, 0)`。
- 问题：原子弹命中后若仍有 `pierce_left`，分裂子弹再继承时又减 1，等于“分裂再额外损失一次穿透层数”。
- 影响：玩家升级“穿透”收益被隐式削弱。
- 建议：如果期望“分裂继承当前剩余穿透”，改为 `pierce_left`；若是特性设计，建议在 UI 文案明确。

## 4) 角色死亡后未阻止重复触发 `died` 信号
- 文件：`scripts/player.gd`
- 位置：`take_damage()`。
- 问题：`current_health <= 0` 时直接 `died.emit()`；如果外部在暂停前再次调用 `take_damage`，可能重复发出死亡信号。
- 建议：加 `_is_dead` 标志位并在死亡后提前返回。

## 5) 自动攻击目标类型约束不严格
- 文件：`scripts/player.gd`
- 位置：`_find_nearest_enemy()`。
- 问题：函数返回 `Node2D`，但分组内节点理论上可能混入非 `Node2D`，`enemy.global_position` 会报错。
- 建议：遍历时先做 `enemy is Node2D` 判断或显式强转并判空。

## 6) 游戏暂停与界面状态耦合，容易残留暂停态
- 文件：`scripts/game_manager.gd`
- 位置：`_level_up()` / `_on_upgrade_selected()` / `_on_player_died()`。
- 问题：升级面板与死亡都通过 `get_tree().paused` 控制，若未来新增弹窗或切场景，可能出现暂停状态未恢复。
- 建议：引入集中状态机（Playing / LevelUp / GameOver）统一管理暂停与 UI。

## 7) 经验阈值初始化重复，维护性一般
- 文件：`scripts/game_manager.gd`
- 位置：变量定义 `next_level_exp := 5` 与 `_ready()` 再赋值 `first_level_exp`。
- 问题：同一参数有两个来源，后续改默认值时容易遗漏。
- 建议：直接 `var next_level_exp := first_level_exp`（或在 `_ready` 前统一初始化路径）。

---

以上为静态代码审查结果，未结合运行时场景树/碰撞层配置进行实机验证。
