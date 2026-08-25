# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 720x720

class_name ARCHER_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ARCHER_IDLE_FOOT: Array[int] = [21, 21, 11, 15, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 16]

## 每帧头顶偏移（head_gap）
const ARCHER_IDLE_HEAD: Array[int] = [19, 17, 17, 17, 19, 21, 25, 27, 27, 29, 29, 29, 27, 27, 27, 25, 23, 21, 20, 19, 17]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ARCHER_IDLE_CENTER: Array[float] = [-15.0, -87.0, 15.5, 11.5, 2.5, 2.0, 2.0, 2.0, 1.5, 3.0, 3.0, 3.0, 3.0, 3.0, 2.5, 2.0, 2.0, 1.5, 1.0, 0.5, 0.0]

## 每帧内容尺寸（content_w / content_h）
const ARCHER_IDLE_CONTENT_W: Array[int] = [324, 472, 689, 689, 673, 670, 670, 670, 669, 666, 666, 666, 666, 666, 667, 666, 666, 667, 668, 667, 666]
const ARCHER_IDLE_CONTENT_H: Array[int] = [680, 682, 692, 688, 684, 682, 678, 676, 676, 674, 674, 674, 676, 676, 676, 678, 680, 682, 683, 684, 687]

## 汇总（median）
const ARCHER_IDLE_FOOT_MEDIAN: int = 17
const ARCHER_IDLE_HEAD_MEDIAN: int = 23
const ARCHER_IDLE_CENTER_MEDIAN: float = 2.0
const ARCHER_IDLE_HEIGHT_MEDIAN: int = 680
