<h1 align="center">
  <br>
  <img src="https://img.icons8.com/color/96/000000/dna-helix.png" alt="Bulk RNA-Seq Pipeline" width="96">
  <br>
  Bulk RNA-Seq Pipeline v4
  <br>
</h1>

<h4 align="center">A comprehensive pipeline for processing and quantifying RNA-Seq data using Salmon</h4>

<p align="center">
  <a href="#-key-features">Key Features</a> •
  <a href="#-how-to-use">How To Use</a> •
  <a href="#-detailed-workflow">Detailed Workflow</a> •
  <a href="#️-troubleshooting">Troubleshooting</a> •
  <a href="#-output">Output</a> •
  <a href="#-license">License</a>
</p>




<h3 align="center">Pipeline Overview</h3>

<p align="center">
1. Input BAM Files<br>
↓<br>
2. Reference Preparation<br>
↓<br>
3. Salmon Quantification<br>
↓<br>
4. Sample Sheet Creation<br>
↓<br>
5. Matrix Generation<br>
↓<br>
6. Output Files (Gene Count and TPM Matrices)
</p>


## 🌟 Key Features

- 🔍 **Alignment-based quantification** using Salmon v1.10.3
- 🧠 **Automatic reference handling**: Downloads and prepares genome and annotation files
- 🧮 **Bias correction**: Applies GC bias and sequence bias correction
- 📊 **Comprehensive output**: Generates both gene count and TPM matrices
- 🚄 **Parallel processing**: Efficiently handles multiple samples
- 🔧 **Flexible and robust**: Adaptable to various RNA-Seq project scales
- 💾 **Disk space check**: Ensures sufficient space before starting the pipeline

## 🚀 How To Use

### Prerequisites

Before you begin, ensure you have the following:
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
   conda create -n spatial python=3.11
   conda activate spatial
   conda install -c bioconda salmon=1.10.3
   conda install -c r r-base r-tximport r-readr r-dplyr
   ```

3. **Configure the pipeline**
   Edit the `updated_bulk_rnaseq_pipeline_v4.sh` script to set the correct paths for your environment:
   ```bash
   nano updated_bulk_rnaseq_pipeline_v4.sh
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
   sbatch updated_bulk_rnaseq_pipeline_v4.sh
   ```

3. **Monitor progress**
   Check the status of your job:
   ```bash
   squeue -u your_username
   ```
   View the log file for detailed progress:
   ```bash
   tail -f bulk_rnaseq_pipeline.out
   ```

## 📋 Detailed Workflow

### 1. Setup and Preparation 🛠️

- **Disk Space Check**:
  - Ensures at least 10GB of free space is available before starting.

- **Reference Genome Download**: 
  - Checks for the existence of `GRCh37.primary_assembly.genome.fa`.
  - If not found, downloads from Ensembl FTP server and renames.

- **Gene Annotation Download**:
  - Verifies the presence of `gencode.v19.annotation.gtf`.
  - Downloads if not available locally.

- **Annotation Processing**:
  - Removes 'chr' prefix from chromosome names.
  - Ensures consistency by replacing 'M' with 'MT' for mitochondrial genes.

- **Transcript to Gene Mapping**:
  - Generates `tx2gene_gencodev19.txt` file for later use in R script.

### 2. Salmon Quantification 🐟

- Iterates through all sample directories matching the pattern `*/RS.v2-RNA-*`.
- For each sample:
  - Locates the BAM file ending with `_T_sorted.bam`.
  - Runs Salmon in alignment-based mode with the following settings:
    - Uses the prepared reference genome as targets.
    - Applies GC bias correction (`--gcBias`).
    - Applies sequence-specific bias correction (`--seqBias`).
    - Uses specified number of threads for parallel processing.

### 3. Sample Sheet Creation 📝

- Generates `samples.txt` containing sample names and paths to Salmon quantification files.

### 4. Matrix Generation 📊

- Creates and executes an R script to:
  - Import quantification results using `tximport`.
  - Generate two matrices:
    1. Gene Count Matrix: Raw count data (`gene_count_matrix.csv`).
    2. TPM Matrix: Normalized expression values (`gene_tpm_matrix.csv`).



## 🛠️ Troubleshooting

<details>
<summary>Click to expand troubleshooting guide</summary>

| Issue | Symptom | Solution |
|-------|---------|----------|
| 💾 Insufficient Disk Space | Pipeline fails to start | Ensure at least 10GB free space in `BASE_DIR` |
| 🔧 Salmon Quantification Failure | Error in Salmon quantification step | Check Salmon log for specific errors; ensure BAM files are valid |
| 📊 R Script Execution Error | Failure in matrix generation step | Verify R packages are correctly installed; check R script for syntax errors |
| 🕒 Time Limit Exceeded | Job terminates before completion | Increase `--time` in SLURM script (currently set to 72 hours) |
| 💾 Memory Overflow | Job terminates due to insufficient memory | Adjust `--mem` in SLURM script (currently set to 400G) |
| 🧩 Missing Contigs in Transcriptome FASTA | Salmon fails due to missing reference sequences | Regenerate transcriptome FASTA using full GRCh37 reference genome and GENCODE v19 annotation |
| 🔧 Incorrect Salmon Mode | Errors related to incompatible options | Ensure correct options for alignment-based mode are used (current script uses appropriate options) |
| 🔤 Chromosome Naming Inconsistency | Mismatches between BAM and reference chromosome names | Script now standardizes chromosome names (removes 'chr' prefix, changes 'M' to 'MT') |
| 🔍 Salmon Index Creation Failure | Error when creating Salmon index | Verify integrity of downloaded reference files; ensure sufficient disk space |
| 📁 Input File Structure | Salmon fails to find input files | Ensure BAM files are correctly named (*_T_sorted.bam) and located in the expected directory structure |
| 🧪 Sample Sheet Generation Error | Failure in creating samples.txt | Check write permissions in BASE_DIR; verify Salmon output structure |
| 📈 tximport Error | R script fails during tximport step | Ensure tx2gene file is correctly generated; check Salmon output files for consistency |

</details>



## 📊 Output

The pipeline generates the following key outputs:

1. **Sample-specific Quantification Results**
   - Location: `/N/project/cytassist/masood_colon_300/salmon_output/[SAMPLE_ID]_quant/`
   - Contents:
     - `quant.sf`: Salmon quantification file

2. **Gene Count Matrix**
   - File: `/N/project/cytassist/masood_colon_300/gene_count_matrix.csv`
   - Format: CSV with genes as rows and samples as columns
   - Content: Raw count data

3. **TPM Matrix**
   - File: `/N/project/cytassist/masood_colon_300/gene_tpm_matrix.csv`
   - Format: CSV with genes as rows and samples as columns
   - Content: Normalized TPM (Transcripts Per Million) values

4. **Auxiliary Files**
   - `samples.txt`: List of samples and their quantification file paths
   - `tx2gene_gencodev19.txt`: Transcript to gene mapping file

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <img src="https://img.shields.io/badge/Made%20with-Bash-1f425f.svg" alt="Made with Bash">
  <img src="https://img.shields.io/badge/Made%20with-R-276DC3.svg" alt="Made with R">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Salmon-v1.10.3-ff69b4.svg" alt="Salmon v1.10.3">
</p>

<h4 align="center">🧬 Elevate Your RNA-Seq Analysis with Precision and Efficiency 🚀</h4>
