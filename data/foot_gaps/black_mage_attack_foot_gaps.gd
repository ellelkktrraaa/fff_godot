# 本文件由脚本自动生成，请勿手动修改。
# 每帧角色锚点数据，单位：原始像素（帧内坐标）。
# 帧尺寸: 672x384
# 注意：center_dx 按"角色本体（高密度主体区）中轴"对齐（不含右侧法力波），
#       避免法力波扩散帧把角色本体顶到碰撞体左侧。

class_name BLACK_MAGE_ATTACK_FootGaps

## 每帧脚底偏移（foot_gap）
const BLACK_MAGE_ATTACK_FOOT: Array[int] = [15, 15, 15, 17, 18, 19, 19]

## 每帧头顶偏移（head_gap）
const BLACK_MAGE_ATTACK_HEAD: Array[int] = [0, 20, 31, 55, 48, 46, 46]

## 每帧中轴水平偏移（center_dx）——角色本体中轴相对帧中心（法力波朝 facing 延伸）
const BLACK_MAGE_ATTACK_CENTER: Array[float] = [-165.0, -166.0, -152.0, -129.0, -130.5, -126.5, -122.0]

## 每帧内容尺寸（content_w / content_h）
const BLACK_MAGE_ATTACK_CONTENT_W: Array[int] = [275, 311, 340, 364, 547, 615, 626]
const BLACK_MAGE_ATTACK_CONTENT_H: Array[int] = [370, 350, 339, 313, 318, 320, 320]

## 汇总（median）
const BLACK_MAGE_ATTACK_FOOT_MEDIAN: int = 17
const BLACK_MAGE_ATTACK_HEAD_MEDIAN: int = 46
const BLACK_MAGE_ATTACK_CENTER_MEDIAN: float = -129.0
const BLACK_MAGE_ATTACK_HEIGHT_MEDIAN: int = 320