# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1344x768

class_name KNIGHT_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KNIGHT_ATTACK_FOOT: Array[int] = [37, 37, 37, 49, 49, 49, 49, 49]

## 每帧头顶偏移（head_gap）
const KNIGHT_ATTACK_HEAD: Array[int] = [72, 72, 74, 196, 153, 137, 138, 140]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KNIGHT_ATTACK_CENTER: Array[float] = [-6.0, -6.0, 24.0, 37.0, 58.0, 55.5, 57.0, 57.5]

## 每帧内容尺寸（content_w / content_h）
const KNIGHT_ATTACK_CONTENT_W: Array[int] = [470, 470, 530, 1024, 1078, 1095, 1096, 1095]
const KNIGHT_ATTACK_CONTENT_H: Array[int] = [659, 659, 657, 523, 566, 582, 581, 579]

## 汇总（median）
const KNIGHT_ATTACK_FOOT_MEDIAN: int = 49
const KNIGHT_ATTACK_HEAD_MEDIAN: int = 138
const KNIGHT_ATTACK_CENTER_MEDIAN: float = 55.5
const KNIGHT_ATTACK_HEIGHT_MEDIAN: int = 582
