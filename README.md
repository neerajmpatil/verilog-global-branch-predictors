# Verilog Global Branch Predictors

## Project Summary

This project implements and compares three dynamic global-history branch predictors in Verilog:

- `gpredict`
- `gselect`
- `gshare`

Each predictor uses a 4-bit Global History Register (GHR), a 16-entry Branch History Table (BHT), and 2-bit saturating counters. The predictors are evaluated using the same branch trace generated from a nested-loop benchmark and simulated using ModelSim.

The goal of the project is to compare how different BHT indexing strategies affect branch prediction accuracy.

## Project Overview

Modern pipelined processors use branch prediction to reduce control hazards by speculatively fetching instructions before branch outcomes are resolved. Accurate prediction improves instruction-level parallelism and reduces pipeline stalls.

This project explores three global-history prediction schemes:

- **gpredict**: indexes the BHT using only the Global History Register.
- **gselect**: concatenates selected Program Counter bits with Global History Register bits.
- **gshare**: XORs Program Counter bits with Global History Register bits.

All three predictors are instantiated in the same Verilog testbench and driven by the same 6,000-branch trace to ensure a fair comparison.

## Tools Used

- Verilog HDL
- ModelSim
- Python
- MIPS assembly
- 2-bit saturating counter branch prediction logic

## Predictor Architecture

Each predictor uses the same core structure:

- 4-bit Global History Register
- 16-entry Branch History Table
- 2-bit saturating counters
- 8-bit Program Counter input
- Shared testbench for fair comparison

| Predictor | Index Function | Description |
|---|---|---|
| `gpredict` | `index = ghr` | Uses only global branch history to index the BHT. |
| `gselect` | `index = {pc[1:0], ghr[1:0]}` | Concatenates low PC bits with low GHR bits. |
| `gshare` | `index = pc[3:0] ^ ghr` | XORs low PC bits with global history to reduce aliasing. |

## Implemented Modules

| File | Description |
|---|---|
| `hdl/sat_counter.v` | 2-bit saturating counter used in each BHT entry. |
| `hdl/gpredict.v` | Global-history predictor using GHR-only indexing. |
| `hdl/gselect.v` | Global predictor using PC/GHR concatenation. |
| `hdl/gshare.v` | Global predictor using PC/GHR XOR indexing. |
| `hdl/tb_predictors.v` | Testbench that instantiates and compares all three predictors. |
| `scripts/gen_trace.py` | Python script that generates the branch trace files. |
| `docs/branch_test.s` | MIPS nested-loop benchmark used to define branch behavior. |
| `sim/run.do` | ModelSim script for compiling, running, and viewing waveforms. |
| `results/simulation_output.txt` | Captured simulation results. |

## Branch Trace

The branch trace was generated from a nested-loop benchmark with two conditional branches:

- Inner loop branch at PC `0x24`
- Outer loop branch at PC `0x30`

The Python script generates:

- `trace.txt`: human-readable branch trace
- `trace.mem`: binary trace used by ModelSim `$readmemb`

Trace summary:

| Metric | Value |
|---|---:|
| Total branches | 6,000 |
| Inner-loop branches | 5,000 |
| Outer-loop branches | 1,000 |
| Taken branches | 4,999 |
| Not-taken branches | 1,001 |

## Simulation Results

| Predictor | Mispredictions | Miss Rate | Hit Rate |
|---|---:|---:|---:|
| `gpredict` | 1011 | 16.85% | 83.15% |
| `gselect` | 1009 | 16.82% | 83.18% |
| `gshare` | 1011 | 16.85% | 83.15% |

## Analysis

All three predictors achieved similar accuracy because the workload exposes a limitation of the selected design parameters.

The Global History Register is only 4 bits wide, while the inner loop has a period of 5. This means the predictor cannot fully distinguish between some recurring branch-history patterns. In particular, the same 4-bit history value can correspond to different actual outcomes, causing unavoidable aliasing in the BHT.

For `gselect`, the two branch PCs have identical low two bits, so the selected PC bits do not help separate the inner and outer branches. For `gshare`, XOR indexing changes the BHT mapping but cannot solve cases where the same branch and same GHR value lead to conflicting outcomes.

The result demonstrates that indexing strategy alone cannot compensate for insufficient history length.

## Folder Structure

```text
verilog-global-branch-predictors/
├── hdl/
│   ├── sat_counter.v
│   ├── gpredict.v
│   ├── gselect.v
│   ├── gshare.v
│   └── tb_predictors.v
├── sim/
│   ├── run.do
│   ├── trace.mem
│   └── trace.txt
├── scripts/
│   └── gen_trace.py
├── docs/
│   ├── branch_test.s
│   └── final_report.pdf
├── results/
│   └── simulation_output.txt
└── README.md
```

## How to Run

1. Generate the trace files, if needed:

```bash
python3 scripts/gen_trace.py
```

This creates `trace.txt` and `trace.mem`.

2. Move or copy the generated trace files into the `sim/` directory if they are not already there.

3. Open ModelSim and run from the `sim/` directory:

```tcl
do run.do
```

4. The testbench loads `trace.mem`, runs all three predictors, and prints the misprediction results.

## Expected Output

```text
===============================================================
                 Branch Prediction Results
===============================================================
Total branches simulated: 6000

Predictor    Mispredicts    Mispredict Rate    Hit Rate
---------    -----------    ---------------    --------
gpredict        1011          16.85%            83.15%
gselect         1009          16.82%            83.18%
gshare          1011          16.85%            83.15%
===============================================================
```

## Future Improvements

- Increase GHR width from 4 bits to 5 or 8 bits.
- Increase BHT size to reduce aliasing.
- Compare against a bimodal predictor.
- Implement a tournament predictor.
- Run predictors on richer instruction traces with more branch PCs.
- Synthesize the design for FPGA or ASIC area/timing comparison.

## Key Takeaway

This project demonstrates how global-history branch predictors can be implemented and evaluated at the RTL level. It also shows an important computer architecture concept: predictor accuracy depends not only on the indexing function, but also on history length, branch behavior, and aliasing patterns in the workload.
