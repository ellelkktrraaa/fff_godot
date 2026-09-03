# 批量把 assets/char_ani 下的大图原地缩为 1/2（LANCZOS），并同步缩放 data/foot_gaps 锚点数据。
# 用途：让游戏能在最大纹理尺寸较小的笔记本上运行（纹理超出机器极限）。
# 用法：python tools/downscale_sheets.py            # 实际执行
#       python tools/downscale_sheets.py --dry-run  # 只打印将变更的内容
import glob
import os
import re
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")
FG = os.path.join(ROOT, "data", "foot_gaps")

# 全部图片统一缩为 1/2，保证压缩比一致（锚点/渲染都按同比例缩放，避免混合比例出问题）
THRESHOLD = 0
SCALE = 0.5

_INT_ARRAY_RE = re.compile(r"^(const \w+: Array\[int\] = )\[(.*?)\]$", re.MULTILINE)
_FLOAT_ARRAY_RE = re.compile(r"^(const \w+: Array\[float\] = )\[(.*?)\]$", re.MULTILINE)
_MEDIAN_RE = re.compile(r"^(const \w+_MEDIAN: (int|float) = )(-?[\d.]+)$", re.MULTILINE)
_FRAME_SIZE_RE = re.compile(r"(帧尺寸: )(\d+)(x)(\d+)")


def scale_int(v: int) -> int:
    return v if v <= 0 else (v + 1) // 2  # 正数四舍五入，0/-1 保持原样


def scale_float_list(values_str: str) -> str:
    parts = [p.strip() for p in values_str.split(",") if p.strip()]
    out = []
    for p in parts:
        v = float(p)
        s = round(v * SCALE, 2)
        # 整数值保留一位小数（与生成文件风格一致：15.0）
        out.append(f"{s:.1f}" if s == int(s) else f"{s:g}")
    return ", ".join(out)


def scale_int_list(values_str: str) -> str:
    parts = [p.strip() for p in values_str.split(",") if p.strip()]
    return ", ".join(str(scale_int(int(p))) for p in parts)


def scale_anchors(txt: str) -> str:
    def _replace_int_array(m: re.Match) -> str:
        return m.group(1) + "[" + scale_int_list(m.group(2)) + "]"

    def _replace_float_array(m: re.Match) -> str:
        return m.group(1) + "[" + scale_float_list(m.group(2)) + "]"

    def _replace_median(m: re.Match) -> str:
        v = float(m.group(3))
        if m.group(2) == "int":
            return m.group(1) + str(scale_int(int(v)))
        s = round(v * SCALE, 2)
        return m.group(1) + (f"{s:.1f}" if s == int(s) else f"{s:g}")

    def _replace_frame_size(m: re.Match) -> str:
        return m.group(1) + str((int(m.group(2)) + 1) // 2) + m.group(3) + str((int(m.group(4)) + 1) // 2)

    txt = _INT_ARRAY_RE.sub(_replace_int_array, txt)
    txt = _FLOAT_ARRAY_RE.sub(_replace_float_array, txt)
    txt = _MEDIAN_RE.sub(_replace_median, txt)
    txt = _FRAME_SIZE_RE.sub(_replace_frame_size, txt)
    return txt


def main() -> None:
    dry = "--dry-run" in sys.argv

    images = sorted(glob.glob(os.path.join(ASSETS, "**", "*.png"), recursive=True))
    changed_imgs = []
    for f in images:
        if "sheet_half" in f or "sheet_quarter" in f:
            continue
        with Image.open(f) as im:
            w, h = im.size
        if max(w, h) <= THRESHOLD:
            continue
        nw, nh = max(1, int(w * SCALE)), max(1, int(h * SCALE))
        if (nw, nh) == (w, h):
            continue
        if not dry:
            with Image.open(f) as im:
                im.resize((nw, nh), Image.LANCZOS).save(f)
        changed_imgs.append((os.path.relpath(f, ROOT), f"{(w, h)} -> {(nw, nh)}"))

    anchor_files = sorted(glob.glob(os.path.join(FG, "*.gd")))
    changed_anchors = []
    for f in anchor_files:
        with open(f, encoding="utf-8") as fh:
            txt = fh.read()
        new = scale_anchors(txt)
        if new != txt:
            changed_anchors.append(os.path.relpath(f, ROOT))
            if not dry:
                with open(f, "w", encoding="utf-8") as fh:
                    fh.write(new)

    print(f"IMAGES_TO_RESIZE={len(changed_imgs)}")
    for rel, sz in changed_imgs:
        print("  ", rel, sz)
    print(f"ANCHOR_FILES_TO_SCALE={len(changed_anchors)}")
    for rel in changed_anchors:
        print("  ", rel)
    print("MODE=" + ("dry-run" if dry else "executed"))


if __name__ == "__main__":
    main()
