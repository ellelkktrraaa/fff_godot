# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 512x384

class_name BERSERKER_SKILL2_PARRY_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_SKILL2_PARRY_FOOT: Array[int] = [5, 5, 9, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11]

## 每帧头顶偏移（head_gap）
const BERSERKER_SKILL2_PARRY_HEAD: Array[int] = [7, 9, 12, 4, 19, 16, 17, 18, 18, 21, 24, 26, 27, 27, 25, 23, 22]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_SKILL2_PARRY_CENTER: Array[float] = [21.75, 19.75, 3.75, -3.75, -6.75, -6.75, -7.5, -8.25, -8.75, -10.0, -12.0, -13.25, -13.75, -13.5, -12.25, -10.5, -9.75]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_SKILL2_PARRY_CONTENT_W: Array[int] = [191, 190, 189, 210, 257, 257, 257, 258, 258, 258, 259, 259, 259, 259, 259, 258, 258]
const BERSERKER_SKILL2_PARRY_CONTENT_H: Array[int] = [373, 371, 363, 370, 355, 357, 356, 356, 355, 353, 349, 347, 347, 347, 349, 351, 352]

## 汇总（median）
const BERSERKER_SKILL2_PARRY_FOOT_MEDIAN: int = 11
const BERSERKER_SKILL2_PARRY_HEAD_MEDIAN: int = 19
const BERSERKER_SKILL2_PARRY_CENTER_MEDIAN: float = -8.75
const BERSERKER_SKILL2_PARRY_HEIGHT_MEDIAN: int = 355
