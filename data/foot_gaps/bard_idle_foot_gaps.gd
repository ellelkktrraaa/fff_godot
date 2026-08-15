# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name BARD_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BARD_IDLE_FOOT: Array[int] = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20]

## 每帧头顶偏移（head_gap）
const BARD_IDLE_HEAD: Array[int] = [33, 33, 33, 38, 41, 40, 40, 42, 37, 30, 25, 26, 32, 32]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BARD_IDLE_CENTER: Array[float] = [-17.0, -17.0, -17.0, -18.0, -18.5, -16.0, -14.5, -18.5, -21.5, -21.5, -17.5, -15.5, -16.5, -17.0]

## 每帧内容尺寸（content_w / content_h）
const BARD_IDLE_CONTENT_W: Array[int] = [330, 330, 330, 332, 333, 328, 325, 331, 337, 335, 329, 327, 329, 330]
const BARD_IDLE_CONTENT_H: Array[int] = [715, 715, 715, 710, 707, 708, 708, 706, 711, 718, 723, 722, 716, 716]

## 汇总（median）
const BARD_IDLE_FOOT_MEDIAN: int = 20
const BARD_IDLE_HEAD_MEDIAN: int = 33
const BARD_IDLE_CENTER_MEDIAN: float = -17.0
const BARD_IDLE_HEIGHT_MEDIAN: int = 715
