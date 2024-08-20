<h1 align="center">
  <br>
  <img src="https://raw.githubusercontent.com/s-andrews/FastQC/master/src/main/resources/uk/ac/babraham/FastQC/Resources/fastqc_icon.png" alt="Bulk RNA-Seq Pipeline" width="200">
  <br>
  Bulk RNA-Seq Pipeline
  <br>
</h1>

<h4 align="center">A comprehensive pipeline for processing and quantifying RNA-Seq data using Salmon</h4>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#detailed-workflow">Detailed Workflow</a> •
  <a href="#troubleshooting">Troubleshooting</a> •
  <a href="#output">Output</a> •
  <a href="#license">License</a>
</p>

<p align="center">
  <img src="https://mermaid.ink/img/pako:eNqFk11v2jAUhv-K5auBEkjCR0IKu9hFpU2aNG3aRW-Q45yAF8eObAcYVf97bSdQoFSbLhLsnPc5r4-Pj-SaBSdYqLCqTG6p1SIvqUMPJlP5ylSJQBzBY5tPZZPhwGBNg2wC8-GMYFmDpLUhjGGeERpGiaqS-PzxfAY3t1cEP-DdIGbQNtQYrCgM4HhgaHwP1x4Md9BFsDLNn-Xg8Vhg8bQDdOXyL_0EGtYNCofUu_fQE7LMdqXnHXkIbKhAq2knzbkr-gG6lKUxlGeELSxwrWnTTBCeakOZz6qWOqk2pJhPaSEdLVu76fSl1cBKJTJTCyTzUoAsjVjRglBrXFIVhcGXRCyEe10nCzN_yCJ0yjT2uy8vdx_qZvWw6qbVQQhbq-Qk3OuS5Nz2MF0YXeK4R3_q0FKGQCM0gvCVpfLBSV2jNR5m9SG9pJX0e4DnRlfO9kH-IzV4_Kz7M-5pvQ-J-_vHXfSXnEgVp6N_1fHlFCGcrx-u-4Hj8TvHP0w-nE_C4Xg0-TwcwPn1zVU48lwMsP3lzcRzMcIB9GCQ5GWONhwkr_7GfgfjKFGiRC3PkQWl2OArlaLkRRtIgK-oTXhVbJNrVbIkFVSWVZwWUrHAubhNjVy4_3nRcqqVY0E0XOQbxLh2x3Gzxam5E8yCRuQ1dbuZDCL37w0Lcp7AynbNF9rWru6WBXUpnPR2p1UD7vVupkKpdOG6uzRQM8yzr_t_dQ3mj9Gj" alt="Pipeline Overview" width="800">
</p>

## 🌟 Key Features

- 🔍 **Alignment-based quantification** using Salmon v1.10.3
- 🧠 **Automatic reference handling**: Downloads and prepares genome and annotation files
- 🧮 **Bias correction**: Applies GC bias and sequence bias correction
- 📊 **Comprehensive output**: Generates both gene count and TPM matrices
- 🚄 **Parallel processing**: Efficiently handles multiple samples
- 🔧 **Flexible and robust**: Adaptable to various RNA-Seq project scales

## 🚀 How To Use

### Prerequisites

Before you begin, ensure you have the following installed:
- SLURM workload manager
- Miniconda or Anaconda
- Git (for cloning the repository)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/bulk-rnaseq-pipeline.git
   cd bulk-rnaseq-pipeline
   ```

2. **Set up the Conda environment**
   ```bash
   conda create -n rnaseq_env python=3.11
   conda activate rnaseq_env
   conda install -c bioconda salmon=1.10.3 gffread
   conda install -c r r-base r-tximport r-readr r-dplyr
   ```

3. **Configure the pipeline**
   Edit the `bulk_rnaseq_pipeline.sh` script to set the correct paths for your environment:
   ```bash
   nano bulk_rnaseq_pipeline.sh
   ```
   Adjust the `BASE_DIR` variable to point to your project directory.

### Running the Pipeline

1. **Prepare your data**
   Organize your BAM files in the following structure:
   ```
   /N/project/cytassist/masood_colon_300/
   ├── sample1/
   │   └── RS.v2-RNA-*/
   │       └── *_T_sorted.bam
   ├── sample2/
   │   └── RS.v2-RNA-*/
   │       └── *_T_sorted.bam
   └── ...
   ```

2. **Submit the job**
   ```bash
   sbatch bulk_rnaseq_pipeline.sh
   ```

3. **Monitor progress**
   Check the status of your job:
   ```bash
   squeue -u your_username
   ```
   View the log file for detailed progress:
   ```bash
   tail -f slurm-JOBID.out
   ```

## 📋 Detailed Workflow

### 1. Setup and Preparation 🛠️

- **Reference Genome Download**: 
  - Checks for the existence of the GRCh37/hg19 reference genome.
  - If not found, downloads it from the Ensembl FTP server.
  - Decompresses the downloaded file.

- **Gene Annotation Download**:
  - Verifies the presence of the GENCODE v19 GTF file.
  - Downloads the file if it's not available locally.
  - Removes unwanted prefixes from chromosome names in the GTF file.

### 2. Transcriptome Generation 🧬

- Uses `gffread` to generate a transcriptome FASTA file from the reference genome and GTF annotation.
- Ensures all contigs present in BAM files are included in the transcriptome.

### 3. Salmon Index Creation 📚

- Creates a Salmon index from the generated transcriptome FASTA file.
- This index is used for efficient quantification in subsequent steps.

### 4. Sample Processing 🔬

- Iterates through all sample directories matching the pattern `*/RS.v2-RNA-*`.
- For each sample:
  - Locates the BAM file ending with `_T_sorted.bum`.
  - Runs Salmon in alignment-based mode with the following settings:
    - Applies GC bias correction
    - Applies sequence-specific bias correction
    - Uses 4 threads for parallel processing

### 5. Matrix Generation 📊

- After all samples are processed, an R script is executed to:
  - Import quantification results using `tximport`
  - Generate two matrices:
    1. Gene Count Matrix: Raw count data
    2. TPM Matrix: Normalized expression values

## 🛠️ Troubleshooting

<details>
<summary>Click to expand troubleshooting guide</summary>

| Issue | Symptom | Solution |
|-------|---------|----------|
| 🧩 Missing Contigs | Salmon fails due to missing reference sequences | Regenerate transcriptome FASTA with full genome |
| 🔧 Incorrect Salmon Mode | Errors related to incompatible options | Ensure correct options for alignment-based mode |
| 🔤 Chromosome Naming | Inconsistencies between BAM and reference | Standardize chromosome names (e.g., 'M' to 'MT') |
| 💾 Memory Overflow | Job terminates due to insufficient memory | Increase `--mem` in SLURM script; reduce threads |
| 🕒 Time Limit Exceeded | Job terminates before completion | Increase `--time` in SLURM script |

</details>

## 📊 Output

The pipeline generates the following key outputs:

1. **Sample-specific Quantification Results**
   - Location: `/N/project/cytassist/masood_colon_300/salmon_output/[SAMPLE_ID]_quant/`
   - Contents:
     - `quant.sf`: Salmon quantification file
     - `cmd_info.json`: Command information
     - `aux_info/`: Additional metadata and bias models

2. **Gene Count Matrix**
   - File: `/N/project/cytassist/masood_colon_300/gene_count_matrix.csv`
   - Format: CSV with genes as rows and samples as columns
   - Content: Raw count data

3. **TPM Matrix**
   - File: `/N/project/cytassist/masood_colon_300/gene_tpm_matrix.csv`
   - Format: CSV with genes as rows and samples as columns
   - Content: Normalized TPM (Transcripts Per Million) values

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <img src="https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg" alt="Made with Markdown">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Salmon-v1.10.3-ff69b4.svg" alt="Salmon v1.10.3">
</p>

<h4 align="center">🧬 Elevate Your RNA-Seq Analysis with Precision and Efficiency 🚀</h4>
