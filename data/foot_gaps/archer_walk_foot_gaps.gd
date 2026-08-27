# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name ARCHER_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ARCHER_WALK_FOOT: Array[int] = [21, 22, 23, 23, 23, 25, 31, 33, 29, 21, 23, 23, 23, 23, 25, 31, 33]

## 每帧头顶偏移（head_gap）
const ARCHER_WALK_HEAD: Array[int] = [22, 15, 7, 7, 21, 24, 13, 5, 15, 23, 13, 5, 10, 25, 18, 8, 5]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ARCHER_WALK_CENTER: Array[float] = [-15.0, -18.0, -21.0, -26.0, -24.0, -23.0, -27.0, -18.0, -12.0, -6.0, -17.0, -22.0, -28.0, -11.0, -31.5, -24.0, -16.0]

## 每帧内容尺寸（content_w / content_h）
const ARCHER_WALK_CONTENT_W: Array[int] = [340, 338, 336, 334, 350, 356, 332, 338, 342, 358, 340, 338, 334, 380, 333, 334, 342]
const ARCHER_WALK_CONTENT_H: Array[int] = [725, 731, 738, 738, 724, 719, 724, 730, 724, 724, 732, 740, 735, 720, 725, 729, 730]

## 汇总（median）
const ARCHER_WALK_FOOT_MEDIAN: int = 23
const ARCHER_WALK_HEAD_MEDIAN: int = 13
const ARCHER_WALK_CENTER_MEDIAN: float = -21.0
const ARCHER_WALK_HEIGHT_MEDIAN: int = 729
