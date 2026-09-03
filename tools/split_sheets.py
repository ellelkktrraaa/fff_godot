# 把仍超过 2048 的图集切成若干 ≤2048 的子图，供 FrameAnimation.load_from_sprite_sheet 的 split_grid 参数使用。
# 子图命名：{原图去扩展名}_split_{网格行}_{网格列}.png（网格行 r=0..gy-1，网格列 c=0..gx-1）
# 子图像素尺寸：宽 = min(sub_cols, columns - c*sub_cols) * cell_w，高同理。
# 用法：python tools/split_sheets.py
import glob
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIMIT = 2048

# (相对 assets 的路径, columns, rows) —— 来自各角色配置中的 load_from_sprite_sheet 参数
SPECS = [
    ("assets/char_ani/archer/attack/sheet.png", 5, 5),
    ("assets/char_ani/assassin/ult_head/sheet.png", 7, 7),
    ("assets/char_ani/astrologer/idle/sheet.png", 4, 4),
    ("assets/sheet（1.png", 4, 4),
    ("assets/sheet（2.png", 4, 4),
    ("assets/char_ani/berserker/skill2/sheet1.png", 5, 4),
    ("assets/char_ani/black_mage/output.png", 10, 6),
    ("assets/char_ani/black_mage/ult/output (1).png", 10, 6),
    ("assets/char_ani/black_mage/sheet.png", 5, 4),
    ("assets/char_ani/dragon_knight/skill1/sheet.png", 5, 4),
    ("assets/char_ani/dragon_knight/skill2/sheet.png", 5, 5),
    ("assets/sheet.attack.png", 4, 3),
    ("assets/sheet.dragon.png", 4, 4),
    ("assets/char_ani/evoker/ult/sheet.png", 7, 7),
    ("assets/char_ani/kensai/skill_1/sheet.png", 6, 6),
    ("assets/char_ani/kensai/skill_2/sheet.png", 5, 4),
    ("assets/char_ani/kensai/attack1/sheet.png", 3, 2),
    ("assets/char_ani/rose/ult/sheet.png", 8, 7),
    ("assets/char_ani/rose/skill1_plus_bladeeffect/sheet1.png", 4, 4),
    ("assets/char_ani/rose/attack/sheet.png", 4, 3),
    ("assets/sheet1.png", 4, 3),
    ("assets/sheet_lighting.png", 5, 5),
    ("assets/sheet_uzimaki.png", 5, 4),
]


def pick_grid(w: int, h: int, cols: int, rows: int) -> tuple[int, int]:
    """选最小网格，使每个子图 ≤2048。"""
    gx, gy = 1, 1
    while True:
        sub_cols = (cols + gx - 1) // gx
        sub_rows = (rows + gy - 1) // gy
        sw = sub_cols * (w // cols)
        sh = sub_rows * (h // rows)
        if sw <= LIMIT and sh <= LIMIT:
            return gx, gy
        if sw > LIMIT:
            gx += 1
        if sh > LIMIT:
            gy += 1


def main() -> None:
    dry = "--dry-run" in sys.argv
    for rel, cols, rows in SPECS:
        path = os.path.join(ROOT, rel)
        if not os.path.exists(path):
            print("MISSING", rel)
            continue
        im = Image.open(path)
        w, h = im.size
        cell_w, cell_h = w // cols, h // rows
        gx, gy = pick_grid(w, h, cols, rows)
        sub_cols = (cols + gx - 1) // gx
        sub_rows = (rows + gy - 1) // gy
        stem, ext = os.path.splitext(path)
        print(f"GRID {rel} cols={cols} rows={rows} size={w}x{h} cell={cell_w}x{cell_h} grid=({gx},{gy}) sub={sub_cols}x{sub_rows}")
        for r in range(gy):
            for c in range(gx):
                sw = min(sub_cols, cols - c * sub_cols) * cell_w
                sh = min(sub_rows, rows - r * sub_rows) * cell_h
                box = (c * sub_cols * cell_w, r * sub_rows * cell_h,
                       c * sub_cols * cell_w + sw, r * sub_rows * cell_h + sh)
                out = f"{stem}_split_{r}_{c}{ext}"
                if not dry:
                    im.crop(box).save(out)
                print(f"   -> {os.path.relpath(out, ROOT)} {sw}x{sh} box={box}")
        im.close()
    print("MODE=" + ("dry-run" if dry else "executed"))


if __name__ == "__main__":
    main()
