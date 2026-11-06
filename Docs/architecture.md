# MLP Accelerator — Hardware Architecture

## 1. Overview

This project implements an inference accelerator for a Multi-Layer Perceptron (MLP) trained on the MNIST handwritten digit dataset.

The neural network has three computational stages:

- Input: 784 pixel values
- Hidden layer: 16 neurons with ReLU activation
- Output layer: 10 logits corresponding to digits 0–9

The network is trained in software using PyTorch. The trained parameters are exported and used by the Verilog RTL implementation for inference.

The hardware design is organized around memory modules, multiply-accumulate (MAC) units, datapaths, finite-state-machine (FSM) controllers, and an argmax classifier.

## 2. Overall Architecture

The inference dataflow is:

1. Read the 784 input pixel values from input memory.
2. Compute the 16 hidden-layer neurons.
3. Apply ReLU and fixed-point rescaling.
4. Store the 16 hidden activations in activation memory.
5. Compute the 10 output logits.
6. Store the logits in logit memory.
7. Apply argmax to identify the predicted digit.

### Network architecture

| Layer | Number of neurons | Operation |
|---|---:|---|
| Input | 784 | Image pixel values |
| Hidden | 16 | Weighted sum, bias, ReLU |
| Output | 10 | Weighted sum and bias |
| Classifier | 1 prediction | Argmax over 10 logits |

## 3. Hardware Block Description

### 3.1 Input Memory

The input memory stores the 784 pixel values of a 28 × 28 MNIST image.

- Each pixel is represented using unsigned 8-bit data.
- The memory is initialized from `input.mem`.
- The pixel address is supplied by the first-layer controller.
- The memory provides the pixel value to the first-layer MAC datapath.

### 3.2 First Layer

The first layer implements the computation:

\[
z_j = b_j + \sum_{i=0}^{783} x_i w_{j,i}
\]

for each of the 16 hidden neurons.

The first-layer design contains:

- Input memory
- Weight memory
- Bias memory
- MAC unit
- ReLU and rescaling logic
- Activation memory
- First-layer datapath
- First-layer controller

The controller sequences bias loading, pixel and weight reads, MAC operations, and activation writes.

The weight address is generated using the neuron and pixel counters:

\[
\text{weight address} = 784j+i
\]

where \(j\) is the hidden neuron index and \(i\) is the input pixel index.

After all 784 multiply-accumulate operations for a neuron are completed, the result is passed through ReLU and rescaling and written to activation memory.

This process is repeated for all 16 hidden neurons.

### 3.3 MAC Unit

The MAC unit performs multiplication and accumulation.

The bias is loaded into the accumulator before the pixel-weight products are accumulated.

The operation is:

\[
ACC \leftarrow b_j
\]

\[
ACC \leftarrow ACC + x_i w_{j,i}
\]

The accumulator is signed 26-bit, while the input pixels are unsigned 8-bit and weights are signed 8-bit.

### 3.4 ReLU and Rescaling

The first-layer output passes through ReLU:

\[
ReLU(x)=\max(0,x)
\]

The result is then rescaled into the unsigned 8-bit activation range using the fixed-point conversion implemented in the RTL.

The resulting activation is stored in activation memory.

### 3.5 Activation Memory

The activation memory stores the 16 hidden-layer activation values.

Each activation is unsigned 8-bit.

The second-layer datapath reads these values as inputs to the output-layer MAC operations.

### 3.6 Second Layer

The second layer computes 10 output logits:

\[
z_k = b_k + \sum_{j=0}^{15} a_j w_{k,j}
\]

where:

- \(a_j\) is a hidden-layer activation.
- \(w_{k,j}\) is the corresponding second-layer weight.
- \(b_k\) is the output-layer bias.

The second-layer design contains:

- Hidden activation memory interface
- Second-layer weight memory
- Second-layer bias memory
- MAC datapath
- Logit memory
- Second-layer controller

The controller sequences the bias loading, 16 MAC operations per output neuron, and logit writes.

The process is repeated for all 10 output neurons.

Unlike the hidden layer, the output layer does not apply ReLU because its outputs are logits used for classification.

### 3.7 Logit Memory and Argmax

The ten output logits are stored in logit memory.

The argmax module compares the logits and returns the index of the largest value:

\[
\text{prediction} = \arg\max_{k \in [0,9]} z_k
\]

The resulting index represents the predicted MNIST digit.

### 3.8 Top-Level Integration

The top-level MLP module integrates:

- First-layer computation
- Second-layer computation
- Argmax classification
- Overall control sequencing

The top-level controller coordinates the inference process and provides the completion signal.

## 4. Controller and Datapath Organization

The design uses FSM-based controllers to sequence the datapath operations.

The first-layer controller handles:

- Bias address generation
- Bias loading
- Pixel and weight addressing
- MAC enable signals
- Activation write control
- Neuron iteration
- Completion of the first layer

The second-layer controller handles:

- Bias loading
- Activation and weight addressing
- MAC enable signals
- Logit write control
- Output neuron iteration
- Completion of the second layer

Separating control and datapath logic makes the design easier to understand, simulate, and debug.

## 5. Memory Organization

The accelerator uses memory modules for input pixels, weights, biases, hidden activations, and output logits.

The parameter and input memories are initialized using Verilog memory initialization files.

The memory initialization files are part of the simulation setup and must be available at the paths expected by the RTL.

## 6. Simulation Dataflow

The complete inference sequence is:

Input image  
→ Input memory  
→ First-layer MAC computation  
→ ReLU and rescaling  
→ Activation memory  
→ Second-layer MAC computation  
→ Logit memory  
→ Argmax  
→ Predicted digit

## 7. Implementation Status

The RTL modules and integrated MLP have been functionally verified using ModelSim Intel FPGA Starter Edition 2020.1.

An integrated single-image test and a 50-image regression test were completed successfully against a Python reference.

This project has currently been verified through RTL simulation. FPGA synthesis, resource utilization, timing analysis, and physical hardware measurements have not yet been performed.

## 8. Future Extensions

Possible extensions include:

- Pipelining the MAC datapath.
- Parallel neuron computation.
- CNN convolution and pooling accelerators.
- Systolic-array-based computation.
- FPGA synthesis and resource optimization.