# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x360

class_name ASSASSIN_IDLE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASSASSIN_IDLE_FOOT: Array[int] = [38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38]

## 每帧头顶偏移（head_gap）
const ASSASSIN_IDLE_HEAD: Array[int] = [69, 69, 70, 72, 73, 75, 76, 77, 77, 76, 75, 74, 72, 71, 70, 69]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASSASSIN_IDLE_CENTER: Array[float] = [-10.75, -11.0, -11.5, -11.25, -11.0, -10.75, -10.5, -10.25, -10.0, -9.75, -9.75, -9.75, -9.75, -9.5, -9.75, -10.0]

## 每帧内容尺寸（content_w / content_h）
const ASSASSIN_IDLE_CONTENT_W: Array[int] = [230, 231, 232, 234, 234, 235, 234, 234, 233, 233, 232, 231, 230, 229, 229, 229]
const ASSASSIN_IDLE_CONTENT_H: Array[int] = [254, 254, 253, 251, 250, 248, 247, 246, 246, 247, 248, 249, 251, 252, 253, 254]

## 汇总（median）
const ASSASSIN_IDLE_FOOT_MEDIAN: int = 38
const ASSASSIN_IDLE_HEAD_MEDIAN: int = 73
const ASSASSIN_IDLE_CENTER_MEDIAN: float = -10.0
const ASSASSIN_IDLE_HEIGHT_MEDIAN: int = 251
