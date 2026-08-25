# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name EVOKER_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const EVOKER_IDLE_FOOT: Array[int] = [23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23]

## 每帧头顶偏移（head_gap）
const EVOKER_IDLE_HEAD: Array[int] = [51, 51, 51, 51, 51, 51, 51, 51, 51, 51, 52, 52, 52, 52, 52]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const EVOKER_IDLE_CENTER: Array[float] = [-47.0, -51.0, -53.0, -52.0, -44.0, -42.5, -50.0, -53.0, -48.0, -41.0, -47.0, -51.0, -54.0, -40.0, -43.0]

## 每帧内容尺寸（content_w / content_h）
const EVOKER_IDLE_CONTENT_W: Array[int] = [464, 472, 476, 470, 454, 451, 466, 472, 462, 448, 460, 468, 474, 446, 456]
const EVOKER_IDLE_CONTENT_H: Array[int] = [694, 694, 694, 694, 694, 694, 694, 694, 694, 694, 693, 693, 693, 693, 693]

## 汇总（median）
const EVOKER_IDLE_FOOT_MEDIAN: int = 23
const EVOKER_IDLE_HEAD_MEDIAN: int = 51
const EVOKER_IDLE_CENTER_MEDIAN: float = -48.0
const EVOKER_IDLE_HEIGHT_MEDIAN: int = 694
