# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name BARD_ATTACK_NOTE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BARD_ATTACK_NOTE_FOOT: Array[int] = [57, 50, 43, 49, 58, 58]

## 每帧头顶偏移（head_gap）
const BARD_ATTACK_NOTE_HEAD: Array[int] = [38, 26, 21, 26, 39, 37]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BARD_ATTACK_NOTE_CENTER: Array[float] = [-13.0, -14.25, -13.5, -13.75, -12.75, -12.75]

## 每帧内容尺寸（content_w / content_h）
const BARD_ATTACK_NOTE_CONTENT_W: Array[int] = [144, 163, 174, 160, 144, 144]
const BARD_ATTACK_NOTE_CONTENT_H: Array[int] = [290, 309, 321, 310, 288, 290]

## 汇总（median）
const BARD_ATTACK_NOTE_FOOT_MEDIAN: int = 57
const BARD_ATTACK_NOTE_HEAD_MEDIAN: int = 37
const BARD_ATTACK_NOTE_CENTER_MEDIAN: float = -13.0
const BARD_ATTACK_NOTE_HEIGHT_MEDIAN: int = 309
