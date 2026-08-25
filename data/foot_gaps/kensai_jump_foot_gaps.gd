# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x1024

class_name KENSAI_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KENSAI_JUMP_FOOT: Array[int] = [164, 163, 163, 190, 257, 281, 254, 153]

## 每帧头顶偏移（head_gap）
const KENSAI_JUMP_HEAD: Array[int] = [249, 275, 204, 126, 116, 108, 122, 186]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
## 注意：以人物头部/身体中心为基准（包围盒含刀身偏右，会导致跳跃中人物左右漂移）
const KENSAI_JUMP_CENTER: Array[float] = [64.5, 73.5, 45.5, 64.5, 71.5, 73.5, 69.5, 58.5]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_JUMP_CONTENT_W: Array[int] = [486, 510, 479, 489, 523, 526, 523, 497]
const KENSAI_JUMP_CONTENT_H: Array[int] = [611, 586, 657, 708, 651, 635, 648, 685]

## 汇总（median）
const KENSAI_JUMP_FOOT_MEDIAN: int = 190
const KENSAI_JUMP_HEAD_MEDIAN: int = 186
const KENSAI_JUMP_CENTER_MEDIAN: float = 69.5
const KENSAI_JUMP_HEIGHT_MEDIAN: int = 651
