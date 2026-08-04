import cv2
import numpy as np
import os

# ── Configuration ──────────────────────────────────────────────────────────────
IMAGE_PATH   = "baby.jpg"      # replace with your image path
TARGET_WIDTH  = 320
TARGET_HEIGHT = 240
OUTPUT_DIR    = "hex_files"    # folder to save hex files

# ── Step 1: Load and Resize ────────────────────────────────────────────────────
def load_and_resize(image_path, width, height):
    image = cv2.imread(image_path)
    if image is None:
        print(f"Error: could not load image from {image_path}")
        exit(1)
    
    resized = cv2.resize(image, (width, height))
    print(f"Original size  : {image.shape[1]}x{image.shape[0]}")
    print(f"Resized to     : {width}x{height}")
    
    # Save resized image so you can verify it looks correct
    cv2.imwrite("resized_preview.jpg", resized)
    print(f"Resized preview saved to resized_preview.jpg")
    
    return resized

# ── Step 2: Convert to Hex Files ───────────────────────────────────────────────
def image_to_hex(image_bgr, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    
    B = image_bgr[:,:,0]
    G = image_bgr[:,:,1]
    R = image_bgr[:,:,2]
    
    height, width = image_bgr.shape[:2]
    total_pixels = height * width
    
    # Write separate hex files for R, G, B
    r_path = os.path.join(output_dir, "R.hex")
    g_path = os.path.join(output_dir, "G.hex")
    b_path = os.path.join(output_dir, "B.hex")
    
    with open(r_path, 'w') as rf, \
         open(g_path, 'w') as gf, \
         open(b_path, 'w') as bf:
        for row in range(height):
            for col in range(width):
                rf.write(f"{R[row,col]:02x}\n")
                gf.write(f"{G[row,col]:02x}\n")
                bf.write(f"{B[row,col]:02x}\n")
    
    print(f"\nHex files saved to {output_dir}/")
    print(f"  R.hex : {total_pixels} values")
    print(f"  G.hex : {total_pixels} values")
    print(f"  B.hex : {total_pixels} values")
    print(f"  Total pixels: {total_pixels}")

# ── Verify hex files ───────────────────────────────────────────────────────────
def verify_hex(output_dir, image_bgr):
    """Read hex files back and check they match original image."""
    r_path = os.path.join(output_dir, "R.hex")
    
    with open(r_path, 'r') as f:
        lines = f.readlines()
    
    height, width = image_bgr.shape[:2]
    
    # Check first 5 pixels
    print(f"\n── Verification (first 5 pixels) ────────")
    print(f"{'Pixel':<8} {'R_orig':<10} {'R_hex':<10} {'Match'}")
    for i in range(5):
        row = i // width
        col = i % width
        orig = image_bgr[row, col, 2]  # R channel
        hex_val = int(lines[i].strip(), 16)
        match = "✅" if orig == hex_val else "❌"
        print(f"{i:<8} {orig:<10} {hex_val:<10} {match}")
    print(f"────────────────────────────────────────")

# ── Main ───────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=== Image to Hex Converter ===\n")
    
    # Step 1: Load and resize
    image = load_and_resize(IMAGE_PATH, TARGET_WIDTH, TARGET_HEIGHT)
    
    # Step 2: Convert to hex
    image_to_hex(image, OUTPUT_DIR)
    
    # Verify
    verify_hex(OUTPUT_DIR, image)
    
    print(f"\n=== Done ===")
    print(f"Next steps:")
    print(f"1. Copy hex_files/R.hex, G.hex, B.hex to your Vivado project folder")
    print(f"2. Update top.v parameters: WIDTH=320, HEIGHT=240")
    print(f"3. Update zone parameters to fit 320x240 image")
    print(f"4. Run Verilog testbench with $readmemh")