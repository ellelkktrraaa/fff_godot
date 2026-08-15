# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name ROSE_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ROSE_IDLE_FOOT: Array[int] = [47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47, 47]

## 每帧头顶偏移（head_gap）
const ROSE_IDLE_HEAD: Array[int] = [48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ROSE_IDLE_CENTER: Array[float] = [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0]

## 每帧内容尺寸（content_w / content_h）
const ROSE_IDLE_CONTENT_W: Array[int] = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
const ROSE_IDLE_CONTENT_H: Array[int] = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]

## 汇总（median）
const ROSE_IDLE_FOOT_MEDIAN: int = 47
const ROSE_IDLE_HEAD_MEDIAN: int = 48
const ROSE_IDLE_CENTER_MEDIAN: float = 5.0
const ROSE_IDLE_HEIGHT_MEDIAN: int = 0
