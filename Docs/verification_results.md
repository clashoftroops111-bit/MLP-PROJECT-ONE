# Verification and Simulation Results

## 1. Verification Overview

The MLP inference accelerator was verified using RTL simulation in ModelSim Intel FPGA Starter Edition 2020.1.

Verification was performed incrementally, beginning with individual hardware modules and progressing to complete end-to-end inference.

The objective was to establish that the Verilog implementation produces the same quantized numerical results as the Python reference model.

## 2. Simulation Environment

| Item | Configuration |
|---|---|
| HDL | Verilog |
| Simulator | ModelSim Intel FPGA Starter Edition |
| Simulator version | 2020.1 |
| Development environment | Visual Studio Code |
| Reference framework | PyTorch and Python |
| Dataset | MNIST |
| Verification type | RTL simulation |

No physical FPGA board was used.

## 3. Module-Level Verification

Individual modules were tested using dedicated testbenches.

The verification process covered:

- Input memory
- Weight memories
- Bias memories
- MAC unit
- ReLU and rescaling logic
- Activation memory
- First-layer datapath and controller
- Second-layer datapath and controller
- Logit memory
- Argmax classifier
- MLP controller

The individual testbenches were used to verify module functionality before integration.

## 4. Integrated MLP Verification

The first complete top-level simulation tested one MNIST image.

The following were verified:

- First-layer computation.
- All 16 hidden activation values.
- Second-layer computation.
- All 10 output logits.
- Final argmax prediction.

The integrated RTL outputs matched the Python reference for the tested image.

The test completed with zero numerical errors.

## 5. 50-Image Regression Verification

After successful single-image verification, a 50-image regression testbench was developed.

For every test image, the testbench:

1. Loaded the input image into input memory.
2. Loaded the expected hidden activations.
3. Loaded the expected output logits.
4. Reset and started the MLP accelerator.
5. Waited for the inference completion signal.
6. Compared all hidden activations against the Python reference.
7. Compared all output logits against the Python reference.
8. Checked the predicted digit against the expected prediction.

A timeout limit was included to detect inference sequences that fail to complete.

### Regression Dataset

The regression contains 50 MNIST test images.

Each image has:

- 784 input pixel values.
- 16 expected hidden activation values.
- 10 expected output logits.
- Reference classification metadata.

The expected values were generated using the quantized Python reference model.

### Regression Results

| Metric | Result |
|---|---:|
| Images tested | 50 |
| Images passed | 50 |
| Images failed | 0 |
| Hidden activation comparisons | 800 |
| Logit comparisons | 500 |
| Total numerical comparisons | 1,300 |
| Hidden activation mismatches | 0 |
| Logit mismatches | 0 |
| Prediction mismatches | 0 |
| Timeouts | 0 |
| Total errors | 0 |

### Result

**50 out of 50 images passed the RTL regression.**

All 800 hidden activation values and all 500 output logits matched the Python reference exactly.

The final regression testbench reported:

```text
COMPLETE 50 IMAGE REGRESSION: PASSED
```

## 6. Simulation Cycle Count

The integrated inference simulation completed in 25,536 clock cycles per image.

This is a simulated cycle count based on the RTL controller and datapath implementation.

It does not represent measured physical FPGA latency or establish a maximum operating frequency.

## 7. Python Reference Model Results

The quantized Python model achieved:

| Evaluation | Result |
|---|---:|
| MNIST test set | 10,000 images |
| Quantized model accuracy | 95.35% |
| 50-image regression subset | 48/50 correct |

The 50-image RTL regression checks numerical equivalence with the Python reference. Therefore, an image can pass RTL numerical verification even if the reference model itself classifies that image incorrectly.


## 8. Verification Conclusion

The complete Verilog MLP inference accelerator successfully passed the 50-image RTL regression test against the quantized Python reference model.

The results demonstrate functional agreement between the software reference and the simulated RTL implementation for all tested hidden activations and output logits.

The project currently establishes functional correctness through simulation for the tested cases.

## 9. Limitations and Future Verification

The following activities remain outside the scope of the current verification:

- FPGA synthesis.
- FPGA resource utilization analysis.
- Timing analysis and maximum clock frequency measurement.
- Physical FPGA implementation.
- Power consumption measurement.
- Hardware inference latency measurement.

Future work will include synthesis, timing analysis, and eventual FPGA implementation when suitable hardware is available.