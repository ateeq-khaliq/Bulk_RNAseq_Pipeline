# RNA-seq Analysis Pipeline with featureCounts

## Table of Contents
- [Introduction](#introduction)
- [Pipeline Overview](#pipeline-overview)
- [Key Features](#key-features)
- [Requirements](#requirements)
- [Usage](#usage)
- [Script Breakdown](#script-breakdown)
- [Output](#output)
- [FAQs](#faqs)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This repository contains a comprehensive RNA-seq analysis pipeline designed to process BAM files and generate gene-level counts using featureCounts. The pipeline was developed to address specific requirements for analyzing single-end RNA-seq data from colon samples.

## Pipeline Overview

1. **Input**: BAM files (aligned reads)
2. **Process**: Gene-level quantification using featureCounts
3. **Output**: Raw counts and processed gene count matrix

## Key Features

- Automatic detection of single-end/paired-end data
- Robust handling of input BAM files
- Integration with SLURM job scheduler
- Comprehensive error checking and reporting
- Efficient processing of multiple samples

## Requirements

- SLURM job scheduler
- Conda (with 'spatial' environment)
- R (with data.table package)
- featureCounts (part of the Subread package)
- samtools

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/your-username/rnaseq-featurecounts-pipeline.git
   ```

2. Navigate to the project directory:
   ```
   cd rnaseq-featurecounts-pipeline
   ```

3. Modify the script parameters if necessary (e.g., `BASE_DIR`, SLURM settings)

4. Submit the job to SLURM:
   ```
   sbatch integrated_rnaseq_pipeline.sh
   ```

## Script Breakdown

The main script (`integrated_rnaseq_pipeline.sh`) performs the following steps:

1. Sets up the environment and loads necessary modules
2. Locates input BAM files
3. Checks if data is single-end or paired-end
4. Runs featureCounts for gene-level quantification
5. Processes the output into a convenient matrix format

## Output

- `gene_counts.txt`: Raw output from featureCounts
- `processed_gene_counts.csv`: Gene-by-sample count matrix
- `analysis_info.txt`: Information about the analysis run

## FAQs

**Q: Why use featureCounts instead of Salmon?**

A: While both tools are excellent for RNA-seq quantification, featureCounts was chosen for this pipeline due to its direct compatibility with the provided BAM files and its straightforward approach to gene-level counting. Salmon typically requires raw FASTQ files for optimal performance.

**Q: The script says "Single-end reads are included". What does this mean?**

A: This indicates that featureCounts has detected your data as single-end. This could be due to the original sequencing method or upstream processing of the data. Single-end data is perfectly valid for many RNA-seq analyses, including differential gene expression studies.

**Q: Is single-end data sufficient for my analysis?**

A: For many applications, especially gene-level expression analysis, single-end data provides robust and reliable results. It allows for cost-effective analysis of more samples, which can be beneficial for experiments requiring larger sample sizes.

## Troubleshooting

If you encounter issues:

1. Check that all required software is installed and accessible
2. Ensure input BAM files are in the expected location and format
3. Verify that the SLURM parameters match your system's capabilities
4. Check the error log files for specific error messages

## Contributing

Contributions to improve the pipeline are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

Developed with ❤️ for RNA-seq analysis
