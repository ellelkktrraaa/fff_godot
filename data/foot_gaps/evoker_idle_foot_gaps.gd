# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name EVOKER_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const EVOKER_IDLE_FOOT: Array[int] = [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12]

## 每帧头顶偏移（head_gap）
const EVOKER_IDLE_HEAD: Array[int] = [26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const EVOKER_IDLE_CENTER: Array[float] = [-23.5, -25.5, -26.5, -26.0, -22.0, -21.25, -25.0, -26.5, -24.0, -20.5, -23.5, -25.5, -27.0, -20.0, -21.5]

## 每帧内容尺寸（content_w / content_h）
const EVOKER_IDLE_CONTENT_W: Array[int] = [232, 236, 238, 235, 227, 226, 233, 236, 231, 224, 230, 234, 237, 223, 228]
const EVOKER_IDLE_CONTENT_H: Array[int] = [347, 347, 347, 347, 347, 347, 347, 347, 347, 347, 347, 347, 347, 347, 347]

## 汇总（median）
const EVOKER_IDLE_FOOT_MEDIAN: int = 12
const EVOKER_IDLE_HEAD_MEDIAN: int = 26
const EVOKER_IDLE_CENTER_MEDIAN: float = -24.0
const EVOKER_IDLE_HEIGHT_MEDIAN: int = 347
