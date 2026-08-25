# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x1024

class_name BERSERKER_WARCY_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const BERSERKER_WARCY_FOOT: Array[int] = [76, 56, 30, 15, 9, 9, 9, 9, 9, 9, 9, 9]

## 每帧头顶偏移（head_gap）
const BERSERKER_WARCY_HEAD: Array[int] = [184, 108, 0, 10, 21, 19, 19, 19, 19, 18, 18, 18]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const BERSERKER_WARCY_CENTER: Array[float] = [44.0, 49.5, -9.5, -6.5, -6.0, -17.0, -11.5, -10.0, -8.5, -6.5, -5.0, -3.5]

## 每帧内容尺寸（content_w / content_h）
const BERSERKER_WARCY_CONTENT_W: Array[int] = [646, 669, 683, 695, 702, 726, 745, 748, 751, 755, 758, 761]
const BERSERKER_WARCY_CONTENT_H: Array[int] = [764, 860, 994, 999, 994, 996, 996, 996, 996, 997, 997, 997]

## 汇总（median）
const BERSERKER_WARCY_FOOT_MEDIAN: int = 9
const BERSERKER_WARCY_HEAD_MEDIAN: int = 19
const BERSERKER_WARCY_CENTER_MEDIAN: float = -6.5
const BERSERKER_WARCY_HEIGHT_MEDIAN: int = 996
