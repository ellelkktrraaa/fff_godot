# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name ASTROLOGER_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASTROLOGER_ATTACK_FOOT: Array[int] = [13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13]

## 每帧头顶偏移（head_gap）
const ASTROLOGER_ATTACK_HEAD: Array[int] = [17, 17, 17, 17, 17, 17, 8, 6, 0, 0, 0, 2, 5, 5]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASTROLOGER_ATTACK_CENTER: Array[float] = [-20.0, -17.5, -17.0, -19.0, -17.75, -9.5, -3.0, -2.0, 1.25, 2.0, -1.0, -1.0, -1.5, -2.0]

## 每帧内容尺寸（content_w / content_h）
const ASTROLOGER_ATTACK_CONTENT_W: Array[int] = [239, 244, 245, 241, 244, 260, 273, 275, 282, 283, 277, 277, 276, 275]
const ASTROLOGER_ATTACK_CONTENT_H: Array[int] = [355, 355, 355, 355, 355, 355, 364, 366, 372, 372, 372, 370, 367, 367]

## 汇总（median）
const ASTROLOGER_ATTACK_FOOT_MEDIAN: int = 13
const ASTROLOGER_ATTACK_HEAD_MEDIAN: int = 8
const ASTROLOGER_ATTACK_CENTER_MEDIAN: float = -2.0
const ASTROLOGER_ATTACK_HEIGHT_MEDIAN: int = 366
