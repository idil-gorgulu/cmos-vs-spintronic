# CMOS vs Spintronic Logic: Comparative Design and Benchmarking

## Authors

- **İdil Görgülü** – [GitHub](https://github.com/idil-gorgulu)  
- **Damla Görgülü**  – [GitHub](https://github.com/Damla-Gorgulu)  
- **İsmet Erdem**  – [GitHub](https://github.com/ismet-erdem)  

**Advisor**: Prof. Mehmet Cengiz Onbaşlı – Koç University

This repository contains the complete design, implementation, and evaluation of three fundamental circuits using both **CMOS-based microelectronic** and **skyrmion-based spintronic** architectures. Developed as part of the ELEC 491 – Electrical Engineering Design Project at Koç University, the work aims to benchmark **latency**, **power**, and **area** across the two paradigms using identical RTL schematics.

## Overview

As the semiconductor industry approaches the limits of Moore’s Law, alternative technologies like spintronics offer promising benefits in power and area efficiency. In this project, we implemented and analyzed:

- ✅ Arithmetic Logic Unit (ALU)
- ✅ Discrete-Time Fourier Transform (DTFT)
- ✅ Multi-Layer Perceptron (MLP) for MNIST Classification

Each circuit was implemented using both conventional microelectronic flow (CMOS + Sky130 PDK via OpenLane) and spintronic flow (Skyrmion Logic App + MuMax3-based simulation).

## 🔧 Design Flow

### CMOS (Microelectronic)
- Python & C++ functional prototyping
- Manual VHDL to Verilog translation
- RTL synthesis using OpenLane with Sky130 PDK
- Layout visualization with KLayout
- Metrics extraction: area, timing, and power

### Spintronic
- RTL-preserving gate-level mapping using Skyrmion Logic App
- Tool extension for large-scale circuit support (copy/paste, subcircuit import, auto-routing)
- Component-wise analysis using MuMax3 and Python
- Power and delay modeling using gate benchmarks

## 📊 Results Summary

| Module | Domain       | Area (µm²) | Latency (ns) | Power         |
|--------|--------------|------------|---------------|----------------|
| ALU    | CMOS         | 3475.2     | 23.4          | 9.42 µW        |
|        | Spintronic   | 413.9      | 214.5         | 10.4 nW        |
| DTFT   | CMOS         | 110800     | 16.4          | 4.6 mW         |
|        | Spintronic   | 61500      | 2510.4        | 3020.2 nW      |
| MLP    | CMOS         | 1000000    | 2.6           | 9.42 mW        |
|        | Spintronic   | 960164     | 2868.8        | 126.2 µW       |

✅ **Spintronics significantly reduces power and area**, but comes at the cost of higher latency.

## Tools & Technologies

- VHDL / Verilog (manual conversion)
- Vivado for simulation and RTL analysis
- OpenLane (Sky130 PDK) for synthesis and layout
- Skyrmion Logic App (extended)
- MuMax3 (micromagnetic simulation)
- Python for analysis automation
- KLayout for GDSII visualization
