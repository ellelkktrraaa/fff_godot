# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1024x768

class_name KENSAI_ATTACK2_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KENSAI_ATTACK2_FOOT: Array[int] = [251, 251, 251, 251, 244, 250, 243]

## 每帧头顶偏移（head_gap）
const KENSAI_ATTACK2_HEAD: Array[int] = [293, 283, 277, 274, 262, 256, 262]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
## 注意：横斩时刀身横贯画面，用内容包围盒居中使刀身视觉与判定框对齐
const KENSAI_ATTACK2_CENTER: Array[float] = [-41.0, -21.5, 17.5, -5.5, 1.5, 3.0, 5.0]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_ATTACK2_CONTENT_W: Array[int] = [302, 319, 409, 463, 839, 840, 840]
const KENSAI_ATTACK2_CONTENT_H: Array[int] = [224, 234, 240, 243, 262, 262, 263]

## 汇总（median）
const KENSAI_ATTACK2_FOOT_MEDIAN: int = 251
const KENSAI_ATTACK2_HEAD_MEDIAN: int = 274
const KENSAI_ATTACK2_CENTER_MEDIAN: float = 1.5
const KENSAI_ATTACK2_HEIGHT_MEDIAN: int = 243
