# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name KENSAI_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KENSAI_WALK_FOOT: Array[int] = [11, 11, 11, 18, 22, 18, 17, 17, 17, 17, 21, 22]

## 每帧头顶偏移（head_gap）
const KENSAI_WALK_HEAD: Array[int] = [42, 42, 43, 40, 41, 44, 42, 39, 41, 44, 41, 38]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KENSAI_WALK_CENTER: Array[float] = [-21.75, -21.75, -21.75, -22.0, -22.0, -15.75, -21.75, -22.25, -22.75, -16.25, -22.0, -22.25]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_WALK_CONTENT_W: Array[int] = [190, 190, 190, 190, 190, 202, 190, 191, 191, 203, 190, 191]
const KENSAI_WALK_CONTENT_H: Array[int] = [332, 332, 331, 326, 322, 322, 326, 329, 327, 324, 323, 324]

## 汇总（median）
const KENSAI_WALK_FOOT_MEDIAN: int = 17
const KENSAI_WALK_HEAD_MEDIAN: int = 41
const KENSAI_WALK_CENTER_MEDIAN: float = -21.75
const KENSAI_WALK_HEIGHT_MEDIAN: int = 326
