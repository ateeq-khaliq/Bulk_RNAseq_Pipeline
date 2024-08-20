
# 🚀 Bulk RNA-Seq Pipeline 🚀

Welcome to the **Bulk RNA-Seq Pipeline** repository! This pipeline is designed to process and quantify RNA-Seq data using alignment-based quantification with Salmon. It automates the preparation of reference files, runs the Salmon quantification step, and generates final output matrices for downstream analysis. The pipeline is optimized for use in high-performance computing environments.

## 🧬 Introduction

The Bulk RNA-Seq Pipeline provides a streamlined approach to RNA-Seq data analysis. It starts from BAM files, aligns them to a reference genome, and produces gene-level quantification output. This pipeline is especially useful for large-scale RNA-Seq projects where alignment-based quantification is needed.

### Key Features
- **Alignment-based quantification using Salmon v1.10.3**
- **Automatic handling of reference genome and annotation downloads**
- **GC bias and sequence bias correction**
- **Generation of gene count and TPM matrices in a single run**

## 📋 Pipeline Overview

This pipeline is structured into several stages:

1. **Setup**: Ensures that the reference genome and annotation files (GRCh37/hg19 and GENCODE v19) are available. If not, it downloads them.
2. **Reference Preparation**: Prepares the reference files, including removing unwanted prefixes from the GTF file and ensuring consistent chromosome naming.
3. **Quantification with Salmon**: Runs the Salmon quantification step using alignment-based mode, with bias correction enabled.
4. **Output Generation**: After quantification, the pipeline generates two output matrices:
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

1. **Prepare your BAM files**: Organize your BAM files in directories corresponding to each sample.
2. **Run the pipeline**: Submit the job to your cluster using the `sbatch` command:

    ```bash
    sbatch bulk_rnaseq_pipeline.sh
    ```

   The pipeline will automatically process all samples and generate output files in the `salmon_output` directory.

## 🔍 Input and Output

### Input:
- **BAM files**: Aligned RNA-Seq reads in BAM format.
- **Reference genome**: GRCh37/hg19 (automatically downloaded if not available).
- **Gene annotation**: GENCODE v19 GTF file (also downloaded if not available).

### Output:
- **Gene Count Matrix**: `gene_count_matrix.csv`
- **TPM Matrix**: `gene_tpm_matrix.csv`
- **Salmon Logs**: Detailed logs for each sample’s quantification process.

## 🛠️ Troubleshooting: Challenges and Solutions

### 1. Missing Contigs in the Transcriptome FASTA
**Problem**: Salmon failed due to missing contigs in the transcriptome FASTA, leading to errors.

**Solution**: The transcriptome FASTA file was regenerated using the full GRCh37 reference genome and GENCODE v19 annotation. This ensured that all contigs present in the BAM file header were included.

### 2. Alignment-Based Mode Configuration
**Problem**: The pipeline initially used options intended for transcriptome-based quantification, which caused errors in alignment-based mode.

**Solution**: The script was modified to remove incorrect options and use alignment-based mode configuration. The `--targets` option was added to specify the reference genome.

### 3. Inconsistent Chromosome Naming
**Problem**: The pipeline encountered issues with inconsistent chromosome naming, particularly the mitochondrial chromosome (`M` vs `MT`).

**Solution**: The GTF file was modified to ensure consistent chromosome naming by replacing `M` with `MT`, making it compatible with the reference genome.

### 4. Option Handling in Salmon
**Problem**: Salmon required different options depending on the mode (alignment-based vs transcriptome-based). Errors were raised when incorrect options were used.

**Solution**: The script was iteratively updated to handle Salmon’s specific requirements for alignment-based mode, ensuring proper option usage and configuration.

## 📊 Final Output

After successfully running the pipeline, you will obtain:
- A **gene count matrix** (`gene_count_matrix.csv`) with raw counts.
- A **TPM matrix** (`gene_tpm_matrix.csv`) with normalized transcript abundance.

These matrices are ready for downstream analysis, including differential expression analysis, clustering, and visualization.

## 📝 Final Notes

This Bulk RNA-Seq Pipeline is designed to be flexible, robust, and scalable. Whether you're processing a small number of samples or a large-scale RNA-Seq dataset, this pipeline provides a streamlined solution to get accurate quantification results.

If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request. Contributions are welcome!

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

