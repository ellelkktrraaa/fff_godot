# 把 sprite-video-lab 导出的 .mov 全屏动画转成 PNG 帧序列，供 FrameAnimation 播放。
# mov 多为 qtrle 编码（带 alpha），ffmpeg 可直接抽帧。
# 用法：python tools/import_mov.py <mov路径> <目标目录> [--scale 0.5]
import os
import subprocess
import sys

from PIL import Image

FFMPEG = r"c:\workspace\sprite-video-lab\work-8894\tools\ffmpeg\ffmpeg-9.0-essentials_build\bin\ffmpeg.exe"
FFPROBE = r"c:\workspace\sprite-video-lab\work-8894\tools\ffmpeg\ffmpeg-9.0-essentials_build\bin\ffprobe.exe"


def main() -> None:
    if len(sys.argv) < 3:
        print("用法: python tools/import_mov.py <mov> <目标目录> [--scale 0.5]")
        sys.exit(1)
    mov = os.path.abspath(sys.argv[1])
    target_dir = os.path.abspath(sys.argv[2])
    scale = 0.5
    if "--scale" in sys.argv:
        scale = float(sys.argv[sys.argv.index("--scale") + 1])
    prefix = "ult_mov_"

    # 1. 抽帧到临时目录
    tmp = os.path.join(target_dir, "_mov_frames")
    os.makedirs(tmp, exist_ok=True)
    subprocess.run([FFMPEG, "-y", "-i", mov, os.path.join(tmp, "frame_%04d.png")], check=True)
    frames = sorted(os.listdir(tmp))
    print(f"extracted {len(frames)} frames")

    # 2. 缩放 + 落位
    n = 0
    for f in frames:
        p = os.path.join(tmp, f)
        im = Image.open(p)
        w, h = im.size
        if scale != 1.0:
            im = im.resize((max(1, int(w * scale)), max(1, int(h * scale))), Image.LANCZOS)
        n += 1
        im.save(os.path.join(target_dir, f"{prefix}{n:04d}.png"))
        im.close()
    # 3. 清理临时
    for f in frames:
        os.remove(os.path.join(tmp, f))
    os.rmdir(tmp)
    print(f"wrote {n} frames -> {target_dir}")
    print(f"frames={n} dur=0.1")
    print("loading: FrameAnimation.load_from_frames('" + target_dir.replace("\\", "/") + "/', '" + prefix + "', [{'index': i, 'duration': 0.1} ...])")


if __name__ == "__main__":
    main()
