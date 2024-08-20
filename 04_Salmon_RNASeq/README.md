```ascii
 ____        _ _      ____  _   _    _       ____            ____  _            _ _            
|  _ \      | | |    |  _ \| \ | |  / \     / ___|  ___  __ |  _ \(_)_ __   ___| (_)_ __   ___ 
| |_) |_   _| | | __ | |_) |  \| | / _ \    \___ \ / _ \/ _ \ |_) | | '_ \ / _ \ | | '_ \ / _ \
|  _ <| | | | | |/ / |  _ <| |\  |/ ___ \    ___) |  __/  __/  __/| | |_) |  __/ | | | | |  __/
|_| \_\ |_|_|_|_|___||_| \_\_| \_/_/   \_\  |____/ \___|\___| |  _|_| .__/ \___| |_|_| |_|\___|
                                                                       |_|                     
```

# 🧬 Bulk RNA-Seq Pipeline 🚀

Welcome to the **Bulk RNA-Seq Pipeline** repository! This pipeline is designed to process and quantify RNA-Seq data using alignment-based quantification with Salmon. It automates the preparation of reference files, runs the Salmon quantification step, and generates final output matrices for downstream analysis.

![Pipeline Overview](https://mermaid.ink/img/pako:eNp1kc9OwzAMxl8l8mmVtq7rn3U7bBxAaAhx4JZD27BFtHEVp2gT2rsTO-1AQoC4JP58P_uLE2YWHGbGrzqjbXF7X1h2OiZpnuepwRddMsFFw6BDI1toPLFBZ7_QSqT0V2JIpAn7xO1HQIdL5OPpgoIQC_-jLwgBx7GoqKuxZcqOdpmzf4pnMBdUcWv-nv5m3wF_x9kJrcZCVQaHKPVsKIUiKOuWtNVgPVY0TScZdezOHMZBJbOXyZXSXlGHDVsGRHqXY89Y0NjRF0sKfMc-g0f6ZA8R4hMgXvlhO8jvYXE4WV1XtYvCx_2T0z7ZKFhtl7i0aMvDqA8SDmgPOhzQ7sEJR0QbLCQ6Uad20_qqR9VoDHEDtg074Mzbe2nMXHU07zYj9A4z98xT_x8RR4-Z)

## 🌟 Key Features

- 🔍 Alignment-based quantification using **Salmon v1.10.3**
- 🧠 Automatic handling of reference genome and annotation downloads
- 🧮 GC bias and sequence bias correction
- 📊 Generation of gene count and TPM matrices in a single run
- 🚄 Processing of multiple samples in parallel

## 📋 Table of Contents

- [Introduction](#-introduction)
- [Pipeline Overview](#-pipeline-overview)
- [Installation](#️-installation)
- [Usage](#-usage)
- [Input and Output](#-input-and-output)
- [Troubleshooting](#️-troubleshooting-challenges-and-solutions)
- [Final Output](#-final-output)
- [Final Notes](#-final-notes)
- [License](#-license)

## 🧬 Introduction

The Bulk RNA-Seq Pipeline provides a streamlined approach to RNA-Seq data analysis. It starts from BAM files, aligns them to a reference genome, and produces gene-level quantification output. This pipeline is especially useful for large-scale RNA-Seq projects where alignment-based quantification is needed.

## 📋 Pipeline Overview

This pipeline is structured into several stages:

1. **Setup** 🛠️: Ensures that the reference genome and annotation files (GRCh37/hg19 and GENCODE v19) are available. If not, it downloads them.
2. **Reference Preparation** 📚: Prepares the reference files, including removing unwanted prefixes from the GTF file and ensuring consistent chromosome naming.
3. **Quantification with Salmon** 🐟: Runs the Salmon quantification step using alignment-based mode, with bias correction enabled. The pipeline automatically detects and processes all BAM files in the input directory.
4. **Output Generation** 📊: After quantification, the pipeline generates two output matrices:
   - **Gene Count Matrix**: A CSV file with raw gene counts.
   - **TPM Matrix**: A CSV file with normalized TPM values.

## 🛠️ Installation

Follow these steps to get the pipeline up and running:

1. **Clone the repository**:

    ```bash
    git clone https://github.com/your-username/bulk-rnaseq-pipeline.git
    cd bulk-rnaseq-pipeline
    ```

2. **Set up the environment**:

   Ensure you have the necessary tools installed:

   - **Miniconda**
   - **Salmon v1.10.3**
   - **gffread**
   - **R** with the following packages: `tximport`, `readr`, `dplyr`

   Create and activate a conda environment:

    ```bash
    conda create -n spatial python=3.11
    conda activate spatial
    conda install salmon gffread r-base
    ```

3. **Modify paths if necessary**:

   Ensure that all paths in the script are correct for your environment.

## 🚀 Usage

1. **Prepare your BAM files**: Organize your BAM files in directories corresponding to each sample under the base directory (e.g., `/N/project/cytassist/masood_colon_300`). The script will automatically detect and process all BAM files in subdirectories that match the pattern `*/RS.v2-RNA-*`.

2. **Run the pipeline**: Submit the job to your cluster using the `sbatch` command:

    ```bash
    sbatch bulk_rnaseq_pipeline.sh
    ```

   The pipeline will automatically process all samples and generate output files in the `salmon_output` directory.

## 🔍 Input and Output

### Input:
- 📁 **BAM files**: Aligned RNA-Seq reads in BAM format. The pipeline automatically detects all BAM files ending with `_T_sorted.bam` in the subdirectories under the base directory.
- 🧬 **Reference genome**: GRCh37/hg19 (automatically downloaded if not available).
- 📘 **Gene annotation**: GENCODE v19 GTF file (also downloaded if not available).

### Output:
- 📊 **Quantification Results**: For each sample, the quantification results from Salmon are stored in a subdirectory under `salmon_output`, named after the sample.
- 📈 **Gene Count Matrix**: `gene_count_matrix.csv`, located in the base directory.
- 📉 **TPM Matrix**: `gene_tpm_matrix.csv`, located in the base directory.
- 📝 **Salmon Logs**: Detailed logs for each sample's quantification process are stored within the corresponding sample subdirectory in `salmon_output`.

## 🛠️ Troubleshooting: Challenges and Solutions

| Problem | Solution |
|---------|----------|
| 🧩 Missing Contigs in the Transcriptome FASTA | Regenerated transcriptome FASTA using full GRCh37 reference genome and GENCODE v19 annotation |
| 🔧 Alignment-Based Mode Configuration | Modified script to use correct options for alignment-based mode |
| 🔤 Inconsistent Chromosome Naming | Modified GTF file to ensure consistent chromosome naming |
| ⚙️ Option Handling in Salmon | Updated script to handle Salmon's specific requirements for alignment-based mode |
| 💾 Out of Memory (OOM) Issues | Adjusted memory allocation and reduced number of threads |

## 📊 Final Output

After successfully running the pipeline, you will obtain:
- 📁 **Quantification Results**: Each sample's quantification output is stored in a separate subdirectory under `salmon_output`.
- 📈 **Gene Count Matrix** (`gene_count_matrix.csv`): Located in the base directory.
- 📉 **TPM Matrix** (`gene_tpm_matrix.csv`): Located in the base directory.

These matrices are ready for downstream analysis, including differential expression analysis, clustering, and visualization.

## 📝 Final Notes

This Bulk RNA-Seq Pipeline is designed to be flexible, robust, and scalable. Whether you're processing a small number of samples or a large-scale RNA-Seq dataset, this pipeline provides a streamlined solution to get accurate quantification results.

If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request. Contributions are welcome!

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

---

<p align="center">
  <img src="https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg" alt="Made with Markdown">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Salmon-v1.10.3-ff69b4.svg" alt="Salmon v1.10.3">
</p>

<p align="center">🧬 Happy RNA-Seq Analysis! 🚀</p>
```
