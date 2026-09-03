# 把 sprite-video-lab 新增导出压缩并写入 Godot（paladin / berserker 等，仿 tools/import_witch.py）。
# 流程：0.5 缩放 → 保存 assets/char_ani/{char}/{state}/sheet.png → 超 2048 拆分 →
#       锚点取 sheet.json 的人工 uniform（非全零）否则自动扫描 → 写 data/foot_gaps/*.gd。
# 用法：python tools/import_more.py
import json
import os
import sys

from PIL import Image

LAB_EXPORTS = r"c:\workspace\sprite-video-lab\work-8895\exports"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FG_DIR = os.path.join(ROOT, "data", "foot_gaps")
LIMIT = 2048
SCALE = 0.5
ALPHA = 16

# (导出目录名, 角色名[assets/char_ani 下], 状态[目录/文件名], 常量前缀, gd 文件名)
# manual 不为空 → 用人工 uniform 锚点（原始像素），否则自动扫描
EXPORTS = [
    {
        "export": "20260903-101918-baed-export-paladin_ult",
        "char": "paladin", "state": "ult",
        "prefix": "PALADIN_ULT", "gd": "paladin_ult_foot_gaps.gd",
        "manual": None,  # json 里有真值 uniform 锚点，工具自动读取
    },
    {
        "export": "20260903-101305-1f40-export-paladin_skill1",
        "char": "paladin", "state": "charge",
        "prefix": "PALADIN_CHARGE", "gd": "paladin_charge_foot_gaps.gd",
        "manual": None,
    },
    {
        "export": "20260903-101020-24a7-export-paladin_jump",
        "char": "paladin", "state": "jump",
        "prefix": "PALADIN_JUMP", "gd": "paladin_jump_foot_gaps.gd",
        "manual": None,
    },
    {
        "export": "20260903-095845-60a4-export-paladin_walk",
        "char": "paladin", "state": "walk",
        "prefix": "PALADIN_WALK", "gd": "paladin_walk_foot_gaps.gd",
        "manual": None,
    },
    {
        "export": "20260903-095519-f0e8-export-basaker_sub_skill",
        "char": "berserker", "state": "warcry",
        # 沿用现有 berserker_warcry_foot_gaps.gd 的类/常量前缀（WARCY），避免改锚点辅助函数
        "prefix": "BERSERKER_WARCY", "gd": "berserker_warcry_foot_gaps.gd",
        "manual": None,
    },
]


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
    center_x = (left + right) / 2.0
    cell_center_x = (fw - 1) / 2.0
    return {
        "top": top, "bottom": bottom,
        "content_w": right - left + 1,
        "content_h": bottom - top + 1,
        "center_dx": round(center_x - cell_center_x, 1),
    }


def pick_head_ref(bboxes: list, seed: int = 42) -> int:
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


def build_gdscript(prefix: str, cell: tuple[int, int], anchors: list) -> str:
    cls = prefix + "_FootGaps"
    cell_w, cell_h = cell

    def col(key: str) -> str:
        return ", ".join(str(a[key]) if a else "-1" for a in anchors)

    med = lambda key: sorted(a[key] for a in anchors if a)[len([a for a in anchors if a]) // 2]
    return "\n".join([
        "# 本文件由 tools/import_more.py 自动生成，请勿手动修改。",
        "# 每帧角色锚点数据，单位：缩放后像素（帧内坐标）。",
        "#   foot_gap / head_gap / center_dx / content_w / content_h",
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
    ])


def main() -> None:
    dry = "--dry-run" in sys.argv
    for cfg in EXPORTS:
        export_dir, char, state = cfg["export"], cfg["char"], cfg["state"]
        prefix, gd_name = cfg["prefix"], cfg["gd"]
        d = os.path.join(LAB_EXPORTS, export_dir, "sprite-sheet")
        sheet_path = os.path.join(d, "sheet.png")
        j = json.load(open(os.path.join(d, "sheet.json"), encoding="utf-8"))
        cols, rows, frames = j["columns"], j["rows"], j["frame_count"]

        # 读取人工 uniform 锚点（非全零才算有效）
        uniform = None
        anchors_field = j.get("anchors", {})
        uni = anchors_field.get("uniform") if isinstance(anchors_field, dict) else None
        if uni and (uni.get("foot_gap") or uni.get("head_gap") or uni.get("center_dx")):
            uniform = uni

        im = Image.open(sheet_path).convert("RGBA")
        w, h = im.size
        nw, nh = max(1, int(w * SCALE)), max(1, int(h * SCALE))
        im = im.resize((nw, nh), Image.LANCZOS)

        char_dir = os.path.join(ROOT, "assets", "char_ani", char)
        target_dir = os.path.join(char_dir, state)
        os.makedirs(target_dir, exist_ok=True)
        target = os.path.join(target_dir, "sheet.png")
        if not dry:
            im.save(target)
        print(f"== {char}/{state}: {w}x{h} -> {nw}x{nh} grid {cols}x{rows} frames {frames}")

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
        anchors = []
        if uniform:
            for _ in range(frames):
                anchors.append({
                    "foot_gap": round(uniform["foot_gap"] * SCALE),
                    "head_gap": round(uniform["head_gap"] * SCALE),
                    "center_dx": round(uniform["center_dx"] * SCALE, 1),
                    "content_w": -1,
                    "content_h": -1,
                })
        else:
            raw_bboxes = []
            for i in range(frames):
                c, r = i % cols, i // cols
                box = (c * cell_w, r * cell_h, (c + 1) * cell_w, (r + 1) * cell_h)
                a = im.crop(box).getchannel("A")
                raw_bboxes.append(scan_frame_raw(a, cell_w, cell_h))
            head_ref = pick_head_ref(raw_bboxes)
            for i in range(frames):
                b = raw_bboxes[i]
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

        gd_file = os.path.join(FG_DIR, gd_name)
        gd = build_gdscript(prefix, (cell_w, cell_h), anchors)
        if not dry:
            open(gd_file, "w", encoding="utf-8").write(gd)
        med_h = sorted(a["content_h"] for a in anchors if a)[len([a for a in anchors if a]) // 2]
        print(f"   anchors frames={len(anchors)} cell={cell_w}x{cell_h} ref_h={med_h} anchor_type={'manual' if uniform else 'scan'}")
        print(f"   grid=Vector2i({gx}, {gy})")
        im.close()
    print("MODE=" + ("dry-run" if dry else "executed"))


if __name__ == "__main__":
    main()
