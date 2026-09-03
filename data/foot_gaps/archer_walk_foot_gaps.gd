# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 384x384

class_name ARCHER_WALK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ARCHER_WALK_FOOT: Array[int] = [11, 11, 12, 12, 12, 13, 16, 17, 15, 11, 12, 12, 12, 12, 13, 16, 17]

## 每帧头顶偏移（head_gap）
const ARCHER_WALK_HEAD: Array[int] = [11, 8, 4, 4, 11, 12, 7, 3, 8, 12, 7, 3, 5, 13, 9, 4, 3]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ARCHER_WALK_CENTER: Array[float] = [-7.5, -9.0, -10.5, -13.0, -12.0, -11.5, -13.5, -9.0, -6.0, -3.0, -8.5, -11.0, -14.0, -5.5, -15.75, -12.0, -8.0]

## 每帧内容尺寸（content_w / content_h）
const ARCHER_WALK_CONTENT_W: Array[int] = [170, 169, 168, 167, 175, 178, 166, 169, 171, 179, 170, 169, 167, 190, 167, 167, 171]
const ARCHER_WALK_CONTENT_H: Array[int] = [363, 366, 369, 369, 362, 360, 362, 365, 362, 362, 366, 370, 368, 360, 363, 365, 365]

## 汇总（median）
const ARCHER_WALK_FOOT_MEDIAN: int = 12
const ARCHER_WALK_HEAD_MEDIAN: int = 7
const ARCHER_WALK_CENTER_MEDIAN: float = -10.5
const ARCHER_WALK_HEIGHT_MEDIAN: int = 365
