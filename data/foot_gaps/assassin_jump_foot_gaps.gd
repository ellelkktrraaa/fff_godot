# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x480

class_name ASSASSIN_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASSASSIN_JUMP_FOOT: Array[int] = [96, 95, 112, 117, 123, 127, 131, 134, 136, 138, 139, 139, 139, 137, 135, 132, 130, 104, 95, 95]

## 每帧头顶偏移（head_gap）
const ASSASSIN_JUMP_HEAD: Array[int] = [179, 96, 54, 49, 45, 42, 39, 38, 36, 35, 35, 35, 35, 37, 38, 41, 43, 76, 153, 151]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASSASSIN_JUMP_CENTER: Array[float] = [-18.75, -7.0, -12.0, -11.75, -11.0, -11.0, -10.75, -10.5, -10.25, -10.0, -9.75, -9.75, -9.5, -9.0, -8.5, -8.5, -9.25, -17.75, -15.75, -17.0]

## 每帧内容尺寸（content_w / content_h）
const ASSASSIN_JUMP_CONTENT_W: Array[int] = [251, 226, 210, 213, 215, 217, 219, 220, 221, 222, 223, 224, 224, 224, 224, 225, 228, 229, 254, 255]
const ASSASSIN_JUMP_CONTENT_H: Array[int] = [206, 290, 315, 314, 313, 311, 310, 309, 308, 307, 307, 307, 307, 307, 307, 308, 308, 301, 233, 235]

## 汇总（median）
const ASSASSIN_JUMP_FOOT_MEDIAN: int = 131
const ASSASSIN_JUMP_HEAD_MEDIAN: int = 42
const ASSASSIN_JUMP_CENTER_MEDIAN: float = -10.25
const ASSASSIN_JUMP_HEIGHT_MEDIAN: int = 307
