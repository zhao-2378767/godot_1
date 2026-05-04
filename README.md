# Godot 4.x 俯视角肉鸽小游戏入门项目

这是一个可以直接用 Godot 4.x 打开的最小可运行项目。

## 已包含功能

- WASD 移动
- 摄像机跟随玩家
- 敌人自动生成
- 敌人追踪玩家
- 玩家自动攻击最近敌人
- 子弹击中敌人
- 敌人死亡消失
- 玩家血量
- 击杀数 UI
- 经验系统
- 升级五选一：子弹数量 +1、攻速 +1、穿透 +1、分裂 +1、攻击力 +1
- 游戏结束提示

## 如何运行

1. 解压 zip 文件
2. 打开 Godot 4.x
3. 点击“导入”
4. 选择本项目文件夹里的 `project.godot`
5. 打开项目后点击右上角运行按钮

## 主要文件

- `scenes/Main.tscn`：主场景
- `scenes/Player.tscn`：玩家
- `scenes/Enemy.tscn`：敌人
- `scenes/Bullet.tscn`：子弹
- `scenes/UI.tscn`：界面和升级选择
- `scripts/game_manager.gd`：敌人生成、击杀、经验、升级流程
- `scripts/player.gd`：移动、自动攻击、升级属性
- `scripts/bullet.gd`：伤害、穿透、分裂
- `scripts/enemy.gd`：敌人追踪、受伤、死亡
- `scripts/ui.gd`：血量、经验、升级按钮 UI
