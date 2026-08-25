# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 768x768

class_name ASTROLOGER_SKILL1_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASTROLOGER_SKILL1_FOOT: Array[int] = [27, 26, 26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27]

## 每帧头顶偏移（head_gap）
const ASTROLOGER_SKILL1_HEAD: Array[int] = [35, 35, 35, 35, 35, 35, 35, 35, 26, 10, 0, 2, 0, 0, 7, 15, 20, 21, 19, 21, 25, 19, 19, 23]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASTROLOGER_SKILL1_CENTER: Array[float] = [-36.0, -36.0, -36.5, -34.5, -34.5, -34.5, -13.5, 9.5, 31.0, 43.0, 46.0, 38.0, 10.0, 16.0, 18.0, 4.5, 2.5, 5.0, -2.0, 4.0, -2.0, -11.5, 5.5, 3.0]

## 每帧内容尺寸（content_w / content_h）
const ASTROLOGER_SKILL1_CONTENT_W: Array[int] = [490, 490, 491, 495, 495, 495, 537, 607, 656, 668, 666, 670, 678, 678, 658, 653, 655, 680, 682, 674, 666, 629, 673, 696]
const ASTROLOGER_SKILL1_CONTENT_H: Array[int] = [706, 707, 707, 707, 707, 706, 706, 706, 715, 731, 741, 739, 741, 741, 734, 726, 721, 720, 722, 720, 716, 722, 722, 718]

## 汇总（median）
const ASTROLOGER_SKILL1_FOOT_MEDIAN: int = 27
const ASTROLOGER_SKILL1_HEAD_MEDIAN: int = 21
const ASTROLOGER_SKILL1_CENTER_MEDIAN: float = 4.0
const ASTROLOGER_SKILL1_HEIGHT_MEDIAN: int = 720
