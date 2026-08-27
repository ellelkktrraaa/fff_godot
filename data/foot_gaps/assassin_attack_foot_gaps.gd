# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 720x720

class_name ASSASSIN_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASSASSIN_ATTACK_FOOT: Array[int] = [74, 74, 74, 74, 74, 68, 49, 48, 48, 48, 48, 48, 48]

## 每帧头顶偏移（head_gap）
const ASSASSIN_ATTACK_HEAD: Array[int] = [160, 180, 193, 193, 190, 181, 98, 96, 96, 96, 96, 96, 96]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASSASSIN_ATTACK_CENTER: Array[float] = [-32.0, -37.5, -41.0, -41.0, -40.0, -28.5, 15.0, 14.0, 13.5, 13.5, 13.5, 13.5, 13.5]

## 每帧内容尺寸（content_w / content_h）
const ASSASSIN_ATTACK_CONTENT_W: Array[int] = [482, 493, 500, 500, 498, 499, 578, 580, 581, 581, 581, 581, 581]
const ASSASSIN_ATTACK_CONTENT_H: Array[int] = [486, 466, 453, 453, 456, 471, 573, 576, 576, 576, 576, 576, 576]

## 汇总（median）
const ASSASSIN_ATTACK_FOOT_MEDIAN: int = 49
const ASSASSIN_ATTACK_HEAD_MEDIAN: int = 98
const ASSASSIN_ATTACK_CENTER_MEDIAN: float = 13.5
const ASSASSIN_ATTACK_HEIGHT_MEDIAN: int = 573
