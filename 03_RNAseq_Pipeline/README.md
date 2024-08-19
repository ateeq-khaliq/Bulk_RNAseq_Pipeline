
# Comprehensive Bulk RNA-seq Analysis Pipeline

## Table of Contents
1. [Introduction](#introduction)
2. [Pipeline Overview](#pipeline-overview)
3. [Prerequisites](#prerequisites)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Pipeline Steps](#pipeline-steps)
7. [Output Files](#output-files)
8. [Customization](#customization)
9. [Troubleshooting](#troubleshooting)
10. [Contributing](#contributing)
11. [License](#license)
12. [Acknowledgments](#acknowledgments)
13. [Contact](#contact)

## Introduction

This repository contains a comprehensive pipeline for analyzing bulk RNA-sequencing (RNA-seq) data. The pipeline is designed to process BAM files from RNA-seq experiments, perform transcript quantification, and generate gene expression matrices for downstream analysis. It utilizes state-of-the-art tools and follows best practices in the field of RNA-seq analysis.

The pipeline is optimized for use on high-performance computing clusters that use the SLURM workload manager, making it suitable for processing large-scale RNA-seq datasets efficiently.

## Pipeline Overview

Our pipeline consists of the following main steps:

1. **Reference Preparation**: Download and prepare reference genome, annotation files, and transcriptome.
2. **Index Generation**: Create a Salmon index for efficient transcript quantification.
3. **Transcript Quantification**: Use Salmon to quantify transcript expression from BAM files.
4. **Expression Matrix Generation**: Aggregate transcript-level quantifications to gene-level counts and TPM (Transcripts Per Million) values.

The pipeline uses the following key tools:

- **Salmon**: For fast and accurate transcript quantification
- **gffread**: To generate transcriptome sequences from genome and annotation files
- **R** with **tximport**: For aggregating transcript-level quantifications to gene-level counts

## Prerequisites

To run this pipeline, you need:

1. Access to a Linux-based high-performance computing environment with SLURM
2. Anaconda or Miniconda installed
3. R (version 3.6 or higher)
4. Input BAM files from your RNA-seq experiments

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/bulk-rnaseq-pipeline.git
   cd bulk-rnaseq-pipeline
   ```

2. Create and activate the conda environment:
   ```
   conda env create -f environment.yml
   conda activate rnaseq_env
   ```

3. Ensure you have the necessary R packages installed:
   ```R
   if (!requireNamespace("BiocManager", quietly = TRUE))
       install.packages("BiocManager")
   
   BiocManager::install(c("tximport", "readr", "dplyr"))
   ```

## Usage

1. Edit the `complete_rnaseq_pipeline.sh` script to set your project-specific parameters:
   - `BASE_DIR`: Path to your project directory
   - SLURM parameters (nodes, tasks, CPUs, memory, etc.)
   - Email for job notifications

2. Make the script executable:
   ```
   chmod +x complete_rnaseq_pipeline.sh
   ```

3. Submit the job to SLURM:
   ```
   sbatch complete_rnaseq_pipeline.sh
   ```

## Pipeline Steps

1. **Download Reference Files**:
   - Reference genome (GRCh38 no-alt analysis set)
   - Gene annotation (GENCODE v36)
   - Generate transcript-to-gene mapping file

2. **Generate Transcriptome**:
   - Use gffread to create a transcriptome FASTA file from the genome and annotation

3. **Create Salmon Index**:
   - Build an index of the transcriptome for efficient quantification

4. **Salmon Quantification**:
   - Process each BAM file with Salmon to quantify transcript expression
   - Apply GC bias and sequence-specific bias correction

5. **Create Sample Sheet**:
   - Generate a file listing all processed samples and their quantification files

6. **Generate Count Matrices**:
   - Use R and tximport to create gene-level count and TPM matrices

## Output Files

The pipeline generates the following key output files:

1. `gene_count_matrix.csv`: A matrix of raw gene counts for all samples
2. `gene_tpm_matrix.csv`: A matrix of TPM-normalized gene expression values for all samples
3. Individual Salmon quantification directories for each sample
4. `samples.txt`: A sample sheet listing all processed samples

## Customization

You can customize the pipeline by modifying the `complete_rnaseq_pipeline.sh` script. Common customizations include:

- Adjusting SLURM parameters for your computing environment
- Changing the reference genome or annotation versions
- Modifying Salmon parameters for specific analysis needs
- Altering the R script to perform additional downstream analyses

## Troubleshooting

Common issues and their solutions:

1. **Missing reference files**: Ensure you have internet access to download reference files, or manually place them in the `BASE_DIR`.
2. **Insufficient disk space**: Check that your project directory has enough space for reference files and output.
3. **Memory errors**: Adjust the `--mem` parameter in the SLURM header if you encounter out-of-memory errors.
4. **Missing R packages**: Ensure all required R packages are installed in your conda environment.

## Contributing

We welcome contributions to improve this pipeline. Please feel free to submit issues or pull requests on GitHub.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- The developers of Salmon, gffread, and the R/Bioconductor community
- The GENCODE project for providing comprehensive gene annotations
- The high-performance computing support team at Indiana University

## Contact

For questions or support, please contact:
Ateeq Khaliq - akhaliq@iu.edu

---

We hope this pipeline proves useful for your RNA-seq analysis needs. Happy sequencing!
```
