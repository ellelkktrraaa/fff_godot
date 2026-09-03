# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x512

class_name KENSAI_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KENSAI_JUMP_FOOT: Array[int] = [82, 82, 82, 95, 129, 141, 127, 77]

## 每帧头顶偏移（head_gap）
const KENSAI_JUMP_HEAD: Array[int] = [125, 138, 102, 63, 58, 54, 61, 93]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
## 注意：以人物头部/身体中心为基准（包围盒含刀身偏右，会导致跳跃中人物左右漂移）
const KENSAI_JUMP_CENTER: Array[float] = [32.25, 36.75, 22.75, 32.25, 35.75, 36.75, 34.75, 29.25]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_JUMP_CONTENT_W: Array[int] = [243, 255, 240, 245, 262, 263, 262, 249]
const KENSAI_JUMP_CONTENT_H: Array[int] = [306, 293, 329, 354, 326, 318, 324, 343]

## 汇总（median）
const KENSAI_JUMP_FOOT_MEDIAN: int = 95
const KENSAI_JUMP_HEAD_MEDIAN: int = 93
const KENSAI_JUMP_CENTER_MEDIAN: float = 34.75
const KENSAI_JUMP_HEIGHT_MEDIAN: int = 326
