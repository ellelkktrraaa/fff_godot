# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 540x540

class_name ROSE_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ROSE_ATTACK_FOOT: Array[int] = [41, 50, 52, 53, 53, 53, 53, 49, 35, 25]

## 每帧头顶偏移（head_gap）
const ROSE_ATTACK_HEAD: Array[int] = [0, 12, 59, 76, 76, 76, 76, 70, 54, 47]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ROSE_ATTACK_CENTER: Array[float] = [-5.5, -51.25, 10.25, 11.75, 20.75, 22.75, 20.0, 25.25, 24.5, 12.25]

## 每帧内容尺寸（content_w / content_h）
const ROSE_ATTACK_CONTENT_W: Array[int] = [358, 407, 520, 517, 499, 495, 500, 490, 486, 477]
const ROSE_ATTACK_CONTENT_H: Array[int] = [499, 479, 429, 412, 412, 412, 412, 422, 452, 469]

## 汇总（median）
const ROSE_ATTACK_FOOT_MEDIAN: int = 52
const ROSE_ATTACK_HEAD_MEDIAN: int = 70
const ROSE_ATTACK_CENTER_MEDIAN: float = 20.0
const ROSE_ATTACK_HEIGHT_MEDIAN: int = 429
