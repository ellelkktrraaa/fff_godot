# 导入 sprite-video-lab 的死灵骑士（slqs）导出到 Godot 项目。
# 流程：1/2 缩放 → 复制为 necro_knight/{state}/sheet.png → 超 2048 拆分 → 扫描生成锚点 foot_gaps。
# 用法：python tools/import_slqs.py
import glob
import json
import os
import sys

from PIL import Image

LAB_EXPORTS = r"c:\workspace\sprite-video-lab\work-8895\exports"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FG_DIR = os.path.join(ROOT, "data", "foot_gaps")
CHAR_DIR = os.path.join(ROOT, "assets", "char_ani", "necro_knight")
LIMIT = 2048
SCALE = 0.5
ALPHA = 16

# 个别导出单独降低缩放（缩小图片分辨率/体积）。渲染显示尺寸 = f.h/content_h_ref ×
# anim_scale × 状态倍率，content_h_ref 随缩放重新扫描而同比变化 → 画面大小不受影响。
# mounted_skill1 原帧 1344×766 过高，0.5 缩放下 4 列仍超 2048 需拆两张；降到 0.25 单张即可。
EXPORT_SCALE: dict[str, float] = {"mounted_skill1": 0.25}

# (导出目录名, 目标动画状态)
EXPORTS = [
    ("20260829-204823-06c2-export-slqs_idle", "idle"),
    ("20260829-205011-6281-export-slqs_hours_idle", "horse_idle"),
    ("20260829-205344-13d7-export-slqs_walk", "walk"),
    ("20260829-205509-0df3-export-slqs_idle_on_hours", "mounted_idle"),
    ("20260829-205810-1bfc-export-slqs_idle_mount_hours", "mounted_transition"),
    ("20260901-025344-fa3d-export-slqs_attack", "attack"),
    ("20260901-025604-f578-export-slqs_walk_on_hours", "mounted_walk"),
    ("20260829-212600-6a2f-export-slqs_on_hours_jump", "mounted_jump"),
    # mounted_skill1 由 sprite-video-lab 重新导出为 10 帧版（2026-09-02），覆盖旧的 7 帧导出
    ("20260902-184040-28ad-export-slqs_skill1_on_hours", "mounted_skill1"),
    ("20260901-014009-0a82-export-slqs_jump", "jump"),
    ("20260901-024535-d582-export-slqs_attack_on_hours", "mounted_attack"),
]


# 人工指定锚点的导出（sprite-video-lab 里由人填写，脚/头对齐以它为准）。
# 值在原始分辨率；content_w/h 置 -1，渲染端会用 帧高-foot_gap-head_gap 推算内容高度。
MANUAL_ANCHORS = {
    "attack": {"foot_gap": 480, "head_gap": 450, "center_dx": -51.0},
    "mounted_attack": {"foot_gap": 120, "head_gap": 95, "center_dx": 0.0},
    "mounted_walk": {"foot_gap": 70, "head_gap": 20, "center_dx": -51.0},
}

# 自动扫描锚点的头顶偏移（缩放后像素）：正值=头顶下移（角色更高/头参考降低）
# 注意：渲染时 head_gap 会被缩放完全抵消（头顶位置 = py + f.h * (1 - anim_scale * state_scale)），
# 调整头顶高度请改 necro_knight.gd 的 anim_scale_states，可用 head_offset_to_scale() 换算。
# 原有偏移已于 2026-09-01 换算进 anim_scale_states，此处保持空以生成真实头顶锚点。
HEAD_OFFSET: dict[str, int] = {}


def head_offset_to_scale(head_offset: float, content_h_ref: float, old_scale: float) -> float:
    """把头顶锚点偏移（缩放后像素）换算为 anim_scale_states 倍率。

    渲染公式推导：scale = f.h / content_h_ref * anim_scale * state_scale，
    头顶屏幕位置 = py + f.h - content_h * scale = py + f.h * (1 - anim_scale * state_scale)，
    head_gap / content_h 被完全抵消 —— 头顶高度只由倍率决定，锚点偏移本身不生效。
    换算：新倍率 = 旧倍率 * (1 - 偏移 / content_h_ref)。
    正偏移 = 头顶下移（变矮），负偏移 = 头顶上移（变高）。
    """
    if content_h_ref <= 0:
        return old_scale
    return old_scale * (1.0 - head_offset / content_h_ref)


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
    """随机抽样几帧（开头/结尾权重更高——那里武器更可能未举起），
    取头顶最低点（最大 top）作为统一头顶参考。

    武器举过头顶的帧 top 偏小（更靠上），正常帧的头顶才是真实参考；
    取最大 top（最低点）找到“正常”帧，而不假定武器细长。
    """
    import random
    frames = [i for i, b in enumerate(bboxes) if b]
    if not frames:
        return 0
    n = len(frames)
    # 权重：越靠近开头/结尾越大，中间最低
    weights = []
    for i in frames:
        d = min(i, n - 1 - i)              # 距较近一端的距离
        w = 1.0 - d / max(1.0, n / 2.0)    # 端点=1，中间≈0
        weights.append(max(w, 0.05))
    random.seed(seed)
    k = min(5, n)
    sample = random.choices(frames, weights=weights, k=k)
    return max(bboxes[i]["top"] for i in sample)


def build_gdscript(state: str, cols: int, rows: int, frames: int,
                   cell: tuple[int, int], anchors: list) -> str:
    prefix = "NECRO_KNIGHT_" + state.upper()
    cls = prefix + "_FootGaps"
    cell_w, cell_h = cell

    def col(key: str) -> str:
        return ", ".join(str(a[key]) if a else "-1" for a in anchors)

    med = lambda key: sorted(a[key] for a in anchors if a)[len([a for a in anchors if a]) // 2]
    lines = [
        "# 本文件由 tools/import_slqs.py（仿 scan_feet_offsets.py）自动生成，请勿手动修改。",
        "# 每帧角色锚点数据，单位：原始像素（帧内坐标）。",
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
        "## 每帧中轴水平偏移（center_dx），渲染时用于让角色内容中轴对齐碰撞体中心",
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
        s = EXPORT_SCALE.get(state, SCALE)  # 该状态的缩放系数（可低于全局 SCALE）
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

        # 锚点扫描（在缩放后的图上）：先扫原始包围盒，再用“随机抽样取头顶最低点”统一头顶
        cell_w = nw // cols
        cell_h = nh // rows
        raw_bboxes = []
        for i in range(frames):
            c, r = i % cols, i // cols
            box = (c * cell_w, r * cell_h, (c + 1) * cell_w, (r + 1) * cell_h)
            a = im.crop(box).getchannel("A")
            raw_bboxes.append(scan_frame_raw(a, cell_w, cell_h))
        head_ref = pick_head_ref(raw_bboxes)
        head_ref += HEAD_OFFSET.get(state, 0)  # 人工头顶微调
        anchors = []
        manual = MANUAL_ANCHORS.get(state)
        for i in range(frames):
            b = raw_bboxes[i]
            if manual:
                # 人工锚点：按原始分辨率值缩放该状态系数（content 尺寸置 -1，渲染端推算）
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

        fg_file = os.path.join(FG_DIR, f"necro_knight_{state}_foot_gaps.gd")
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
