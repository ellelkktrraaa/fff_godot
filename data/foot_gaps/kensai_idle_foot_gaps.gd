# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name KENSAI_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KENSAI_IDLE_FOOT: Array[int] = [22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22]

## 每帧头顶偏移（head_gap）
const KENSAI_IDLE_HEAD: Array[int] = [87, 87, 87, 87, 87, 87, 86, 86, 85, 84, 83, 83, 83, 83, 83, 83, 83, 83, 83, 83, 84, 84, 85, 85, 86]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const KENSAI_IDLE_CENTER: Array[float] = [-43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -42.5, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0, -43.0]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_IDLE_CONTENT_W: Array[int] = [378, 378, 378, 378, 378, 378, 378, 378, 378, 378, 378, 378, 378, 378, 378, 378, 377, 378, 378, 378, 378, 378, 378, 378, 378]
const KENSAI_IDLE_CONTENT_H: Array[int] = [659, 659, 659, 659, 659, 659, 660, 660, 661, 662, 663, 663, 663, 663, 663, 663, 663, 663, 663, 663, 662, 662, 661, 661, 660]

## 汇总（median）
const KENSAI_IDLE_FOOT_MEDIAN: int = 22
const KENSAI_IDLE_HEAD_MEDIAN: int = 83
const KENSAI_IDLE_CENTER_MEDIAN: float = -43.0
const KENSAI_IDLE_HEIGHT_MEDIAN: int = 662
