# 本文件由 tools/scan_feet_offsets.py 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 360x360

class_name ASSASSIN_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const ASSASSIN_ATTACK_FOOT: Array[int] = [37, 37, 37, 37, 37, 34, 25, 24, 24, 24, 24, 24, 24]

## 每帧头顶偏移（head_gap）
const ASSASSIN_ATTACK_HEAD: Array[int] = [80, 90, 97, 97, 95, 91, 49, 48, 48, 48, 48, 48, 48]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
const ASSASSIN_ATTACK_CENTER: Array[float] = [-16.0, -18.75, -20.5, -20.5, -20.0, -14.25, 7.5, 7.0, 6.75, 6.75, 6.75, 6.75, 6.75]

## 每帧内容尺寸（content_w / content_h）
const ASSASSIN_ATTACK_CONTENT_W: Array[int] = [241, 247, 250, 250, 249, 250, 289, 290, 291, 291, 291, 291, 291]
const ASSASSIN_ATTACK_CONTENT_H: Array[int] = [243, 233, 227, 227, 228, 236, 287, 288, 288, 288, 288, 288, 288]

## 汇总（median）
const ASSASSIN_ATTACK_FOOT_MEDIAN: int = 25
const ASSASSIN_ATTACK_HEAD_MEDIAN: int = 49
const ASSASSIN_ATTACK_CENTER_MEDIAN: float = 6.75
const ASSASSIN_ATTACK_HEIGHT_MEDIAN: int = 287
