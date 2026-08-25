# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 720x960

class_name ASSASSIN_JUMP_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASSASSIN_JUMP_FOOT: Array[int] = [191, 190, 223, 234, 245, 254, 262, 267, 272, 276, 278, 278, 277, 274, 270, 264, 259, 207, 190, 190]

## 每帧头顶偏移（head_gap）
const ASSASSIN_JUMP_HEAD: Array[int] = [357, 191, 107, 98, 90, 84, 78, 75, 72, 70, 69, 69, 70, 73, 76, 81, 86, 151, 305, 301]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASSASSIN_JUMP_CENTER: Array[float] = [-37.5, -14.0, -24.0, -23.5, -22.0, -22.0, -21.5, -21.0, -20.5, -20.0, -19.5, -19.5, -19.0, -18.0, -17.0, -17.0, -18.5, -35.5, -31.5, -34.0]

## 每帧内容尺寸（content_w / content_h）
const ASSASSIN_JUMP_CONTENT_W: Array[int] = [501, 452, 420, 425, 430, 434, 437, 440, 441, 444, 445, 447, 448, 448, 448, 450, 455, 457, 507, 510]
const ASSASSIN_JUMP_CONTENT_H: Array[int] = [412, 579, 630, 628, 625, 622, 620, 618, 616, 614, 613, 613, 613, 613, 614, 615, 615, 602, 465, 469]

## 汇总（median）
const ASSASSIN_JUMP_FOOT_MEDIAN: int = 262
const ASSASSIN_JUMP_HEAD_MEDIAN: int = 84
const ASSASSIN_JUMP_CENTER_MEDIAN: float = -20.5
const ASSASSIN_JUMP_HEIGHT_MEDIAN: int = 614
