# 本文件由 scan_feet_offsets.py 生成并整理，数据来源：assets/char_ani/kensai/skill1/sheet.png（白虹贯日闪）
# 网格 5列×4行，每帧 1024x768。仅帧3~14 有效（索引2~13：3-9 抓取、10-14 斩击），其余帧舍弃。
# 索引以帧1=0 起算，本文件保留 20 帧原始数据，kensai.gd 组装锚点时取索引 2~13。

class_name KENSAI_SKILL1_FootGaps

## 每帧脚底偏移（foot_gap）
const KENSAI_SKILL1_FOOT: Array[int] = [172, 172, 173, 173, 173, 173, 173, 173, 173, 141, 115, 122, 123, 110, 123, 111, 116, 127, -1, -1]

## 每帧头顶偏移（head_gap）
const KENSAI_SKILL1_HEAD: Array[int] = [212, 212, 212, 212, 212, 213, 197, 161, 173, 96, 63, 54, 54, 65, 54, 57, 60, 50, -1, -1]

## 每帧中轴水平偏移（center_dx）
const KENSAI_SKILL1_CENTER: Array[float] = [6.5, 6.0, 6.0, 6.0, 6.0, 5.0, -33.0, -70.5, -55.0, -63.5, -142.5, -145.0, -138.0, -140.5, -139.5, -137.0, -141.5, -133.5, -1, -1]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_SKILL1_CONTENT_W: Array[int] = [765, 764, 766, 766, 766, 764, 700, 627, 634, 635, 615, 620, 622, 621, 621, 622, 623, 623, -1, -1]
const KENSAI_SKILL1_CONTENT_H: Array[int] = [384, 384, 383, 383, 383, 382, 398, 434, 422, 531, 590, 592, 591, 593, 591, 600, 592, 591, -1, -1]
