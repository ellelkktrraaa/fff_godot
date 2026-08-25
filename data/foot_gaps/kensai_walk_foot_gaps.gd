# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name KENSAI_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KENSAI_WALK_FOOT: Array[int] = [21, 21, 22, 36, 43, 36, 33, 33, 33, 33, 42, 44]

## 每帧头顶偏移（head_gap）
const KENSAI_WALK_HEAD: Array[int] = [84, 84, 85, 80, 82, 88, 83, 77, 81, 88, 81, 76]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KENSAI_WALK_CENTER: Array[float] = [-43.5, -43.5, -43.5, -44.0, -44.0, -31.5, -43.5, -44.5, -45.5, -32.5, -44.0, -44.5]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_WALK_CONTENT_W: Array[int] = [379, 379, 379, 380, 380, 403, 379, 381, 381, 405, 380, 381]
const KENSAI_WALK_CONTENT_H: Array[int] = [663, 663, 661, 652, 643, 644, 652, 658, 654, 647, 645, 648]

## 汇总（median）
const KENSAI_WALK_FOOT_MEDIAN: int = 34
const KENSAI_WALK_HEAD_MEDIAN: int = 82
const KENSAI_WALK_CENTER_MEDIAN: float = -43.5
const KENSAI_WALK_HEIGHT_MEDIAN: int = 652
