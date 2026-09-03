# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name BARD_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BARD_IDLE_FOOT: Array[int] = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]

## 每帧头顶偏移（head_gap）
const BARD_IDLE_HEAD: Array[int] = [17, 17, 17, 19, 21, 20, 20, 21, 19, 15, 13, 13, 16, 16]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BARD_IDLE_CENTER: Array[float] = [-8.5, -8.5, -8.5, -9.0, -9.25, -8.0, -7.25, -9.25, -10.75, -10.75, -8.75, -7.75, -8.25, -8.5]

## 每帧内容尺寸（content_w / content_h）
const BARD_IDLE_CONTENT_W: Array[int] = [165, 165, 165, 166, 167, 164, 163, 166, 169, 168, 165, 164, 165, 165]
const BARD_IDLE_CONTENT_H: Array[int] = [358, 358, 358, 355, 354, 354, 354, 353, 356, 359, 362, 361, 358, 358]

## 汇总（median）
const BARD_IDLE_FOOT_MEDIAN: int = 10
const BARD_IDLE_HEAD_MEDIAN: int = 17
const BARD_IDLE_CENTER_MEDIAN: float = -8.5
const BARD_IDLE_HEIGHT_MEDIAN: int = 358
