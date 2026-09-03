# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name ASTROLOGER_SKILL1_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASTROLOGER_SKILL1_FOOT: Array[int] = [14, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14]

## 每帧头顶偏移（head_gap）
const ASTROLOGER_SKILL1_HEAD: Array[int] = [18, 18, 18, 18, 18, 18, 18, 18, 13, 5, 0, 1, 0, 0, 4, 8, 10, 11, 10, 11, 13, 10, 10, 12]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASTROLOGER_SKILL1_CENTER: Array[float] = [-18.0, -18.0, -18.25, -17.25, -17.25, -17.25, -6.75, 4.75, 15.5, 21.5, 23.0, 19.0, 5.0, 8.0, 9.0, 2.25, 1.25, 2.5, -1.0, 2.0, -1.0, -5.75, 2.75, 1.5]

## 每帧内容尺寸（content_w / content_h）
const ASTROLOGER_SKILL1_CONTENT_W: Array[int] = [245, 245, 246, 248, 248, 248, 269, 304, 328, 334, 333, 335, 339, 339, 329, 327, 328, 340, 341, 337, 333, 315, 337, 348]
const ASTROLOGER_SKILL1_CONTENT_H: Array[int] = [353, 354, 354, 354, 354, 353, 353, 353, 358, 366, 371, 370, 371, 371, 367, 363, 361, 360, 361, 360, 358, 361, 361, 359]

## 汇总（median）
const ASTROLOGER_SKILL1_FOOT_MEDIAN: int = 14
const ASTROLOGER_SKILL1_HEAD_MEDIAN: int = 11
const ASTROLOGER_SKILL1_CENTER_MEDIAN: float = 2.0
const ASTROLOGER_SKILL1_HEIGHT_MEDIAN: int = 360
