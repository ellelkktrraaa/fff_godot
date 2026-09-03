# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 540x750

class_name ASTROLOGER_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASTROLOGER_IDLE_FOOT: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

## 每帧头顶偏移（head_gap）
const ASTROLOGER_IDLE_HEAD: Array[int] = [36, 36, 35, 35, 35, 35, 34, 34, 34, 34, 34, 34, 34, 34, 34]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASTROLOGER_IDLE_CENTER: Array[float] = [7.5, 7.5, 6.5, 7.25, 7.5, 7.5, 7.5, -9.75, 4.5, -3.0, -1.25, 1.0, -9.0, -9.25, -9.25]

## 每帧内容尺寸（content_w / content_h）
const ASTROLOGER_IDLE_CONTENT_W: Array[int] = [525, 525, 523, 526, 525, 525, 525, 491, 519, 504, 508, 512, 492, 492, 492]
const ASTROLOGER_IDLE_CONTENT_H: Array[int] = [714, 715, 715, 715, 716, 716, 716, 716, 716, 716, 717, 717, 717, 717, 717]

## 汇总（median）
const ASTROLOGER_IDLE_FOOT_MEDIAN: int = 0
const ASTROLOGER_IDLE_HEAD_MEDIAN: int = 34
const ASTROLOGER_IDLE_CENTER_MEDIAN: float = 4.5
const ASTROLOGER_IDLE_HEIGHT_MEDIAN: int = 716
