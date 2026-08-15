# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name BARD_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BARD_ATTACK_FOOT: Array[int] = [17, 17, 17, 17, 17, 17, 20, 17]

## 每帧头顶偏移（head_gap）
const BARD_ATTACK_HEAD: Array[int] = [21, 19, 19, 23, 31, 38, 38, 33]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BARD_ATTACK_CENTER: Array[float] = [1.5, 1.0, 1.5, 1.5, 1.0, 1.0, 0.5, -1.5]

## 每帧内容尺寸（content_w / content_h）
const BARD_ATTACK_CONTENT_W: Array[int] = [703, 732, 623, 659, 634, 678, 715, 723]
const BARD_ATTACK_CONTENT_H: Array[int] = [730, 732, 732, 728, 720, 713, 710, 718]

## 汇总（median）
const BARD_ATTACK_FOOT_MEDIAN: int = 17
const BARD_ATTACK_HEAD_MEDIAN: int = 31
const BARD_ATTACK_CENTER_MEDIAN: float = 1.0
const BARD_ATTACK_HEIGHT_MEDIAN: int = 728