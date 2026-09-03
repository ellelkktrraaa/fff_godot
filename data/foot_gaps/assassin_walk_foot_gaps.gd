# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name ASSASSIN_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASSASSIN_WALK_FOOT: Array[int] = [36, 38, 50, 47, 37, 28, 28, 30, 33, 58, 44, 32, 31, 30, 32]

## 每帧头顶偏移（head_gap）
const ASSASSIN_WALK_HEAD: Array[int] = [58, 51, 47, 44, 47, 50, 52, 50, 46, 45, 47, 49, 53, 53, 51]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASSASSIN_WALK_CENTER: Array[float] = [-31.5, -28.75, -14.75, -11.0, -11.5, -12.5, -27.0, -31.0, -23.0, -19.25, -17.0, -18.5, -28.75, -31.5, -29.5]

## 每帧内容尺寸（content_w / content_h）
const ASSASSIN_WALK_CONTENT_W: Array[int] = [232, 240, 253, 254, 253, 248, 225, 236, 259, 271, 274, 271, 244, 234, 236]
const ASSASSIN_WALK_CONTENT_H: Array[int] = [291, 295, 288, 294, 301, 307, 305, 305, 306, 282, 294, 304, 301, 302, 302]

## 汇总（median）
const ASSASSIN_WALK_FOOT_MEDIAN: int = 33
const ASSASSIN_WALK_HEAD_MEDIAN: int = 50
const ASSASSIN_WALK_CENTER_MEDIAN: float = -23.0
const ASSASSIN_WALK_HEIGHT_MEDIAN: int = 301
