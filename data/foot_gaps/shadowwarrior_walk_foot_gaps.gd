# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 512x384

class_name SHADOWWARRIOR_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const SHADOWWARRIOR_WALK_FOOT: Array[int] = [22, 22, 18, 17, 18, 17, 34, 30, 21, 19, 19, 20, 28, 26]

## 每帧头顶偏移（head_gap）
const SHADOWWARRIOR_WALK_HEAD: Array[int] = [39, 39, 41, 44, 45, 43, 38, 37, 39, 41, 44, 41, 38, 37]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const SHADOWWARRIOR_WALK_CENTER: Array[float] = [-11.5, -11.5, -14.5, -14.75, -14.75, -14.5, -14.5, -13.5, -14.75, -15.0, -15.0, -14.75, -14.75, -14.0]

## 每帧内容尺寸（content_w / content_h）
const SHADOWWARRIOR_WALK_CONTENT_W: Array[int] = [292, 292, 285, 285, 285, 285, 286, 288, 286, 285, 285, 286, 286, 286]
const SHADOWWARRIOR_WALK_CONTENT_H: Array[int] = [324, 324, 325, 323, 322, 324, 313, 317, 325, 324, 322, 324, 319, 322]

## 汇总（median）
const SHADOWWARRIOR_WALK_FOOT_MEDIAN: int = 21
const SHADOWWARRIOR_WALK_HEAD_MEDIAN: int = 41
const SHADOWWARRIOR_WALK_CENTER_MEDIAN: float = -14.5
const SHADOWWARRIOR_WALK_HEIGHT_MEDIAN: int = 324
