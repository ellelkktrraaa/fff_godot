# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 512x384

class_name DRAGON_KNIGHT_SKILL2_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_SKILL2_FOOT: Array[int] = [45, 45, 44, 48, 49, 49, 49, 48, 48, 49, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_SKILL2_HEAD: Array[int] = [89, 0, 94, 71, 70, 70, 65, 63, 61, 60, 70, 67, 64, 61, 70, 65, 62, 61, 70, 67, 65, 62, 62, 66]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_SKILL2_CENTER: Array[float] = [29.25, -14.25, 5.75, -19.5, -27.75, -23.0, -5.0, -7.0, -10.75, -1.25, -5.0, -8.5, -11.75, -2.5, -4.0, -7.25, -9.0, -2.5, -4.0, -13.75, -10.25, -3.25, -4.75, -11.5]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_SKILL2_CONTENT_W: Array[int] = [319, 243, 351, 301, 318, 333, 339, 344, 356, 342, 340, 343, 353, 338, 339, 344, 348, 341, 341, 356, 350, 340, 343, 352]
const DRAGON_KNIGHT_SKILL2_CONTENT_H: Array[int] = [251, 339, 247, 266, 266, 266, 271, 274, 275, 276, 266, 269, 272, 275, 267, 272, 275, 276, 266, 269, 272, 275, 275, 271]

## 汇总（median）
const DRAGON_KNIGHT_SKILL2_FOOT_MEDIAN: int = 48
const DRAGON_KNIGHT_SKILL2_HEAD_MEDIAN: int = 65
const DRAGON_KNIGHT_SKILL2_CENTER_MEDIAN: float = -7.0
const DRAGON_KNIGHT_SKILL2_HEIGHT_MEDIAN: int = 272
