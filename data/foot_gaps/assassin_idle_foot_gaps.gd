# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 720x720

class_name ASSASSIN_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASSASSIN_IDLE_FOOT: Array[int] = [75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75, 75]

## 每帧头顶偏移（head_gap）
const ASSASSIN_IDLE_HEAD: Array[int] = [137, 138, 140, 143, 146, 150, 152, 153, 153, 152, 150, 147, 144, 141, 139, 138]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASSASSIN_IDLE_CENTER: Array[float] = [-21.5, -22.0, -23.0, -22.5, -22.0, -21.5, -21.0, -20.5, -20.0, -19.5, -19.5, -19.5, -19.5, -19.0, -19.5, -20.0]

## 每帧内容尺寸（content_w / content_h）
const ASSASSIN_IDLE_CONTENT_W: Array[int] = [459, 462, 464, 467, 468, 469, 468, 467, 466, 465, 463, 461, 459, 458, 457, 458]
const ASSASSIN_IDLE_CONTENT_H: Array[int] = [508, 507, 505, 502, 499, 495, 493, 492, 492, 493, 495, 498, 501, 504, 506, 507]

## 汇总（median）
const ASSASSIN_IDLE_FOOT_MEDIAN: int = 75
const ASSASSIN_IDLE_HEAD_MEDIAN: int = 146
const ASSASSIN_IDLE_CENTER_MEDIAN: float = -20.0
const ASSASSIN_IDLE_HEIGHT_MEDIAN: int = 501
