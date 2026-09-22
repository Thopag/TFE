This repository contains the simulation code used for the Master's thesis **"Computational Analysis of Lidocaine-Induced Modulations on the Excitability of Two Heterogeneous DRG Neuron States Connected to a Projection Neuron"** (University of Liège, Academic Year 2025–2026).

## Model Overview

The repository implements a **conductance-based model** consisting of three main components:
1. **Nociceptor** (DRG Neuron)
2. **Synapse**
3. **Projection Neuron**

## Repository Structure

The code is divided into two primary directories:

* **`mains/`**: Contains execution scripts that should be run after setting up the environment.
* **`TFE_package/`**: Contains the core codebase responsible for running simulations, processing results, and generating plots.

> ℹ️ **Setup:** Make sure to initialize the environment using [`setup.jl`](TFE_package\setup.jl) before running scripts in `mains/`.

For detailed information about the internal package structure, see the [TFE_package README](TFE_package\src\README.md).