# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1344x768

class_name DRAGON_KNIGHT_DRAGON_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const DRAGON_KNIGHT_DRAGON_FOOT: Array[int] = [75, 5, 68, 0, 0, 60, 175, 176, 140, 52, 0, 0, 169, 157]

## 每帧头顶偏移（head_gap）
const DRAGON_KNIGHT_DRAGON_HEAD: Array[int] = [19, 66, 169, 158, 152, 148, 152, 126, 60, 178, 165, 159, 165, 64]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const DRAGON_KNIGHT_DRAGON_CENTER: Array[float] = [-34.0, -22.5, 22.5, -24.5, -120.0, -131.0, -110.0, -102.5, -108.5, 6.0, -35.0, -90.0, -103.0, -65.0]

## 每帧内容尺寸（content_w / content_h）
const DRAGON_KNIGHT_DRAGON_CONTENT_W: Array[int] = [702, 847, 1049, 1053, 956, 1014, 1058, 1023, 959, 1018, 1024, 1038, 1092, 1032]
const DRAGON_KNIGHT_DRAGON_CONTENT_H: Array[int] = [674, 697, 531, 610, 616, 560, 441, 466, 568, 538, 603, 609, 434, 547]

## 汇总（median）
const DRAGON_KNIGHT_DRAGON_FOOT_MEDIAN: int = 68
const DRAGON_KNIGHT_DRAGON_HEAD_MEDIAN: int = 152
const DRAGON_KNIGHT_DRAGON_CENTER_MEDIAN: float = -65.0
const DRAGON_KNIGHT_DRAGON_HEIGHT_MEDIAN: int = 568
