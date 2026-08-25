# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1024x768

class_name SHADOWWARRIOR_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const SHADOWWARRIOR_WALK_FOOT: Array[int] = [43, 43, 36, 34, 35, 34, 68, 60, 41, 38, 37, 39, 56, 52]

## 每帧头顶偏移（head_gap）
const SHADOWWARRIOR_WALK_HEAD: Array[int] = [77, 77, 82, 88, 89, 86, 75, 74, 77, 82, 87, 81, 75, 73]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const SHADOWWARRIOR_WALK_CENTER: Array[float] = [-23.0, -23.0, -29.0, -29.5, -29.5, -29.0, -29.0, -27.0, -29.5, -30.0, -30.0, -29.5, -29.5, -28.0]

## 每帧内容尺寸（content_w / content_h）
const SHADOWWARRIOR_WALK_CONTENT_W: Array[int] = [584, 584, 570, 569, 569, 570, 572, 576, 571, 570, 570, 571, 571, 572]
const SHADOWWARRIOR_WALK_CONTENT_H: Array[int] = [648, 648, 650, 646, 644, 648, 625, 634, 650, 648, 644, 648, 637, 643]

## 汇总（median）
const SHADOWWARRIOR_WALK_FOOT_MEDIAN: int = 41
const SHADOWWARRIOR_WALK_HEAD_MEDIAN: int = 81
const SHADOWWARRIOR_WALK_CENTER_MEDIAN: float = -29.0
const SHADOWWARRIOR_WALK_HEIGHT_MEDIAN: int = 648
