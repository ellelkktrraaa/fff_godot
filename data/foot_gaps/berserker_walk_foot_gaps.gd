# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name BERSERKER_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_WALK_FOOT: Array[int] = [9, 19, 5, 10, 20, 3, 13]

## 每帧头顶偏移（head_gap）
const BERSERKER_WALK_HEAD: Array[int] = [49, 32, 31, 46, 31, 31, 44]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_WALK_CENTER: Array[float] = [-5.5, -2.5, -1.5, 3.0, -2.5, 0.0, -23.0]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_WALK_CONTENT_W: Array[int] = [485, 601, 411, 444, 601, 414, 460]
const BERSERKER_WALK_CONTENT_H: Array[int] = [710, 717, 732, 712, 717, 734, 711]

## 汇总（median）
const BERSERKER_WALK_FOOT_MEDIAN: int = 10
const BERSERKER_WALK_HEAD_MEDIAN: int = 32
const BERSERKER_WALK_CENTER_MEDIAN: float = -2.5
const BERSERKER_WALK_HEIGHT_MEDIAN: int = 717
