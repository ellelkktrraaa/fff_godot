# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1080x1500

class_name ASTROLOGER_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASTROLOGER_IDLE_FOOT: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

## 每帧头顶偏移（head_gap）
const ASTROLOGER_IDLE_HEAD: Array[int] = [72, 71, 70, 70, 69, 69, 68, 68, 68, 68, 67, 67, 67, 67, 67]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASTROLOGER_IDLE_CENTER: Array[float] = [15.0, 15.0, 13.0, 14.5, 15.0, 15.0, 15.0, -19.5, 9.0, -6.0, -2.5, 2.0, -18.0, -18.5, -18.5]

## 每帧内容尺寸（content_w / content_h）
const ASTROLOGER_IDLE_CONTENT_W: Array[int] = [1050, 1050, 1046, 1051, 1050, 1050, 1050, 981, 1038, 1008, 1015, 1024, 984, 983, 983]
const ASTROLOGER_IDLE_CONTENT_H: Array[int] = [1428, 1429, 1430, 1430, 1431, 1431, 1432, 1432, 1432, 1432, 1433, 1433, 1433, 1433, 1433]

## 汇总（median）
const ASTROLOGER_IDLE_FOOT_MEDIAN: int = 0
const ASTROLOGER_IDLE_HEAD_MEDIAN: int = 68
const ASTROLOGER_IDLE_CENTER_MEDIAN: float = 9.0
const ASTROLOGER_IDLE_HEIGHT_MEDIAN: int = 1432
