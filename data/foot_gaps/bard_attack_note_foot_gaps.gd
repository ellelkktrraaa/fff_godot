# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name BARD_ATTACK_NOTE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BARD_ATTACK_NOTE_FOOT: Array[int] = [113, 100, 86, 98, 116, 116]

## 每帧头顶偏移（head_gap）
const BARD_ATTACK_NOTE_HEAD: Array[int] = [75, 51, 41, 51, 77, 73]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BARD_ATTACK_NOTE_CENTER: Array[float] = [-26.0, -28.5, -27.0, -27.5, -25.5, -25.5]

## 每帧内容尺寸（content_w / content_h）
const BARD_ATTACK_NOTE_CONTENT_W: Array[int] = [288, 325, 348, 319, 287, 287]
const BARD_ATTACK_NOTE_CONTENT_H: Array[int] = [580, 617, 641, 619, 575, 579]

## 汇总（median）
const BARD_ATTACK_NOTE_FOOT_MEDIAN: int = 113
const BARD_ATTACK_NOTE_HEAD_MEDIAN: int = 73
const BARD_ATTACK_NOTE_CENTER_MEDIAN: float = -26.0
const BARD_ATTACK_NOTE_HEIGHT_MEDIAN: int = 617
