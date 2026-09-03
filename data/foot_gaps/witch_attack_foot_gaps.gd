# 本文件由 tools/import_witch.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：缩放后像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 512x383

class_name WITCH_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const WITCH_ATTACK_FOOT: Array[int] = [4, 5, 5, 5, 5, 5, 5, 5, 5, 5]

## 每帧头顶偏移（head_gap）
const WITCH_ATTACK_HEAD: Array[int] = [6, 6, 6, 6, 6, 6, 6, 6, 6, 6]

## 每帧中轴水平偏移（center_dx）
const WITCH_ATTACK_CENTER: Array[float] = [-11.5, -9.5, 1.5, 11.5, 8.5, 8.5, 10.5, 17.5, 19.0, 21.5]

## 每帧内容尺寸（content_w / content_h）
const WITCH_ATTACK_CONTENT_W: Array[int] = [231, 247, 293, 367, 377, 377, 379, 395, 398, 403]
const WITCH_ATTACK_CONTENT_H: Array[int] = [373, 372, 372, 372, 372, 372, 372, 372, 372, 372]

## 汇总（median）
const WITCH_ATTACK_FOOT_MEDIAN: int = 5
const WITCH_ATTACK_HEAD_MEDIAN: int = 6
const WITCH_ATTACK_CENTER_MEDIAN: float = 10.5
const WITCH_ATTACK_HEIGHT_MEDIAN: int = 372
