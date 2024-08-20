
# Bulk RNA-Seq Pipeline

This repository contains a comprehensive Bulk RNA-Seq Pipeline designed to handle alignment-based quantification using Salmon. The pipeline was developed and tested on a high-performance computing environment and is designed to process multiple samples efficiently.

## Introduction

This pipeline automates the process of RNA-Seq data quantification using Salmon in alignment-based mode. It takes as input BAM files aligned to a reference genome and outputs quantification results, including counts and normalized TPM values.

### Key Features:
- **Alignment-based quantification using Salmon**
- **Automatic download and preparation of reference files (GRCh37/hg19 and GENCODE v19)**
- **Handling of GC bias and sequence bias corrections**
- **Generation of gene count and TPM matrices using R**

## Pipeline Overview

The pipeline consists of the following main steps:
1. **Download and prepare reference files**: Downloads the GRCh37/hg19 reference genome and GENCODE v19 annotation files if not already present.
2. **Salmon quantification**: Runs Salmon in alignment-based mode to quantify RNA-Seq data from BAM files.
3. **Gene count and TPM matrices**: Creates a gene count matrix and a normalized TPM matrix using R.

## Installation

To run this pipeline, follow these steps:

1. Clone the repository:

    ```bash
    git clone https://github.com/your-username/bulk-rnaseq-pipeline.git
    cd bulk-rnaseq-pipeline
    ```

2. Ensure that you have the following dependencies installed:
   - **Miniconda**
   - **Salmon**
   - **gffread**
   - **R** with the required packages (`tximport`, `readr`, `dplyr`)

3. Create a conda environment:

    ```bash
    conda create -n spatial python=3.11
    conda activate spatial
    conda install salmon gffread r-base
    ```

## Usage

1. Copy the provided script (`bulk_rnaseq_pipeline.sh`) to your working directory.
2. Ensure that your BAM files are organized in the expected directory structure.
3. Run the script with `sbatch` to submit it as a job:

    ```bash
    sbatch bulk_rnaseq_pipeline.sh
    ```

The output files will be generated in the `salmon_output` directory, including the gene count matrix and TPM matrix.

## Challenges and Solutions

### 1. Missing Contigs in the Transcriptome FASTA
**Problem**: The initial Salmon quantification step failed due to missing contigs (e.g., `GL000192.1`) in the transcriptome FASTA file generated from the GTF.

**Solution**: The transcriptome FASTA file was regenerated to include all contigs present in the BAM file header using `gffread` and the full GRCh37 reference genome.

### 2. Alignment-Based Mode Configuration
**Problem**: When running Salmon in alignment-based mode, certain options were not recognized, such as the `-t` option intended for transcriptome-based quantification.

**Solution**: The script was updated to correctly configure Salmon for alignment-based mode by removing the `-t` option and ensuring the `--targets` option was used to specify the reference genome.

### 3. Inconsistent Chromosome Naming
**Problem**: The pipeline encountered issues with inconsistent chromosome naming, particularly with the mitochondrial chromosome (`M` vs `MT`).

**Solution**: The GTF file was modified to ensure consistent chromosome naming by replacing `M` with `MT`.

### 4. Unexpected Salmon Errors
**Problem**: During the troubleshooting process, several unexpected errors surfaced, including missing options or failed steps in Salmon.

**Solution**: Each error was carefully analyzed and resolved by adjusting the pipeline script, ensuring that the correct options were passed to Salmon and that all required files were available.

## Final Notes

This pipeline has been extensively tested and is capable of handling complex RNA-Seq quantification tasks. It is designed to work efficiently in high-performance computing environments. We encourage others to use this pipeline and contribute to its further development.

If you encounter any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request.

### License
This project is licensed under the MIT License.
