# 导入 sprite-video-lab 的魔女（witch）导出到 Godot 项目（仿 tools/import_slqs.py）。
# 流程：EXPORT_SCALE 缩放 → 保存为 witch/{state}/sheet.png → 超 2048 拆分 → 自动扫描锚点 foot_gaps。
# 用法：python tools/import_witch.py
import json
import os
import sys

from PIL import Image

LAB_EXPORTS = r"c:\workspace\sprite-video-lab\work-8895\exports"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FG_DIR = os.path.join(ROOT, "data", "foot_gaps")
CHAR_DIR = os.path.join(ROOT, "assets", "char_ani", "witch")
LIMIT = 2048
SCALE = 0.5
ALPHA = 16

# 个别导出可单独降低缩放（缩小图片体积）；渲染显示尺寸由 content_h_ref × anim_scale 决定，不受影响。
EXPORT_SCALE: dict[str, float] = {}

# (导出目录名, 目标动画状态)
EXPORTS = [
    ("20260903-091502-8db6-export-witch_walk", "walk"),
    ("20260903-091715-e61c-export-witch_in_air", "jump"),
    ("20260903-093734-7b36-export-witch_attack", "attack"),
]

# 人工指定锚点（sprite-video-lab 里人填的才放这里；脚本会忽略 sheet.json 里的全零占位锚点）
MANUAL_ANCHORS: dict[str, dict] = {}

# 自动扫描锚点的头顶偏移（缩放后像素）
HEAD_OFFSET: dict[str, int] = {}


def pick_grid(w: int, h: int, cols: int, rows: int) -> tuple[int, int]:
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


def scan_frame_raw(alpha: Image.Image, fw: int, fh: int) -> dict | None:
    """扫描单帧原始包围盒：返回 {top, bottom, left, right, content_w, content_h, center_dx}。"""
    min_row_pixels = max(12, max(1, fw // 100))
    px = alpha.load()
    xs: list[int] = []
    ys: list[int] = []
    for y in range(fh):
        for x in range(fw):
            if px[x, y] > ALPHA:
                xs.append(x)
                ys.append(y)
    if len(xs) < min_row_pixels:
        return None
    left, right = min(xs), max(xs)
    top, bottom = min(ys), max(ys)
    content_w = right - left + 1
    content_h = bottom - top + 1
    center_x = (left + right) / 2.0
    cell_center_x = (fw - 1) / 2.0
    return {
        "top": top, "bottom": bottom,
        "left": left, "right": right,
        "content_w": content_w, "content_h": content_h,
        "center_dx": round(center_x - cell_center_x, 1),
    }


def pick_head_ref(bboxes: list, seed: int = 42) -> int:
    """随机抽样几帧（开头/结尾权重更高——那里姿态更可能稳定），取头顶最低点作为统一头顶参考。"""
    import random
    frames = [i for i, b in enumerate(bboxes) if b]
    if not frames:
        return 0
    n = len(frames)
    weights = []
    for i in frames:
        d = min(i, n - 1 - i)
        w = 1.0 - d / max(1.0, n / 2.0)
        weights.append(max(w, 0.05))
    random.seed(seed)
    k = min(5, n)
    sample = random.choices(frames, weights=weights, k=k)
    return max(bboxes[i]["top"] for i in sample)


def build_gdscript(state: str, cols: int, rows: int, frames: int,
                   cell: tuple[int, int], anchors: list) -> str:
    prefix = "WITCH_" + state.upper()
    cls = prefix + "_FootGaps"
    cell_w, cell_h = cell

    def col(key: str) -> str:
        return ", ".join(str(a[key]) if a else "-1" for a in anchors)

    med = lambda key: sorted(a[key] for a in anchors if a)[len([a for a in anchors if a]) // 2]
    lines = [
        "# 本文件由 tools/import_witch.py 自动生成，请勿手动修改。",
        "# 每帧角色锚点数据，单位：缩放后像素（帧内坐标）。",
        "#   foot_gap:  脚底到帧底部的空隙",
        "#   head_gap:  头顶到帧顶部的空隙",
        "#   center_dx: 角色内容中轴相对帧中心线的水平偏移（正=偏右）",
        "#   content_w/content_h: 角色实际内容尺寸",
        f"# 帧尺寸: {cell_w}x{cell_h}",
        "",
        f"class_name {cls}",
        "",
        "## 每帧脚底偏移（foot_gap），-1 表示该帧无有效像素",
        f"const {prefix}_FOOT: Array[int] = [{col('foot_gap')}]",
        "",
        "## 每帧头顶偏移（head_gap）",
        f"const {prefix}_HEAD: Array[int] = [{col('head_gap')}]",
        "",
        "## 每帧中轴水平偏移（center_dx）",
        f"const {prefix}_CENTER: Array[float] = [{col('center_dx')}]",
        "",
        "## 每帧内容尺寸（content_w / content_h）",
        f"const {prefix}_CONTENT_W: Array[int] = [{col('content_w')}]",
        f"const {prefix}_CONTENT_H: Array[int] = [{col('content_h')}]",
        "",
        "## 汇总（median）",
        f"const {prefix}_FOOT_MEDIAN: int = {med('foot_gap')}",
        f"const {prefix}_HEAD_MEDIAN: int = {med('head_gap')}",
        f"const {prefix}_CENTER_MEDIAN: float = {med('center_dx')}",
        f"const {prefix}_HEIGHT_MEDIAN: int = {med('content_h')}",
        "",
    ]
    return "\n".join(lines)


def main() -> None:
    dry = "--dry-run" in sys.argv
    for exp_dir, state in EXPORTS:
        d = os.path.join(LAB_EXPORTS, exp_dir, "sprite-sheet")
        sheet_path = os.path.join(d, "sheet.png")
        json_path = os.path.join(d, "sheet.json")
        j = json.load(open(json_path, encoding="utf-8"))
        cols, rows, frames = j["columns"], j["rows"], j["frame_count"]

        im = Image.open(sheet_path).convert("RGBA")
        w, h = im.size
        s = EXPORT_SCALE.get(state, SCALE)
        nw, nh = max(1, int(w * s)), max(1, int(h * s))
        im = im.resize((nw, nh), Image.LANCZOS)

        target_dir = os.path.join(CHAR_DIR, state)
        os.makedirs(target_dir, exist_ok=True)
        target = os.path.join(target_dir, "sheet.png")
        if not dry:
            im.save(target)
        print(f"== {state}: sheet {w}x{h} -> {nw}x{nh} grid {cols}x{rows} frames {frames}")

        gx, gy = pick_grid(nw, nh, cols, rows)
        if gx > 1 or gy > 1:
            if not dry:
                cell_w, cell_h = nw // cols, nh // rows
                sub_cols = (cols + gx - 1) // gx
                sub_rows = (rows + gy - 1) // gy
                stem, ext = os.path.splitext(target)
                for r in range(gy):
                    for c in range(gx):
                        sw = min(sub_cols, cols - c * sub_cols) * cell_w
                        sh = min(sub_rows, rows - r * sub_rows) * cell_h
                        box = (c * sub_cols * cell_w, r * sub_rows * cell_h,
                               c * sub_cols * cell_w + sw, r * sub_rows * cell_h + sh)
                        im.crop(box).save(f"{stem}_split_{r}_{c}{ext}")
            print(f"   SPLIT grid=({gx},{gy})")

        cell_w = nw // cols
        cell_h = nh // rows
        raw_bboxes = []
        for i in range(frames):
            c, r = i % cols, i // cols
            box = (c * cell_w, r * cell_h, (c + 1) * cell_w, (r + 1) * cell_h)
            a = im.crop(box).getchannel("A")
            raw_bboxes.append(scan_frame_raw(a, cell_w, cell_h))
        head_ref = pick_head_ref(raw_bboxes)
        head_ref += HEAD_OFFSET.get(state, 0)
        anchors = []
        manual = MANUAL_ANCHORS.get(state)
        for i in range(frames):
            b = raw_bboxes[i]
            if manual:
                anchors.append({
                    "foot_gap": round(manual["foot_gap"] * s),
                    "head_gap": round(manual["head_gap"] * s),
                    "center_dx": round(manual["center_dx"] * s, 1),
                    "content_w": -1,
                    "content_h": -1,
                })
                continue
            if b is None:
                anchors.append(None)
                continue
            anchors.append({
                "foot_gap": cell_h - 1 - b["bottom"],
                "head_gap": head_ref,
                "center_dx": b["center_dx"],
                "content_w": b["content_w"],
                "content_h": b["bottom"] - head_ref + 1,
            })

        fg_file = os.path.join(FG_DIR, f"witch_{state}_foot_gaps.gd")
        gd = build_gdscript(state, cols, rows, frames, (cell_w, cell_h), anchors)
        if not dry:
            open(fg_file, "w", encoding="utf-8").write(gd)
        med_h = sorted(a["content_h"] for a in anchors if a)[len([a for a in anchors if a]) // 2]
        print(f"   anchors frames={len(anchors)} cell={cell_w}x{cell_h} ref_h={med_h} -> {os.path.basename(fg_file)}")
        print(f"   load_from_sprite_sheet: sheet.png {cols}, {rows}, {frames}, 0.1, loop, anchors, grid=Vector2i({gx}, {gy})")
        im.close()
    print("MODE=" + ("dry-run" if dry else "executed"))


if __name__ == "__main__":
    main()
