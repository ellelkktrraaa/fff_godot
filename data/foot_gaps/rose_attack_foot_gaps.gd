# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1080x1080

class_name ROSE_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ROSE_ATTACK_FOOT: Array[int] = [82, 99, 104, 105, 105, 105, 105, 98, 69, 50]

## 每帧头顶偏移（head_gap）
const ROSE_ATTACK_HEAD: Array[int] = [0, 24, 118, 152, 152, 152, 152, 139, 107, 93]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ROSE_ATTACK_CENTER: Array[float] = [-11.0, -102.5, 20.5, 23.5, 41.5, 45.5, 40.0, 50.5, 49.0, 24.5]

## 每帧内容尺寸（content_w / content_h）
const ROSE_ATTACK_CONTENT_W: Array[int] = [716, 813, 1039, 1033, 997, 989, 1000, 979, 972, 953]
const ROSE_ATTACK_CONTENT_H: Array[int] = [998, 957, 858, 823, 823, 823, 823, 843, 904, 937]

## 汇总（median）
const ROSE_ATTACK_FOOT_MEDIAN: int = 104
const ROSE_ATTACK_HEAD_MEDIAN: int = 139
const ROSE_ATTACK_CENTER_MEDIAN: float = 40.0
const ROSE_ATTACK_HEIGHT_MEDIAN: int = 858
