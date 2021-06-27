# Calyx Evaluation
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4432747.svg)](https://doi.org/10.5281/zenodo.4432747)

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

**Important Note**: The figures generated from the artifact evaluation differ slightly from
the figures in the pre-print. This is for two reasons:
 1) Our figures for the systolic array in the pre-print where incorrect due to [a bug][systolic-bug] in our plotting
 scripts. Our qualitative claims don't change, but the estimated cycles we report are incorrect.
 2) We have implemented [resource sharing][resource-sharing] and [register sharing][minimize-registers]
 optimizations since the pre-print which change the resource numbers slightly.

We have included corrected versions of the graphs in `analysis/*.pdf`

## Prerequisites

### Artifact Sources

The artifact is available in two formats: A virtual machine image and through
code repositories hosted on Github.

**Using the VM**.
The VM is packaged as an OVA file and can be downloaded from a permanent link [here][vm-link].
Our instructions assume you're using [VirtualBox][].

- Minimum host disk space required to install external tools: 65 GB
- Increase number of cores and RAM
  - Select the VM and click "Settings".
  - Select "System" > "Motherboard" and increase the "Base Memory" to 8 GB.
  - Select "System" > "Processor" and select at least 2 cores.

<details>
<summary><b>Troubleshooting common VM problems</b> [click to expand]</summary>

 - **Running out of disk space while installing Vivado tools**. The Vivado installer will sometimes
 crash or not start if there is not enough disk space. The Virtual Machine is configured to use
 a dynamically sized disk, so to solve this problem, simply clear space on the host machine. You need about 65 gbs of free space.
 - **Running out of memory**. Vivado, Vivado HLS, and Verilator all use a fair amount of memory. If there
 is not enough memory available to the VM, they will crash and data won't be generated. If something fails you can do one of:
   - Increase the RAM and rerun the script that had a failure.
   - Ignore the failure, the figure generation scripts are made to be resilient to this kind of data failure.
</details>

**Using a local machine**.
The following instructions can be used to setup and build all the tools required
to evaluate Calyx on a local machine:

- Install the [Dahlia compiler][dahlia].
  - (*Optional*) Run the Dahlia tests to ensure that the compiler is correctly installed.
- Install the [Calyx compiler][calyx-install] and all of its [testing dependencies][calyx-install-testing] (`runt`, `vcdump`, `verilator`, `jq`).
  - (*Optional*) Run the tests to ensure that the Calyx compiler is installed correctly.
- Install our Calyx driver utility [Fud][fud].
- Clone the [artifact evaluation repository][calyx-eval].
- Install evaluation python dependencies with: `pip3 install -r requirements.txt`
- Follow instructions [here][parallel-install] to install GNU Parallel

### Installing external tools (Estimated time: 2-4 hours)
Our evaluation uses Xilinx's Vivado and Vivado HLS tools to generate
area and resource estimates.
Unfortunately due to licensing restrictions, we can't distribute the VM with
these tools installed. However, the tools are freely available and below are
instructions on how to install them.

Our evaluation requires **Vivado WebPACK v.2019.2**.
Due to the [instability of synthesis tools][verismith], we cannot guarantee our
evaluation works with a newer or older version of the Vivado tools.

If you're installing the tools on your own machine instead the VM, you can
[download the installer][vivado-webpack].
The following instructions assume you're using the VM:

1. Log in to the VM with the username `vagrant` and the password `vagrant`.
2. The desktop should have a file named: `Xilinx Installer`. Double click on this to launch the installer.
3. Ignore the warning and press `Ok`.
4. When the box pops up asking you for a new version, click `Continue`.
5. Enter your Xilinx credentials. If you don't have them, [create a Xilinx account][xilinx-account].
  - **Note** When you create an account, you need to fill out all the required information on [your profile][xilinx-profile].
  Otherwise [the Xilinx installer will reject your login](xilinx-fill-account).
  - The "User ID" is the email address of the Xilinx account you created.
6. Agree to the contract and press `Next`.
7. Choose `Vivado` and click `Next`.
8. Choose `Vivado HL WebPACK` and click `Next`.
9. Leave the defaults for selecting devices and click `Next`.
10. **Important!** Change the install path from `/tools/Xilinx` to `/home/vagrant/Xilinx`.
11. Confirm that you want to create the directory.
12. Install.  Depending on the speed of your connection, the whole process
    should take about 2 - 4 hrs.


## Step-by-Step Guide

- **Experimental data and graph generation**: Generate the graphs found in the paper using pre-supplied data.
  - Systolic array comparison (Fig 5a, 5b)
  - Polybench graphs (Fig 6a, 6b, 6c)
- **Data collection**
  - Calyx-based Systolic array generator vs. HLS kernels (Section 6.1).
  - Dahlia-to-Calyx vs. Dahlia-to-HLS (Section 6.2).
- *(Optional)* **Using the Calyx compiler**
  - Implement an [example program][hello-world] in Calyx IL.
  - Take a look at [the documentation][calyx-install] for the Calyx IL.
  - Take a look at [the documentation][calyx-doc] for the compiler infrastructure.

## Experimental Data and Graph Generation (Estimated time: 5 minutes)
Since the process to collecting data takes several hours, we will first
regenerate the graphs presented in the paper from **data already committed to
the repository**.
The [next section](#data-collection) will demonstrate how to collect this data.

Open the `futil-evaluation` directory on the Desktop. Right click in the file explorer
and select `Open Terminal Here`. First run:
```
git pull;
sudo apt install texlive texlive-latex-extra dvipng
```
to make sure that everything is up to date. Then run:
```
jupyter lab analysis/artifact.ipynb
```

This will open up a Jupyter notebook that generates graphs using the data in
che `results/` directory.

- Click "Restart the kernel and re-run the whole notebook" button (⏩)️.
- All the graphs will be generated within the notebook under headers that correspond with the figures
  in the paper.

<details>
<summary>
Details about the structure of the <code>results</code> directory [click to expand]
</summary>

**Data organization**.
All the data lives in the `results` directory. There are four directories:
 - `systolic`: Systolic array data.
 - `standard`: Standard Polybench benchmarks.
 - `unrolled`: Unrolled versions of select Polybench benchmarks.
 - `latency-sensitive`: Polybench benchmarks run with `static-timing` enabled and disabled.

The `systolic`, `standard`, and `unrolled` directories each
have a `futil`, `futil-latency`, and an `hls` sub-directory which contain
a json file for each benchmark.

`latency-sensitive` has the sub-directories `with-static-timing` and `no-static-timing` which
contain a json file for each benchmark.

**Data processing**.
For easier processing, we transform the `json` files into `csv` files. This is done
at the top of `analysis/artifact.ipynb`.
Run the notebook, and check to make sure that `data.csv` files have appeared in each of
the data directories.
</details>

## Data Collection
In this section, we will collect the data required to reproduce the figures in
the paper.
Start by moving the results directory somewhere else:
```
mv results result_provided
```

The following explanations will regenerate all the data files in the `results/`
directory.
At the end of this section, you can reopen the Jupyter notebook from the previous
section and regenerate the graphs with the data you collected.

Each subsection uses a single script to collect data for a study.
The scripts use [fud][], a tool we built to generate and compile Calyx programs
and invoke various toolchains (simulation, synthesis).
By default, the scripts run one benchmark at a time. If you configured your VM to use more CPU cores
and memory, you can increase the parallelism with the `-j` flag. For example:
```
./scripts/systolic_hls.sh -j4
```
This allows 4 jobs to run in parallel and will help things run faster. However, you may run into
`Out of Memory` failures. If this happens, simply re-run the script with less parallelism.

<details>
<summary>Explanation of various flags used by <code>fud</code> to automate the evaluation [click to expand]</summary>

 - `--to hls-estimate`: Uses Vivado HLS to compile and estimate resource usage of an input Dahlia/C++ program.
 - `--to resource-estimate`: Uses Vivado to synthesis Verilog and estimate resource usage.
 - `--to vcd_json`: Uses Verilator to simulate a Verilog program.
 - `-s systolic.flags {args}`: Passes in parameters to the systolic array frontend.
 - `-s verilog.data {data file}`: Passes in a json data file to be given to Verilator for simulation.
 - `-s futil.flags '-d static-timing'`: Disables the `static-timing` pass.
</details>

### HLS vs. Systolic Array (Estimated time: 30-45 minutes)
In this section, we will collect data to reproduce Figure 5a and 5b which
compare the estimated cycle count and resource usage of HLS designs and
Calyx-based systolic arrays.

**Reminder**: Remember to compare the figures generated from the data in this section
against the figures provided in `analysis`, not the ones in the paper.

**Vivado HLS (Estimate time: 1-2 minutes):**
To gather the Vivado HLS data, run:
```
./scripts/systolic_hls.sh
```
<details>
<summary>The script is a simple wrapper over the following <code>fud</code> calls: [click to expand]</summary>

 - `fud e {dahlia file} --to hls-estimate`
</details>

<details>
<summary>Relevant files: [click to expand]</summary>

This script uses the sources here:
 - `benchmarks/systolic_sources/*.fuse`

to generate the data:
 - `results/systolic/hls/*.json`
</details>

**Calyx (Estimated time: 30-45 minutes):**
To gather the Calyx systolic array data, run:
```
./scripts/systolic_calyx.sh
```
<details>
<summary>The script is a simple wrapper over the following <code>fud</code> calls: [click to expand]</summary>

 - `fud e --from systolic --to resource-estimate -s systolic.flags {parameters}`
 - `fud e --from systolic --to vcd_json -s systolic.flags {parameters} -s verilog.data {data}`
</details>

<details>
<summary>Relevant files: [click to expand]</summary>

This script uses the sources here:
 - `benchmarks/systolic_sources/*.systolic`
 - `benchmarks/systolic_sources/*.systolic.data`

to generate the data:
 - `results/systolic/futil/*.json`
 - `results/systolic/futil-latency/*.json`
</details>

----

### HLS vs. Calyx (Estimated time: 85 minutes)
This section reproduces Figure 6a and 6b which compare the estimated cycle
count and resource usage of HLS and Calyx-based designs.

**Vivado HLS** (Estimated time: 5-10 minutes):
To gather the Polybench HLS data, run:
```
./scripts/polybench_hls.sh
```
<details>
<summary>The script is a simple wrapper over the following <code>fud</code> calls: [click to expand]</summary>

 - `fud e {dahlia file} --to hls-estimate`
</details>

<details>
<summary>Relevant files: [click to expand]</summary>

This script uses the sources here:
 - `benchmarks/polybench/*.fuse`
 - `benchmarks/unrolled/*.fuse`

to generate the data:
 - `results/standard/hls/*.json`
 - `results/unrolled/hls/*.json`
</details>

**Calyx** (Estimated time: 75 minutes):
To gather the Polybench Calyx data, run:
```
./scripts/polybench_calyx.sh
```
<details>
<summary>The script is a simple wrapper over the following <code>fud</code> calls: [click to expand]</summary>

 - `fud e {dahlia file} --to resouce-estimate`
 - `fud e {dahlia file} --to vcd_json`
</details>

<details>
<summary>Relevant files: [click to expand]</summary>

This script uses the sources here:
 - `benchmarks/polybench/*.fuse`
 - `benchmarks/polybench/*.fuse.data`
 - `benchmarks/unrolled/*.fuse`
 - `benchmarks/unrolled/*.fuse.data`

to generate the data:
 - `results/standard/hls/*.json`
 - `results/unrolled/hls/*.json`
</details>

----

### Latency-Sensitive compilation (Estimated time: 10 minutes)
In this section, we will collect data to reproduce Figure 6c which captures
the change in cycle count when enabling latency sensitive compilation (Section
4.4) with the Calyx compiler.

**Data** (Estimated time: 10 minutes):
To gather the latency sensitive vs. latency insensitive data, run:
```
./scripts/latency_sensitive.sh
```
<details>
<summary>The script is a simple wrapper over the following <code>fud</code> calls: [click to expand]</summary>

 - `fud e {dahlia file} --to vcd_json -s verilog.data {data}`
 - `fud e {dahlia file} --to vcd_json -s verilog.data {data} -s futil.flags '-d static-timing'`
</details>

<details>
<summary>Relevant files: [click to expand]</summary>

This script uses the sources here:
 - `benchmarks/polybench/*.fuse`
 - `benchmarks/polybench/*.fuse.data`

to generate the data:
 - `results/latency-sensitive/with-static-timing/*.json`
 - `results/latency-sensitive/no-static-timing/*.json`
</details>

## (Optional) Using the Calyx Compiler (Estimated time: 15 minutes)

- [Our tutorial][hello-world] guides you through the process of writing a
Calyx program *by hand* and demonstrates how we use `fud` to simplify working
with Calyx programs.
- The documentation for our source code is generated using rustdoc and is [hosted here][calyx-doc].
- The documentation for Calyx IL is generated using mdbook and is [hosted here][calyx-install].

[calyx]: https://github.com/cucapra/futil
[calyx-eval]: https://github.com/cucapra/futil-evaluation
[calyx-install]: https://capra.cs.cornell.edu/calyx/
[calyx-doc]: https://capra.cs.cornell.edu/calyx/doc/calyx
[fud]: https://capra.cs.cornell.edu/calyx/tools/fud.html
[dahlia]: https://github.com/cucapra/dahlia
[calyx-install-testing]: https://capra.cs.cornell.edu/calyx/#testing-dependencies
[vivado-webpack]: https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2019.2_1106_2127_Lin64.bin
[verismith]: https://johnwickerson.github.io/papers/verismith_fpga20.pdf
[hello-world]: https://capra.cs.cornell.edu/calyx/tutorial/langtut.html
[vm-link]: https://zenodo.org/record/4432747/files/futil-artifact-public.ova?download=1
[virtualbox]: https://www.virtualbox.org/
[resource-sharing]: https://capra.cs.cornell.edu/calyx/doc/calyx/passes/struct.ResourceSharing.html
[minimize-registers]: https://capra.cs.cornell.edu/calyx/doc/calyx/passes/struct.MinimizeRegs.html
[systolic-bug]: https://github.com/cucapra/futil-evaluation/issues/3
[xilinx-account]: https://www.xilinx.com/registration/create-account.html
[xilinx-fill-account]: https://forums.xilinx.com/t5/Installation-and-Licensing/What-is-my-user-ID/td-p/1080887
[xilinx-profile]: https://www.xilinx.com/myprofile/edit-profile.html
[parallel-install]: https://www.gnu.org/software/parallel/
