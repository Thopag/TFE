
### Core Files

* [**`TFE_package.jl`**](TFE_package.jl): Main module entry point handling library dependencies and imports.
* [**`ploting.jl`**](ploting.jl): Standalone plotting routines along with standard channel color palettes and line styles.

### Subdirectories

#### [system](system)

Contains all ordinary differential equation (ODE) models, state variables, and constant/parameter management:

* **Nociceptor & Projection Neuron**: Modular subfolders designed so each cell model can run independently.
* **Synapse**: Integrates the connection between the nociceptor and projection neuron.
* **`lidocaine.jl`**: Functions for computing lidocaine trajectories and handling parameter modulations.

####  [tools](tools)

Utility functions that extract, format, and structure raw ODE simulation output into processed data structures.

#### [run](run)

High-level driver functions called directly by the execution scripts in `mains/`. Utilizes utilities from `tools/` to sequence simulations and return final results.
