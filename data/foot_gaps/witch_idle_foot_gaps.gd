# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name WITCH_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const WITCH_IDLE_FOOT: Array[int] = [8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8]

## 每帧头顶偏移（head_gap）
const WITCH_IDLE_HEAD: Array[int] = [11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const WITCH_IDLE_CENTER: Array[float] = [-7.25, -9.0, -9.0, -8.5, -8.5, -7.0, -6.0, -5.5, -4.25, -4.0, -4.0, -4.0, -4.0, -4.0, -4.0, -4.25, -4.75]

## 每帧内容尺寸（content_w / content_h）
const WITCH_IDLE_CONTENT_W: Array[int] = [228, 231, 231, 230, 230, 227, 225, 224, 222, 221, 221, 221, 221, 221, 221, 222, 223]
const WITCH_IDLE_CONTENT_H: Array[int] = [366, 366, 366, 366, 366, 366, 366, 366, 366, 366, 366, 366, 366, 366, 366, 366, 366]

## 汇总（median）
const WITCH_IDLE_FOOT_MEDIAN: int = 8
const WITCH_IDLE_HEAD_MEDIAN: int = 11
const WITCH_IDLE_CENTER_MEDIAN: float = -4.75
const WITCH_IDLE_HEIGHT_MEDIAN: int = 366
