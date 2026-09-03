#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
find_unused_png.py — 找出 assets/ 中未被任何代码/场景引用的 png。

引用源：
  *.gd / *.tscn / *.tres（递归全项目，排除 .godot/ 与 .png.import）

匹配策略（对每个 png，按 assets 相对路径 rel，如 char_ani/paladin/walk/sheet.png）：
  1. used         ：任一源文件文本含完整路径 "res://assets/<rel>"
  2. used_heuristic：同一源文件内同时出现「某级祖先目录 res 路径」与「文件名」，
                     覆盖 PALADIN_ANI_DIR + "walk/sheet.png" 这类拼接写法
  3. maybe_dynamic：任一处出现祖先目录 res 路径但没有文件名 —— 很可能是
                     load_from_frames / split_sheet 目录枚举型资源（如 idle 帧、
                    sheet_split_*），不能仅凭文本判定，需人工复核
  4. unused       ：以上线索都没有 —— 可安全检查后删除（本脚本输出的重点）

用法：python tools/find_unused_png.py [项目根目录]
输出：控制台打印 unused 摘要；完整报告写入 <项目>/tools/_unused_png_report.txt
"""
import os
import sys
import glob

PROJECT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else r"C:\workspace\fff_godot")
ASSETS = os.path.join(PROJECT, "assets")
OUT_REPORT = os.path.join(PROJECT, "tools", "_unused_png_report.txt")

# 用 PIL 读图片尺寸（tools 其它脚本同依赖）
try:
    from PIL import Image
except Exception:
    Image = None

# ---------- 收集引用源文本 ----------
def collect_sources(root):
    files = []
    for ext in ("*.gd", "*.tscn", "*.tres"):
        files += glob.glob(os.path.join(root, "**", ext), recursive=True)
    # 排除 .godot 缓存目录
    files = [f for f in files if ".godot" not in f.replace("\\", "/").split("/")]
    texts = []
    for f in files:
        try:
            with open(f, "r", encoding="utf-8", errors="ignore") as fh:
                texts.append(fh.read())
        except Exception:
            pass
    return texts

# ---------- 收集候选 png ----------
def collect_pngs(assets):
    pngs = glob.glob(os.path.join(assets, "**", "*.png"), recursive=True)
    pngs = [p for p in pngs if not p.endswith(".import")]
    out = []
    for p in sorted(pngs):
        rel = os.path.relpath(p, PROJECT).replace("\\", "/")
        out.append({"path": p, "rel": rel, "name": os.path.basename(p)})
    return out

def ancestor_dir_strings(rel):
    """返回资产各级祖先目录在源码里可能出现的 res 字符串（最长层 → 顶层）"""
    parts = rel.split("/")          # e.g. ['assets','char_ani','paladin','walk','sheet.png']
    res = []
    for i in range(len(parts) - 1, 1, -1):   # 不含 png 自身，从父目录回溯到 assets
        res.append("res://" + "/".join(parts[:i]))
    return res

def size_of(png):
    try:
        kb = os.path.getsize(png["path"]) / 1024.0
    except Exception:
        kb = 0.0
    w = h = -1
    if Image:
        try:
            with Image.open(png["path"]) as im:
                w, h = im.size
        except Exception:
            pass
    return w, h, kb

def fmt(w, h, kb):
    dim = f"{w}x{h}" if w > 0 else "?"
    return f"{dim:>11} | {kb:>8.0f}KB | "

def split_base_rel(rel):
    """超大图集拆分子图 → 其主图路径（若无 _split_ 标记返回 None）"""
    name = os.path.basename(rel)
    idx = name.find("_split_")
    if idx <= 0:
        return None
    base = name[:idx] + ".png"
    return os.path.join(os.path.dirname(rel), base).replace("\\", "/")

def main():
    texts = collect_sources(PROJECT)
    all_text = "\n".join(texts)

    used, heuristic, dynamic, unused = [], [], [], []
    for png in collect_pngs(ASSETS):
        rel = png["rel"]
        full = "res://" + rel
        name = png["name"]
        # 1) 完整路径
        if full in all_text:
            used.append(png)
            continue
        # 2) 同文件「祖先目录 + 文件名」启发（拼接写法）
        hit_h = False
        for t in texts:
            if name in t and any(a in t for a in ancestor_dir_strings(rel)):
                hit_h = True
                break
        if hit_h:
            heuristic.append(png)
            continue
        # 2.5) 超大图集拆分模式：{主图}_split_{行}_{列}.png 由 load_from_split_sheet
        #      动态命名，文本不出现子图名。若其主图已被引用（used/heuristic），子图视为已使用
        base_rel = split_base_rel(rel)
        base_used = False
        if base_rel is not None:
            for pool in (used, heuristic):
                if any(p["rel"] == base_rel for p in pool):
                    base_used = True
                    break
        if base_used:
            used.append(png)
            continue
        # 3) 仅有祖先目录线索（目录枚举：idle 帧等）
        if any(a in all_text for a in ancestor_dir_strings(rel)):
            dynamic.append(png)
            continue
        # 4) 无任何线索
        unused.append(png)

    # ---- 报告输出 ----
    def dump(section, items):
        lines = []
        for png in items:
            w, h, kb = size_of(png)
            lines.append(f"  {fmt(w, h, kb)}{png['rel']}")
        return lines

    lines = []
    lines.append("=" * 72)
    lines.append("assets 未引用 png 扫描报告")
    lines.append(f"项目根: {PROJECT}")
    lines.append(f"统计: 总png={len(used)+len(heuristic)+len(dynamic)+len(unused)}  "
                 f"used={len(used)} 拼接引用={len(heuristic)} "
                 f"目录枚举(需人工复核)={len(dynamic)} 未引用候选={len(unused)}")
    lines.append("")
    lines.append(f"【1】未引用候选（可检查后删除）共 {len(unused)} 个，按名称排序：")
    lines.append("")
    lines += dump("unused", unused)
    lines.append("")
    lines.append(f"【2】目录枚举/动态加载资源（unused 之外需人工复核）共 {len(dynamic)} 个")
    lines.append("    这些通常由 load_from_frames / split 图命名规则产生，文本扫描无法"
                 "确认，请勿直接删除。")
    lines.append("")

    # 控制台只打印【1】摘要 + 前 60 行 + 摘要
    print("\n".join(lines[:3]))
    print(f"【1】未引用候选 {len(unused)} 个:")
    for line in dump("console", unused)[:60]:
        print(line)
    if len(unused) > 60:
        print(f"  … 其余 {len(unused)-60} 个见报告文件")
    print(f"【2】目录枚举/动态加载(勿删) {len(dynamic)} 个；拼接引用 {len(heuristic)} 个。"
          f"完整报告: {OUT_REPORT}")

    try:
        os.makedirs(os.path.dirname(OUT_REPORT), exist_ok=True)
        with open(OUT_REPORT, "w", encoding="utf-8") as fh:
            fh.write("\n".join(lines))
    except Exception as e:
        print(f"[warn] 写报告失败: {e}")

if __name__ == "__main__":
    main()
