# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name WITCH_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const WITCH_IDLE_FOOT: Array[int] = [16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16]

## 每帧头顶偏移（head_gap）
const WITCH_IDLE_HEAD: Array[int] = [21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const WITCH_IDLE_CENTER: Array[float] = [-14.5, -18.0, -18.0, -17.0, -17.0, -14.0, -12.0, -11.0, -8.5, -8.0, -8.0, -8.0, -8.0, -8.0, -8.0, -8.5, -9.5]

## 每帧内容尺寸（content_w / content_h）
const WITCH_IDLE_CONTENT_W: Array[int] = [455, 462, 462, 460, 460, 454, 450, 448, 443, 442, 442, 442, 442, 442, 442, 443, 445]
const WITCH_IDLE_CONTENT_H: Array[int] = [731, 731, 731, 731, 731, 731, 731, 731, 731, 731, 731, 731, 731, 731, 731, 731, 731]

## 汇总（median）
const WITCH_IDLE_FOOT_MEDIAN: int = 16
const WITCH_IDLE_HEAD_MEDIAN: int = 21
const WITCH_IDLE_CENTER_MEDIAN: float = -9.5
const WITCH_IDLE_HEIGHT_MEDIAN: int = 731
