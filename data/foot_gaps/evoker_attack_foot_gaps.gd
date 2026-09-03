# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name EVOKER_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const EVOKER_ATTACK_FOOT: Array[int] = [11, 11, 11, 11, 11, 11, 11, 11]

## 每帧头顶偏移（head_gap）
const EVOKER_ATTACK_HEAD: Array[int] = [26, 27, 27, 27, 25, 0, 25, 25]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const EVOKER_ATTACK_CENTER: Array[float] = [-20.0, -21.5, -25.0, -21.0, 1.5, 24.5, -11.0, -12.0]

## 每帧内容尺寸（content_w / content_h）
const EVOKER_ATTACK_CONTENT_W: Array[int] = [223, 226, 231, 237, 268, 312, 249, 251]
const EVOKER_ATTACK_CONTENT_H: Array[int] = [347, 347, 347, 347, 349, 373, 349, 349]

## 汇总（median）
const EVOKER_ATTACK_FOOT_MEDIAN: int = 11
const EVOKER_ATTACK_HEAD_MEDIAN: int = 26
const EVOKER_ATTACK_CENTER_MEDIAN: float = -12.0
const EVOKER_ATTACK_HEIGHT_MEDIAN: int = 349
