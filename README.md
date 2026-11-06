# MNIST MLP Inference Accelerator — Verilog

A hardware implementation of a Multi-Layer Perceptron (MLP) for handwritten digit classification using Verilog RTL, with functional verification in ModelSim.

## Project Overview

This project implements an MLP inference accelerator for the MNIST handwritten digit dataset.

The neural network was trained in PyTorch. Its trained parameters were exported and quantized for use in a Verilog hardware implementation.

**Network architecture:**

- Input layer: 784 features (28 × 28 image)
- Hidden layer: 16 neurons with ReLU activation
- Output layer: 10 logits (digits 0–9)
- Inference only: training is performed in software

## Hardware Architecture

The RTL design is organized into the following functional blocks:

- Input memory
- Weight and bias memories
- Multiply-accumulate (MAC) unit
- ReLU and rescaling unit
- Hidden activation memory
- First-layer controller and datapath
- Second-layer controller and datapath
- Logit memory
- Argmax classifier
- Top-level MLP controller and integration module

The controllers use finite-state machines (FSMs) to sequence memory access and arithmetic operations.

## Numerical Representation

The implementation uses quantized integer arithmetic.

| Quantity | Representation |
|---|---|
| Input pixels | Unsigned 8-bit |
| Weights | Signed 8-bit |
| Biases | Signed 32-bit |
| Accumulator | Signed 26-bit |
| Hidden activations | Unsigned 8-bit |
| Output logits | Signed 26-bit |

The first layer applies ReLU followed by fixed-point rescaling and clipping to the 8-bit activation range.

## Software Reference

The neural network was trained using PyTorch, and its quantized parameters and reference outputs were used to verify the RTL implementation.

Python reference evaluation:

- MNIST test set: 10,000 images
- Quantized model accuracy: 95.35%
- 50-image regression subset: 48/50 classifications correct

These are software reference-model results, not physical FPGA measurements.

## RTL Verification

**Simulation environment:** ModelSim Intel FPGA Starter Edition 2020.1

Verification was performed at multiple levels:

1. Individual RTL module testbenches.
2. First-layer and second-layer verification.
3. Integrated end-to-end MLP simulation.
4. A 50-image regression test against the quantized Python reference.

### 50-image regression results

| Verification metric | Result |
|---|---:|
| Images tested | 50 |
| Images passed | 50 |
| Images failed | 0 |
| Hidden activation comparisons | 800 |
| Logit comparisons | 500 |
| Hidden activation mismatches | 0 |
| Logit mismatches | 0 |
| Prediction mismatches | 0 |
| Timeouts | 0 |
| Total numerical mismatches | 0 |

All 800 hidden activations and 500 output logits matched the Python reference exactly across the 50 test images.

The simulated inference took 25,536 clock cycles per image.

## Repository Structure

```text
MLP-PROJECT-ONE/
├── README.md
├── .gitignore
├── rtl/
├── testbench/
├── regression/
├── python/
├── Docs/
├── logs/
└── results/
```

Generated ModelSim files, local Python environments, and raw dataset files are not required in the public repository.

## Running the Simulation

Run ModelSim from the project root directory so that relative memory-file paths resolve correctly.

Compile the RTL modules and regression testbench using the commands documented in `Docs/`.

Run the regression testbench:

```tcl
vsim -voptargs="+acc" work.mlp_regression_tb
run -all
```

The expected successful result is:

```text
COMPLETE 50 IMAGE REGRESSION: PASSED
```

## Limitations

- Verification has been performed using RTL simulation.
- No physical FPGA board was available for hardware testing.
- FPGA resource utilization, maximum clock frequency, power consumption, and physical inference latency have not yet been measured.

## Future Work

- FPGA synthesis and resource analysis.
- CNN operation implementation and CNN inference acceleration.
- Pipelining and parallel MAC architectures.
- Systolic-array-based accelerator exploration.
- Further hardware optimization.

## Tools Used

- Verilog HDL
- ModelSim Intel FPGA Starter Edition 2020.1
- Python
- PyTorch
- Google Colab
- VS Code
