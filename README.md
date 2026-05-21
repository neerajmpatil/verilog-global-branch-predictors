# Verilog Global Branch Predictors

## Project Summary

This project implements and compares three global-history branch predictors in Verilog:

- gpredict
- gselect
- gshare

Each predictor uses a 4-bit Global History Register and a 16-entry Branch History Table made of 2-bit saturating counters. The predictors are tested using a branch trace generated from a nested-loop benchmark and simulated using ModelSim.

The goal of the project is to compare how different BHT indexing strategies affect branch prediction accuracy.

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
│   └── trace.mem
├── scripts/
│   └── gen_trace.py
├── docs/
│   └── final_report.pdf
├── results/
│   └── simulation_output.txt
└── README.md

## Results

| Predictor | Mispredictions | Miss Rate | Hit Rate |
|----------|----------------|-----------|----------|
| gpredict | 1011 | 16.85% | 83.15% |
| gselect  | 1009 | 16.82% | 83.18% |
| gshare   | 1011 | 16.85% | 83.15% |
