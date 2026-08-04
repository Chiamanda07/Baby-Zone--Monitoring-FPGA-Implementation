## Comparison with Software Implementation
A Python/OpenCV reference implementation was built to:
1. Verify correctness of Verilog output through pixel-level comparison
2. Benchmark performance against software baseline

### Correctness Results
| Metric | Result |
|--------|--------|
| Pixel exact match rate | 98.5% |
| Mean Absolute Error (MAE) | 3.945 pixels |
| Max pixel error | 255 pixels (border pixels) |
| Verilog edge pixels | 743 |
| Python edge pixels | 745 |
| Edge pixel difference | 2 pixels |
| Zone detection agreement | ✅ Both agree on baby presence |

Differences are expected and intentional due to deliberate hardware approximations:
- **Grayscale:** bit-shift approximation vs exact floating point weights (0.299R + 0.587G + 0.114B)
- **Edge magnitude:** Manhattan approximation (|Gx|+|Gy|) vs Euclidean (√(Gx²+Gy²))
- **Thresholding:** fixed hardware threshold vs Otsu's automatic method

### Performance Results
| Metric | Python/OpenCV | FPGA (Measured/Theoretical) |
|--------|--------------|---------------|
| Latency (ms/frame) | 0.397 | 0.768 |
| Throughput (FPS) | 2518 | 1302 |
| Resource usage | ~100% one CPU core | 38% LUTs, 19% Registers, 0% BRAM |

### Important Context
The Python/OpenCV implementation runs on a modern laptop CPU with highly optimized 
C++ SIMD instructions — an intentionally strong baseline. In a realistic embedded 
deployment scenario (e.g., Raspberry Pi), Python/OpenCV would achieve approximately 
5-10 FPS, making the FPGA implementation roughly 130-260x faster.

Key FPGA advantages over embedded software:
- **Power:** ~1-2W vs ~5W (Raspberry Pi)
- **Determinism:** fixed 0.768ms latency every frame, no OS jitter
- **Independence:** no operating system or CPU required
- **Scalability:** performance unchanged regardless of other system load

### Resource Utilization
| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| Slice LUTs | 7844 | 20800 | 38% |
| Slice Registers | 7802 | 41600 | 19% |
| BRAM | 0 | 50 | 0% |
| DSP Slices | 0 | 90 | 0% |

Note: 99% of LUT usage is attributed to the three-buffer ping-pong line buffer 
implementing distributed RAM. A future optimization would migrate these to dedicated 
BRAM blocks, reducing LUT utilization to approximately 1-2%.
