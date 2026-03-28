<div align="center">
  <img src="assets/optimization-lab-hero.svg" alt="Optimization Lab hero showing SST-2, Bag-of-Words, Logistic Regression, SGD, L1 sparsity, and optimizer trajectories" width="100%" />

  <h1>Optimization Lab in PyTorch</h1>
  <p><strong>Notebook-first AI optimization project</strong> covering SST-2 preprocessing, Bag-of-Words features, logistic regression from scratch, SGD dynamics, L1 sparsity, and optimizer behavior on convex vs non-convex losses.</p>

  <p>
    <img alt="Python" src="https://img.shields.io/badge/Python-3.10%2B-0f172a?style=for-the-badge&logo=python&logoColor=ffd54f">
    <img alt="PyTorch" src="https://img.shields.io/badge/PyTorch-2.x-0f172a?style=for-the-badge&logo=pytorch&logoColor=ee4c2c">
    <img alt="Jupyter" src="https://img.shields.io/badge/Jupyter-Notebook-0f172a?style=for-the-badge&logo=jupyter&logoColor=f39c12">
    <img alt="Dataset" src="https://img.shields.io/badge/Dataset-SST--2-0f172a?style=for-the-badge">
    <img alt="Focus" src="https://img.shields.io/badge/Focus-Optimization%20and%20Regularization-0f172a?style=for-the-badge">
  </p>
</div>

## Why This Repo

This project is a compact optimization lab built around a single notebook:

- text goes from raw SST-2 samples to cleaned Bag-of-Words vectors
- the classifier is implemented manually with PyTorch primitives
- SGD behavior is studied through learning-rate and batch-size sweeps
- L1 regularization is inspected through sparsity and weight-dynamics plots
- first-order optimizers are compared on both easy and deceptive loss landscapes

The notebook keeps the original assignment prompts, but the core implementation and analysis are already filled in.

## Quickstart

```bash
bash scripts/start_jupyter.sh
```

Then open:

- [`notebooks/LLM_Architectures_hometask_1.ipynb`](notebooks/LLM_Architectures_hometask_1.ipynb)

The launcher bootstraps `.venv/` if needed, installs `requirements.txt`, and keeps Jupyter, Matplotlib, and Hugging Face cache/config files inside the project.

## Project Flow

```text
SST-2 text
  -> clean_text
  -> tokenize
  -> top-k vocabulary
  -> Bag-of-Words vectors
  -> LogisticRegression
  -> stable binary cross-entropy
  -> SGD / L1 regularization
  -> heatmaps, sparsity plots, weight trajectories

theta = (x, y)
  -> GD / Momentum / AdaGrad / Adam
  -> convex bowl + six-hump camel
  -> value curves + optimization trajectories
```

## Notebook Map

| Section | Focus | Main outputs |
| --- | --- | --- |
| Dataset preparation | SST-2 cleaning, tokenization, vocabulary building, vectorization | label stats, vocabulary size, sparse count vectors |
| Part 1.1 | Numerical stability in BCE and softmax | written explanation + stable BCE implementation |
| Part 1.2-1.3 | Logistic regression and mini-batch SGD | model class, training loop, parameter history |
| Part 1.4 | Hyperparameter sweeps | train/validation accuracy heatmaps, log-loss heatmaps, summary analysis |
| Part 1.5 | L1 regularization and sparsity | lambda sweep, init comparison, non-zero counts, weight-dynamics plots |
| Part 2 | Optimizer geometry | GD, Momentum, AdaGrad, Adam on bowl and camel functions |
| Bonus | Why plain L1 SGD hovers near zero | proximal vs subgradient vs L2 toy example |

## What Is Already Implemented

The notebook currently includes:

- a numerically stable `binary_cross_entropy_loss`
- a `LogisticRegression` module with zero and random initialization
- `sgd_logistic_regression` with `penalty='none' | 'l1' | 'l2'`
- experiment sweeps over:
  - learning rates `0.01, 0.03, 0.1, 0.3, 1.0`
  - batch sizes `50, 100, 200`
  - L1 strengths `0, 1e-4, 1e-3, 1e-2, 1e-1`
- optimizer implementations for:
  - gradient descent
  - momentum
  - AdaGrad
  - Adam
- written analysis for both the classification and optimization sections

Most of the old `TODO` comments remain in place as assignment context, but the actual solution code is filled in under them.

## Why It Is Interesting

This repo is small, but it ties together several ideas that usually get learned separately:

- representation: how text becomes fixed-width vectors
- optimization: how SGD behaves under different learning rates and batch sizes
- regularization: why L1 shrinks coordinates and when it does not create exact zeros
- geometry: why the same optimizer can look great on a bowl and fail on a non-convex surface

That makes the notebook useful both as coursework and as a compact reference for optimization intuition.

## Environment Notes

- the notebook contains a `!pip install datasets` cell near the top, but `datasets` is already listed in [`requirements.txt`](requirements.txt)
- the first SST-2 download requires internet access once
- downloaded datasets are cached under `.cache/huggingface/`
- Jupyter may recreate helper directories such as `notebooks/.ipynb_checkpoints/`; they are safe to ignore

## Repo Layout

```text
llm_architecture_hw_1/
├── assets/
│   └── optimization-lab-hero.svg
├── notebooks/
│   └── LLM_Architectures_hometask_1.ipynb
├── scripts/
│   └── start_jupyter.sh
├── README.md
└── requirements.txt
```

## Recommended Use

If you want a clean rerun:

1. Start Jupyter with `bash scripts/start_jupyter.sh`.
2. Open the notebook.
3. Restart the kernel.
4. Run all cells from top to bottom.
5. Expect the first dataset download to take the longest.
