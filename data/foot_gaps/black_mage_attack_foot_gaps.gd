# 本文件由脚本自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
# 帧尺寸: 1344x768
# 注意：center_dx 按"角色本体（高密度主体区）中轴"对齐（不含右侧法力波），
#       避免法力波扩散帧把角色本体顶到碰撞体左侧。

class_name BLACK_MAGE_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap）
const BLACK_MAGE_ATTACK_FOOT: Array[int] = [29, 29, 29, 33, 36, 37, 37]

## 每帧头顶偏移（head_gap）
const BLACK_MAGE_ATTACK_HEAD: Array[int] = [0, 39, 61, 109, 96, 91, 91]

## 每帧中轴水平偏移（center_dx）——角色本体中轴相对帧中心（法力波朝 facing 延伸）
const BLACK_MAGE_ATTACK_CENTER: Array[float] = [-330.0, -332.0, -304.0, -258.0, -261.0, -253.0, -244.0]

## 每帧内容尺寸（content_w / content_h）
const BLACK_MAGE_ATTACK_CONTENT_W: Array[int] = [550, 622, 679, 727, 1093, 1229, 1251]
const BLACK_MAGE_ATTACK_CONTENT_H: Array[int] = [739, 700, 678, 626, 636, 640, 640]

## 汇总（median）
const BLACK_MAGE_ATTACK_FOOT_MEDIAN: int = 33
const BLACK_MAGE_ATTACK_HEAD_MEDIAN: int = 91
const BLACK_MAGE_ATTACK_CENTER_MEDIAN: float = -258.0
const BLACK_MAGE_ATTACK_HEIGHT_MEDIAN: int = 640