# Calyx Evaluation

This repository contains the evaluation materials for our ASPLOS 2021 paper,
"A Compiler Infrastructure for Hardware Accelerators".

The evaluation consist of three code artifacts and several graphs generated in
the paper:
- [The Calyx Infrastructure][calyx]: Calyx IL & the surrounding compiler infrastructure.
- Calyx backend for the [Dahlia compiler][dahlia]: Backend and passes for compiling Dahlia to Calyx.
- Systolic array generator: A python script to generate systolic arrays in Calyx.

**Goals**: There are two goals for this artifact evaluation:
1. To reproduce the graphs presented in our technical paper.
2. To demonstrate robustness of our software artifacts.

### Prerequisites

The artifact is available in two formats: A virtual machine image and through
code repositories hosted on Github.
If you're using the VM image, skip to the next step.

- Install the [Dahlia compiler][dahlia].
  - (*Optional*) Run the Dahlia tests to ensure that the compiler is correctly installed.
- Install the [Calyx compiler][calyx-install] and all of its [testing dependencies][calyx-install-testing] (`runt`, `vcdump`, `verilator`, `jq`).
  - (*Optional*) Run the tests to ensure that the Calyx compiler is installed correctly.
- Install our Calyx driver utility [Fud][fud].
- Clone the [artifact evaluation repository][calyx-eval].

### Installing external tools (Estimated time: 2-4 hours)
Our evaluation uses Xilinx's Vivado and Vivado HLS tools to generate
area and resource estimates.
Our evaluation requires **Vivado WEBPack v.2019.2**.
Due to the [instability of synthesis tools][verismith], we cannot guarantee our
evaluation works with a newer or older version of the Vivado tools.

If you're installing the tools on your own machine instead the VM, you can
[download the installer][vivado-webpack].
The following instructions assume you're using the VM:

1. The desktop should have a file named: `Xilinx_Unified_2019.2_1106_2127_Lin64.bin`.
2. Right-click on the Desktop and select `Open Terminal Here`.
   In the terminal type following command to start the GUI installer:
   `./Xilinx_Unified_2019.2_1106_2127_Lin64.bin`
3. Ignore the warning and press `Ok`.
4. When the box pops up asking you for a new version, click `Continue`.
5. Enter your Xilinx credentials. If you don't have them, click `please create one` and create a Xilinx account.
6. Agree to the contract and press `Next`.
7. Choose `Vivado` and click `Next`.
7. Choose `Vivado HLS WebPACK` and click `Next`.
8. Leave the defaults for selecting devices and click `Next`.
9. Change the install path from `/tools/Xilinx` to `/home/vagrant/Xilinx`.
10. Install.  Depending on the speed of your connection, the whole process
    should take about 2 - 4 hrs.

### Step-by-Step Guide

- **Experimental data and graph generation**: Generate the graphs found in the paper using pre-supplied data.
  - Play around with the data and generate graph using supplied jupyter notebeooks.
  - **Cycle counts normalized to Vivado HLS**: TODO
  - **LUT usage normalized to Vivado HLS**: TODO
  - **Cycle counts normalized to latency-insensitive design**: TODO
- **Regenerating Data**
  - **Polybench experiments**: Compare the Calyx compiler to the Vivado HLS toolchain on the linear algebra polybench benchmarks.
  - **Systolic Array**: Compare the Calyx compiler to the Vivado HLS toolchain on systolic arrays of different sizes.
- *(Optional)* Using the Calyx compiler
  - Implement a counter by writing Calyx IL.
  - Implement a simple pass for the Calyx compiler.

----

### Experimental Data and Graph Generation (Estimated time: 10 minutes)

In this section, we will regenerate graphs presented in the paper using
from **data already committed to the repository**.
Since collecting the data relies on proprietary compilers and takes several
hours, we provide this step as a quick sanity check.
The next section will covers how to collect the data.

In the root `calyx-eval` directory, run `jupyter lab`. This will open a web page
that let's you interact with the provided Jupyter notebooks.

#### Data organization
All the data lives in the `results` directory. There are three directories:
 - `standard`: standard Polybench benchmarks
 - `unrolled`: unrolled versions of select Polybench benchmarks
 - `systolic`: Systolic array data.

Each of these directories have a `calyx` and an `hls` directory which contain
a json file for each benchmark.

#### Data processing
For easier processing, we transform the `json` files into `csv` files. This is done with
the `analysis/data_format.ipynb` notebook file.

 - Navigate to the `analysis/data_format.ipynb` notebook.
 - Click "Restart the kernel, then re-run the whole notebook" button (⏩).
 - Check that a `data.csv` file has appeared in each of the data directories (`results/standard/hls/data.csv`, `results/standard/futil/data.csv`, ...).

Run the notebook, and check to make sure that `data.csv` files have appeared in each of
the data directories.

#### Graph generation
The graph generating is done in `analysis/artfact.ipynb`.
 - Navigate to the `analysis/artfact.ipynb` notebook.
 - Click "Restart the kernel and re-run the whole notebook" button (⏩)️.
 - All the graphs will be generated within the notebook under headers that correspond with the figures
 in the paper.

----

### Data Collection
In this section, we will be collecting the data to reproduce all the figures in the paper.
Our tool `fud` automates the process of compilation, running synthesis for resource estimates, and
simulation for cycle counts. However, running `fud` for each benchmark source file is tedious. We've
automated the process with simple wrapper scripts that find the benchmark source files, call `fud`
with the correct arguments, and create data files.

For those interested, we've included the shape of the `fud` calls in expandable drop downs below each script.
<details>
<summary>Expand for a key for what different flags do:</summary>
    <ul>
        <li><code>--to hls-estimate</code>: Uses Vivado HLS to compile and estimate resource usage of an input Dahlia/C++ program.</li>
        <li><code>--to resource-estimate</code>: Uses Vivado to synthesis Verilog and estimate resource usage.</li>
        <li><code>-s systolic.flags {args}</code>: Passes in parameters to the systolic array frontend.</li>
        <li><code>-s verilog.data {data file}</code>: Passes in a json data file to be given to Verilator for simulation.</li>
    </ul>
</details>

#### HLS vs. Systolic Array (Estimated time: ~30 minutes)

In this section, we will collect data to reproduce Figure 5a and 5b which
compare the estimated cycle count and resource usage of HLS designs and
Calyx-based systolic arrays.

**Vivado HLS (Estimate time: 1-2 minutes):**
To gather the Vivado HLS data, run:
```
./scripts/systolic_hls.sh
```
<details>
<summary>The script is a simple wrapper over the following <code>fud</code> calls: [click to expand]</summary>
    <ul>
        <li><code>fud e {dahlia file} --to hls-estimate</code></li>
    </ul>
</details>

**Calyx (Estimated time: 30 minutes):**
To gather the Calyx systolic array data, run:
```
./scripts/systolic_calyx.sh
```
<details>
<summary>The script is a simple wrapper over the following <code>fud</code> calls: [click to expand]</summary>
    <ul>
        <li><code>fud e --from systolic --to resource-estimate -s systolic.flags {parameters}</code></li>
        <li><code>fud e --from systolic --to vcd_json -s systolic.flags {parameters} -s verilog.data {data}</code></li>
    </ul>
</details>

For those interested, the file sources for the above experiments are:
 - The Dahlia gemm kernels are in `benchmarks/systolic_sources/*.fuse`.
 - The systolic array parameters are stored in `benchmarks/systolic_sources/*.systolic`
 - The systolic array data for Verilator simulation is in `benchmarks/systolic_sources/*.systolic.data`

----

#### HLS vs. Calyx (Estimated time: 4-5 hours)

This section reproduces Figure 6a and 6b which compare the estimated cycle
count and resource usage of HLS and Calyx-based designs.

**Vivado HLS** (Estimated time: 8 minutes):
```
./scripts/polybench_hls.sh
```

**Calyx** (Estimated time: 75 minutes):
```
./scripts/polybench_calyx.sh
```

----

### Latency-Sensitive compilation (Estimated time: 30 minutes)

In this section, we will collect data to reproduce Figure 6c which captures
the change in cycle count when enabling latency sensitive compilation (Section
4.4) with the Calyx compiler.

```
./scripts/latency_sensitive.sh
```


### (Optional) Writing a Calyx Program (Estimated time: 15 minutes)

Check out our documentation for writing your first Calyx program: [hello-world][hello-world].
XXX(sam). flesh this out a tiny bit.

----

### (Optional) Implementing a Compiler Pass (Estimated time: 15 minutes)

---


## Scripts

*vivado.sh*: Does the bulk of the work running `vivado` or `vivado_hls`. It has two modes,
`./vivado.sh futil` and `./vivado.sh hls`. `futil` mode expects a `.sv` file to be provided,
copies over necessary files to a server, runs `vivado`, and then copies the results back.

`hls` mode expects a `.cpp` file to be provided, copies over files to a server, runs `vivado_hls` and then
copies the results back.

Examples:
To synthesis some Futil generated SystemVerilog:
```
mkdir my_results
./scripts/vivado.sh futil my_file.sv my_results
./scripts/futil_copy.sh my_results my_results
./scripts/extract.py my_results
```

For HLS:
```
mkdir my_results
./scripts/vivado.sh hls my_file.cpp my_results
./scripts/hls_copy.sh my_results my_results
./scripts/extract.py my_results
```


For comparing the Vivado HLS results against the equivalent Futil results, use
*compare.sh*. I usually don't call this directly and instead call `run_all.sh`
which is a simple wrapper on top that uses GNU parallel to parallelize running
multiple benchmarks. This expects a file with a list of benchmark names. This is
my workflow:

```
ls ~futil/benchmarks/*.fuse > benchmarks
./scripts/run_all.sh benchmarks -j8 --lb # passes on extra flags to `parallel`
```

The `--lb` flag tells `parallel` to print something out every line it receives from a job
rather then printing the whole thing out at the end of the job.

`-j8` tells parallel to run `8` jobs in parallel.

[calyx]: https://github.com/cucapra/futil
[calyx-eval]: https://github.com/cucapra/futil-evaluation
[calyx-install]: https://capra.cs.cornell.edu/calyx/
[fud]: https://capra.cs.cornell.edu/calyx/tools/fud.html
[dahlia]: https://github.com/cucapra/dahlia
[calyx-install-testing]: https://capra.cs.cornell.edu/calyx/#testing-dependencies
[vivado-webpack]: https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2019.2_1106_2127_Lin64.bin
[verismith]: https://johnwickerson.github.io/papers/verismith_fpga20.pdf
[hello-world]: https://capra.cs.cornell.edu/calyx/tutorial/langtut.html
