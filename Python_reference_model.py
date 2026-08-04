import cv2
import numpy as np
import matplotlib.pyplot as plt
import time

# ── Configuration ──────────────────────────────────────────────────────────────
IMAGE_PATH      = "baby.jpg"
THRESH_HEX_PATH = "thresh_out.hex"
WIDTH           = 320
HEIGHT          = 240
ZONE_ROW_MIN    = 50
ZONE_ROW_MAX    = 220
ZONE_COL_MIN    = 60
ZONE_COL_MAX    = 280
EDGE_COUNT_MIN  = 100  # lowered from 500

# ── Load Verilog Output ────────────────────────────────────────────────────────
def load_verilog_output(hex_path, width, height):
    with open(hex_path, 'r') as f:
        lines = f.readlines()
    
    pixels = [int(line.strip(), 16) for line in lines if line.strip()]
    array  = np.array(pixels, dtype=np.uint8)
    
    total = width * height
    if len(array) < total:
        array = np.pad(array, (0, total - len(array)))
    else:
        array = array[:total]
    
    return array.reshape((height, width))

# ── Python Pipeline (standard software approach) ───────────────────────────────
def python_pipeline(image_bgr):
    """
    Standard software implementation — how a programmer would do it without
    any FPGA constraints. Uses exact floating point arithmetic throughout.
    """
    # Stage 1: Grayscale — standard luminance weights (exact floating point)
    gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)
    # Uses exact weights: 0.299R + 0.587G + 0.114B

    # Stage 2: Edge detection — standard Sobel with Euclidean magnitude
    Gx = cv2.Sobel(gray, cv2.CV_32F, 1, 0, ksize=3)
    Gy = cv2.Sobel(gray, cv2.CV_32F, 0, 1, ksize=3)
    G  = np.sqrt(Gx**2 + Gy**2)  # Euclidean — not Manhattan approximation

    # Stage 3: Thresholding — Otsu's method finds optimal threshold automatically
    G_normalized = np.clip(G / G.max() * 255, 0, 255).astype(np.uint8)
    otsu_thresh, binary = cv2.threshold(
        G_normalized, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU
    )

    return gray, G, binary, otsu_thresh

# ── Zone Detection ─────────────────────────────────────────────────────────────
def zone_detect(binary, row_min, row_max, col_min, col_max, edge_count_min):
    zone       = binary[row_min:row_max+1, col_min:col_max+1]
    edge_count = int(np.sum(zone == 255))
    present    = 1 if edge_count >= edge_count_min else 0
    return present, edge_count

# ── Comparison Metrics ─────────────────────────────────────────────────────────
def compare_outputs(verilog_out, python_out):
    """
    Compare Verilog hardware output against Python software output.
    Note: some difference is expected since:
    - Verilog uses bit-shift grayscale approximation, Python uses exact weights
    - Verilog uses Manhattan |Gx|+|Gy|, Python uses Euclidean sqrt(Gx²+Gy²)
    - Verilog uses fixed threshold, Python uses Otsu's automatic threshold
    """
    diff          = np.abs(verilog_out.astype(int) - python_out.astype(int))
    mae           = np.mean(diff)
    max_err       = np.max(diff)
    exact_matches = np.sum(verilog_out == python_out)
    match_pct     = (exact_matches / verilog_out.size) * 100
    verilog_edges = np.sum(verilog_out == 255)
    python_edges  = np.sum(python_out == 255)

    print(f"\n── Comparison Results ───────────────────")
    print(f"MAE                  : {mae:.3f} pixels")
    print(f"Max error            : {max_err} pixels")
    print(f"Exact match          : {match_pct:.1f}%")
    print(f"Verilog edge pixels  : {verilog_edges}")
    print(f"Python edge pixels   : {python_edges}")
    print(f"Edge pixel diff      : {abs(verilog_edges - python_edges)}")
    print(f"────────────────────────────────────────")
    print(f"\nNote: Differences expected due to:")
    print(f"  - Bit-shift vs exact floating point grayscale")
    print(f"  - Manhattan vs Euclidean edge magnitude")
    print(f"  - Fixed vs Otsu automatic threshold")

    return mae, match_pct

# ── Performance Measurement ────────────────────────────────────────────────────
def measure_performance(image_bgr, num_frames=100):
    start   = time.perf_counter()
    for _   in range(num_frames):
        python_pipeline(image_bgr)
    elapsed = time.perf_counter() - start

    latency_ms = (elapsed / num_frames) * 1000
    throughput  = num_frames / elapsed

    fpga_latency    = (WIDTH * HEIGHT) / 100_000_000 * 1000
    fpga_throughput = 100_000_000 / (WIDTH * HEIGHT)
    speedup         = fpga_throughput / throughput

    print(f"\n── Performance Comparison ───────────────")
    print(f"{'Metric':<20} {'Python/OpenCV':<20} {'FPGA (theoretical)'}")
    print(f"{'Latency (ms/frame)':<20} {latency_ms:<20.3f} {fpga_latency:.3f}")
    print(f"{'Throughput (FPS)':<20} {throughput:<20.1f} {fpga_throughput:.1f}")
    print(f"{'CPU usage':<20} {'~{:.0f}% one core':<20} {'0% (dedicated HW)'}")
    print(f"────────────────────────────────────────")
    print(f"FPGA speedup     : {speedup:.1f}x faster than Python/OpenCV")
    print(f"Frames processed : {num_frames} (same image repeated for stable timing)")

    return latency_ms, throughput

# ── Visualization ──────────────────────────────────────────────────────────────
def visualize(image_bgr, verilog_out, python_out, gray, otsu_thresh):
    fig, axes = plt.subplots(1, 4, figsize=(22, 5))
    fig.suptitle(
        f"FPGA Verilog vs Python/OpenCV Pipeline Comparison\n"
        f"Python uses: exact grayscale weights, Euclidean Sobel, "
        f"Otsu threshold (auto={otsu_thresh:.0f})\n"
        f"FPGA uses: bit-shift grayscale, Manhattan Sobel, fixed threshold=500",
        fontsize=10
    )

    # Original
    axes[0].imshow(cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB))
    axes[0].set_title("Original Image")
    axes[0].axis("off")

    # Verilog output
    axes[1].imshow(verilog_out, cmap="gray")
    axes[1].set_title("FPGA Verilog Output\n(bit-shift + Manhattan + fixed thresh)")
    axes[1].axis("off")

    # Python output
    axes[2].imshow(python_out, cmap="gray")
    axes[2].set_title(f"Python/OpenCV Output\n(exact weights + Euclidean + Otsu)")
    axes[2].axis("off")

    # Difference map
    diff = np.abs(verilog_out.astype(int) - python_out.astype(int)).astype(np.uint8)
    axes[3].imshow(diff, cmap="hot")
    axes[3].set_title("Difference Map\n(brighter = larger difference)")
    axes[3].axis("off")

    # Draw zone rectangle
    for ax_idx in [1, 2, 3]:
        axes[ax_idx].add_patch(plt.Rectangle(
            (ZONE_COL_MIN, ZONE_ROW_MIN),
            ZONE_COL_MAX - ZONE_COL_MIN,
            ZONE_ROW_MAX - ZONE_ROW_MIN,
            linewidth=2, edgecolor='green', facecolor='none'
        ))

    plt.tight_layout()
    plt.savefig("comparison_output.png", dpi=150)
    plt.show()
    print("Comparison saved to comparison_output.png")

# ── Main ───────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=== FPGA Verilog vs Python/OpenCV Pipeline Comparison ===\n")

    # Load and resize image
    image = cv2.imread(IMAGE_PATH)
    if image is None:
        print(f"Error: could not load {IMAGE_PATH}")
        exit(1)
    image = cv2.resize(image, (WIDTH, HEIGHT))
    print(f"Image loaded: {WIDTH}x{HEIGHT}")

    # Load Verilog output
    print(f"Loading Verilog output from {THRESH_HEX_PATH}...")
    verilog_out = load_verilog_output(THRESH_HEX_PATH, WIDTH, HEIGHT)
    print(f"Verilog output loaded: {verilog_out.shape}")

    # Run Python pipeline
    print("Running Python/OpenCV pipeline...")
    gray, edges, python_out, otsu_thresh = python_pipeline(image)
    print(f"Otsu threshold selected automatically: {otsu_thresh:.0f}")

    # Zone detection comparison
    v_present, v_count = zone_detect(verilog_out, ZONE_ROW_MIN, ZONE_ROW_MAX,
                                      ZONE_COL_MIN, ZONE_COL_MAX, EDGE_COUNT_MIN)
    p_present, p_count = zone_detect(python_out,  ZONE_ROW_MIN, ZONE_ROW_MAX,
                                      ZONE_COL_MIN, ZONE_COL_MAX, EDGE_COUNT_MIN)

    print(f"\n── Zone Detection Results ───────────────")
    print(f"Verilog : present={v_present}, edge_count={v_count}")
    print(f"Python  : present={p_present}, edge_count={p_count}")
    print(f"Match   : {'✅' if v_present == p_present else '❌'}")
    print(f"────────────────────────────────────────")

    # Compare outputs
    compare_outputs(verilog_out, python_out)

    # Performance comparison
    measure_performance(image, num_frames=100)

    # Visualize
    visualize(image, verilog_out, python_out, gray, otsu_thresh)