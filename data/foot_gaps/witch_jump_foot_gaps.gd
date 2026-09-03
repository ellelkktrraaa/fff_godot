# 本文件由 tools/import_witch.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：缩放后像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 512x383

class_name WITCH_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const WITCH_JUMP_FOOT: Array[int] = [3, 2, 3, 4, 6, 5, 2, 0, 0]

## 每帧头顶偏移（head_gap）
const WITCH_JUMP_HEAD: Array[int] = [19, 19, 19, 19, 19, 19, 19, 19, 19]

## 每帧中轴水平偏移（center_dx）
const WITCH_JUMP_CENTER: Array[float] = [-19.5, -27.5, -21.0, -6.0, -6.0, -17.0, -26.0, -26.5, -16.5]

## 每帧内容尺寸（content_w / content_h）
const WITCH_JUMP_CONTENT_W: Array[int] = [305, 317, 296, 274, 266, 288, 306, 311, 293]
const WITCH_JUMP_CONTENT_H: Array[int] = [361, 362, 361, 360, 358, 359, 362, 364, 364]

## 汇总（median）
const WITCH_JUMP_FOOT_MEDIAN: int = 3
const WITCH_JUMP_HEAD_MEDIAN: int = 19
const WITCH_JUMP_CENTER_MEDIAN: float = -19.5
const WITCH_JUMP_HEIGHT_MEDIAN: int = 361
