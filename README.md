# Baby Zone Monitoring System — FPGA Implementation

## Project Overview
A real-time baby monitoring system implemented on a Basys 3 FPGA that detects when a baby leaves a defined zone of interest (such as a crib) and triggers an LED alert after sustained absence. The system processes a live camera feed through a hardware image processing pipeline entirely in Verilog.

---

## Motivation
Traditional software-based baby monitors rely on CPU-intensive video processing that introduces latency and consumes significant computational resources. This project explores whether an FPGA implementation can achieve lower latency, higher throughput, and lower power consumption compared to an equivalent Python/OpenCV software implementation.

---

## System Architecture

### Pipeline 
Camera (OV7670) → Grayscale → Edge Detection → Thresholding → Zone Detection → Persistence Timer → LED Alert  
I first made each module with their individual testbenches to ensure they work.

### Modules
| Module | Description |
|--------|-------------|
| `grayscale.v` | Converts RGB input to grayscale using fixed-point bit-shift approximation of standard luminance weights (0.299R + 0.587G + 0.114B) |
| `line_buffer.v` | Three-buffer ping-pong design that buffers two complete rows to enable 3×3 neighborhood access for convolution |
| `edge_simplified.v` | Sobel edge detection using Manhattan approximation (\|Gx\| + \|Gy\|) to avoid square root hardware and overflow |
| `threshold.v` | Binary thresholding of edge strength output — pixels above threshold output 255, below output 0 |
| `zone_detect.v` | Counts edge pixels within a configurable zone of interest per frame and outputs baby presence signal |
| `timer.v` | Persistence timer that triggers LED alert after 600 consecutive frames (~10 seconds at 60fps) of baby absence |
| `top.v` | Top-level module connecting all pipeline stages |

---

## Hardware
- **FPGA Board:** Digilent Basys 3 (Xilinx Artix-7)
- **Camera:** OV7670 (planned)
- **Output:** Onboard LED alert
- **Toolchain:** Vivado Design Suite
- **Language:** Verilog HDL

---

## Key Design Decisions

### Fixed-Point Arithmetic
Floating-point operations are avoided entirely. Grayscale luminance weights are approximated using bit shifts:
Y = (R>>2) + (R>>5) + (R>>6)
(G>>1) + (G>>4) + (G>>6) + (G>>7)
(B>>4) + (B>>5) + (B>>6) + (B>>8)  
This approximates the standard weights (0.299, 0.587, 0.114) with worst-case error under 1 pixel value.

### Manhattan Distance for Edge Magnitude
Instead of the mathematically precise `√(Gx² + Gy²)`, the system uses `|Gx| + |Gy|`. This avoids square root hardware and prevents overflow while remaining sufficient for edge detection.

### Three-Buffer Ping-Pong Line Buffer
Two buffers are insufficient for streaming line buffer designs — the incoming row would overwrite data still needed for convolution. A three-buffer rotating design with a 2-bit counter eliminates read/write conflicts without copying array data (which is unsupported in Verilog).

### Persistence Timer
A 600-frame (~10 second) persistence check prevents false alerts from transient occlusions such as an adult briefly passing through the zone.

---

## Known Limitations
- The system cannot distinguish a baby from objects with similar edge profiles (e.g., large toys), creating potential false negatives
- Zone boundaries are hardcoded parameters — the system cannot automatically detect the crib boundary
- Border pixels (outermost row and column) are ignored due to incomplete 3×3 neighborhoods at image edges
- Camera interface (OV7670) is not yet implemented — currently verified through simulation only

---

## Performance Targets
| Metric | Target |
|--------|--------|
| Throughput | ≥ 60 FPS at 640×480 |
| Latency | < 1 frame (< 16.7ms) |
| Alert delay | ~10 seconds sustained absence |

---

## Comparison with Software Implementation
A Python/OpenCV reference implementation will be used to:
1. Verify correctness of Verilog output (pixel-level comparison)
2. Benchmark performance (latency, throughput, CPU usage vs FPGA resource usage)

To view the results, see [Results-Comparison with Python.md](Results-Comparison%20with%20Python.md).

---

## Project Status
- [x] Grayscale module — implemented and verified
- [x] Line buffer — implemented and verified
- [x] Edge detection — implemented and verified  
- [x] Thresholding — implemented and verified
- [x] Zone detection — implemented and verified
- [x] Persistence timer — implemented and verified
- [x] Top level integration — connected
- [ ] Top level testbench
- [ ] Python/OpenCV reference model
- [ ] Camera interface (OV7670)
- [ ] Hardware deployment on Basys 3
- [ ] Performance comparison

---

## Future Work
- Integrate thermal or depth camera to distinguish baby from objects
- Implement machine learning classifier for robust baby detection
- Add wireless alert (WiFi/Bluetooth module)
- Extend to multi-zone monitoring
