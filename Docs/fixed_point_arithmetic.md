# Fixed-Point Arithmetic and Quantization

## 1. Introduction

The MLP was initially trained using PyTorch. The trained model uses floating-point parameters, but the Verilog accelerator uses integer arithmetic.

Quantization converts the floating-point model parameters into integer representations suitable for hardware implementation.

The objective is to reduce the complexity of arithmetic operations while maintaining classification accuracy close to the original model.

The hardware performs inference only. Training and backpropagation are performed in software.

## 2. Numerical Representation

The accelerator uses the following numerical formats:

| Quantity | Representation | Width |
|---|---|---:|
| Input pixels | Unsigned integer | 8 bits |
| Weights | Signed two's complement | 8 bits |
| Biases | Signed integer | 32 bits |
| MAC accumulator | Signed integer | 26 bits |
| Hidden activations | Unsigned integer | 8 bits |
| Output logits | Signed integer | 26 bits |

Input pixels are converted from normalized MNIST values in the range [0, 1] to integer pixel values in the range [0, 255].

Weights are represented using signed 8-bit two's-complement values.

Biases are stored as signed 32-bit integers in the exported parameter files. The MAC datapath loads the bias into its 26-bit accumulator.

## 3. First-Layer Computation

For hidden neuron \(j\), the mathematical operation is:

\[
z_j = b_j + \sum_{i=0}^{783}x_iw_{j,i}
\]

where:

- \(x_i\) is an unsigned 8-bit input pixel.
- \(w_{j,i}\) is a signed 8-bit weight.
- \(b_j\) is the quantized bias.

The MAC unit first loads the bias:

\[
ACC \leftarrow b_j
\]

It then accumulates the products:

\[
ACC \leftarrow ACC+x_iw_{j,i}
\]

The accumulator is signed 26-bit.

The input pixel is zero-extended before signed multiplication, while the weight is sign-extended. The product is sign-extended before being added to the accumulator.

This preserves the signed interpretation of the weights while allowing unsigned pixel values.

## 4. ReLU Activation

After the first-layer MAC computation, the result passes through ReLU:

\[
ReLU(z_j)=\max(0,z_j)
\]

Negative values are replaced with zero.

Positive values are passed to the rescaling operation.

## 5. Fixed-Point Rescaling

The first-layer result is converted into the unsigned 8-bit activation representation.

The RTL implements multiplication by the rescaling constant 7116, addition of a rounding offset, and an arithmetic right shift by 24 bits.

The implemented operation is:

\[
q_j =
\left(ACC \times 7116 + 2^{23}\right) \mathbin{\text{>>>}} 24
\]

The output is clipped to the range:

\[
0 \leq q_j \leq 255
\]

The rescaling operation is applied after ReLU.

The rounding offset is \(2^{23}\), and the right shift is an arithmetic shift.

The rescaled result is stored as an unsigned 8-bit hidden activation.

## 6. Hidden-Layer Storage

The 16 hidden activations are stored in activation memory.

Each entry contains one unsigned 8-bit activation.

These activation values become the inputs to the second-layer MAC operations.

## 7. Second-Layer Computation

For output neuron \(k\), the computation is:

\[
z_k=b_k+\sum_{j=0}^{15}a_jw_{k,j}
\]

where:

- \(a_j\) is an unsigned 8-bit hidden activation.
- \(w_{k,j}\) is a signed 8-bit weight.
- \(b_k\) is the quantized output bias.

The MAC unit loads the bias and accumulates the 16 activation-weight products.

The output logits are stored as signed 26-bit values.

No ReLU is applied to the output layer because the classifier operates on the raw logits.

## 8. Classification

The predicted digit is determined by selecting the index of the largest output logit:

\[
\text{prediction}=\arg\max_{k \in [0,9]}z_k
\]

The argmax operation compares signed logits.

## 9. Python Reference Model

A quantized Python reference model is used to calculate expected hidden activations and output logits.

The reference model uses the exported integer parameters and the same quantization and rescaling conventions as the RTL implementation.

The Python reference outputs are used as the numerical ground truth for simulation verification.

## 10. Quantized Model Accuracy

The quantized Python model achieved:

- 95.35% accuracy on the 10,000-image MNIST test set.
- 48 correct classifications out of 50 images in the regression subset.

These results describe the software reference model. They are not FPGA hardware measurements.

## 11. Numerical Verification

The RTL outputs were compared against the Python reference for 50 input images.

For each image:

- 16 hidden activation values were compared.
- 10 output logits were compared.

Across the regression:

- Hidden activation comparisons: 800.
- Logit comparisons: 500.
- Total numerical comparisons: 1,300.
- Numerical mismatches: 0.

## 12. Numerical Design Considerations

Important considerations in this implementation include:

- Signed versus unsigned multiplication.
- Sign extension of intermediate products.
- Accumulator width and overflow.
- Bias loading before accumulation.
- Rounding during rescaling.
- Clipping to the 8-bit activation range.
- Signed comparison of output logits.

Matching the numerical conventions between the Python reference and RTL implementation is essential for bit-exact verification.