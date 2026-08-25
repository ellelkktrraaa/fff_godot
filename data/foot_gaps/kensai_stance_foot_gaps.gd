# 本文件由 watcher-godot-importer 自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
#   foot_gap:  脚底到帧底部的空隙
#   head_gap:  头顶到帧顶部的空隙
#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）
#   content_w/content_h: 角色实际内容尺寸
# 帧尺寸: 1024x768

class_name KENSAI_STANCE_FootGaps

## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素
const KENSAI_STANCE_FOOT: Array[int] = [18, 18, 21, 40, 48, 54, 54, 54, 54]

## 每帧头顶偏移（head_gap）
const KENSAI_STANCE_HEAD: Array[int] = [73, 75, 78, 109, 122, 126, 125, 123, 123]

## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心
## 注意：蓄力姿态身体保持不动（刀身向右展开），全部帧使用统一身体中心，避免人物漂移
const KENSAI_STANCE_CENTER: Array[float] = [30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.0]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_STANCE_CONTENT_W: Array[int] = [395, 481, 595, 644, 649, 667, 666, 664, 664]
const KENSAI_STANCE_CONTENT_H: Array[int] = [677, 675, 669, 619, 598, 588, 589, 591, 591]

## 汇总（median）
const KENSAI_STANCE_FOOT_MEDIAN: int = 48
const KENSAI_STANCE_HEAD_MEDIAN: int = 122
const KENSAI_STANCE_CENTER_MEDIAN: float = 30.0
const KENSAI_STANCE_HEIGHT_MEDIAN: int = 598
