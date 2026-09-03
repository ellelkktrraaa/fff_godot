# 本文件由 scan_feet_offsets.py 生成并整理，数据来源：assets/char_ani/kensai/skill1/sheet.png（白虹贯日闪）
# 网格 5列×4行，每帧 1024x768。仅帧3~14 有效（索引2~13：3-9 抓取、10-14 斩击），其余帧舍弃。
# 索引以帧1=0 起算，本文件保留 20 帧原始数据，kensai.gd 组装锚点时取索引 2~13。

class_name KENSAI_SKILL1_FootGaps

## 每帧脚底偏移（foot_gap）
const KENSAI_SKILL1_FOOT: Array[int] = [86, 86, 87, 87, 87, 87, 87, 87, 87, 71, 58, 61, 62, 55, 62, 56, 58, 64, -1, -1]

## 每帧头顶偏移（head_gap）
const KENSAI_SKILL1_HEAD: Array[int] = [106, 106, 106, 106, 106, 107, 99, 81, 87, 48, 32, 27, 27, 33, 27, 29, 30, 25, -1, -1]

## 每帧中轴水平偏移（center_dx）
const KENSAI_SKILL1_CENTER: Array[float] = [3.25, 3.0, 3.0, 3.0, 3.0, 2.5, -16.5, -35.25, -27.5, -31.75, -71.25, -72.5, -69.0, -70.25, -69.75, -68.5, -70.75, -66.75, -0.5, -0.5]

## 每帧内容尺寸（content_w / content_h）
const KENSAI_SKILL1_CONTENT_W: Array[int] = [383, 382, 383, 383, 383, 382, 350, 314, 317, 318, 308, 310, 311, 311, 311, 311, 312, 312, -1, -1]
const KENSAI_SKILL1_CONTENT_H: Array[int] = [192, 192, 192, 192, 192, 191, 199, 217, 211, 266, 295, 296, 296, 297, 296, 300, 296, 296, -1, -1]
