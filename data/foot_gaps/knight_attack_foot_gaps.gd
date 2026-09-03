# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 672x384

class_name KNIGHT_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_ATTACK_FOOT: Array[int] = [19, 19, 19, 25, 25, 25, 25, 25]

## 每帧头顶偏移（head_gap）
const KNIGHT_ATTACK_HEAD: Array[int] = [36, 36, 37, 98, 77, 69, 69, 70]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_ATTACK_CENTER: Array[float] = [-3.0, -3.0, 12.0, 18.5, 29.0, 27.75, 28.5, 28.75]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_ATTACK_CONTENT_W: Array[int] = [235, 235, 265, 512, 539, 548, 548, 548]
const KNIGHT_ATTACK_CONTENT_H: Array[int] = [330, 330, 329, 262, 283, 291, 291, 290]

## 汇总（median）
const KNIGHT_ATTACK_FOOT_MEDIAN: int = 25
const KNIGHT_ATTACK_HEAD_MEDIAN: int = 69
const KNIGHT_ATTACK_CENTER_MEDIAN: float = 27.75
const KNIGHT_ATTACK_HEIGHT_MEDIAN: int = 291
