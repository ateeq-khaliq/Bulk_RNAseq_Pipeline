# RNA-seq Analysis Pipeline with featureCounts

## Table of Contents
- [Introduction](#introduction)
- [Pipeline Overview](#pipeline-overview)
- [Key Features](#key-features)
- [Requirements](#requirements)
- [Folder Structure](#folder-structure)
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

## Folder Structure

```
/N/project/cytassist/masood_colon_300/
│
├── [sample_id]/
│   └── RS.v2-RNA-[timestamp]/
│       └── [sample_id]_T_sorted.bam
│
├── featurecounts_output/
│   ├── gene_counts.txt
│   ├── processed_gene_counts.csv
│   └── analysis_info.txt
│
├── gencode.v19.annotation.gtf
├── bam_files.txt
├── process_counts.R
└── integrated_rnaseq_pipeline.sh
```

### Input Folder Structure
- The base directory `/N/project/cytassist/masood_colon_300/` contains subdirectories for each sample.
- Each sample subdirectory contains an `RS.v2-RNA-[timestamp]` folder.
- Within these folders, you'll find BAM files named `[sample_id]_T_sorted.bam`.

### Output Folder
- All output files will be in the `featurecounts_output/` directory within the base directory.

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

In the `featurecounts_output/` directory, you will find:

1. `gene_counts.txt`: 
   - Raw output from featureCounts
   - Contains detailed information about the counting process
   - Includes gene IDs, chromosome, start, end, strand, length, and counts for each sample

2. `processed_gene_counts.csv`:
   - A simplified gene-by-sample count matrix
   - Rows represent genes, columns represent samples
   - Values are the raw count of reads assigned to each gene in each sample

3. `analysis_info.txt`:
   - Contains metadata about the analysis run
   - Includes information such as the date of analysis, featureCounts version, and whether data was processed as single-end or paired-end

Additionally, in the base directory:

4. `bam_files.txt`:
   - A list of all BAM files processed by the pipeline

5. `process_counts.R`:
   - The R script used to convert the raw featureCounts output into the processed count matrix

## FAQs

**Q: Why use featureCounts instead of Salmon?**

A: While both tools are excellent for RNA-seq quantification, featureCounts was chosen for this pipeline due to its direct compatibility with the provided BAM files and its straightforward approach to gene-level counting. Salmon typically requires raw FASTQ files for optimal performance.

**Q: The script says "Single-end reads are included". What does this mean?**

A: This indicates that featureCounts has detected your data as single-end. This could be due to the original sequencing method or upstream processing of the data. Single-end data is perfectly valid for many RNA-seq analyses, including differential gene expression studies.

**Q: Is single-end data sufficient for my analysis?**

A: For many applications, especially gene-level expression analysis, single-end data provides robust and reliable results. It allows for cost-effective analysis of more samples, which can be beneficial for experiments requiring larger sample sizes.

**Q: What should I do if my input files are not in the expected location?**

A: Modify the `BASE_DIR` variable in the script to point to the correct location of your input files. Ensure that your BAM files follow the naming convention `[sample_id]_T_sorted.bam` and are located in directories matching the structure described in the Folder Structure section.

## Troubleshooting

If you encounter issues:

1. Check that all required software is installed and accessible
2. Ensure input BAM files are in the expected location and format
3. Verify that the SLURM parameters match your system's capabilities
4. Check the error log files for specific error messages

Common issues:
- If featureCounts fails to run, ensure that the annotation file (gencode.v19.annotation.gtf) is present in the base directory
- If the R script fails, make sure the data.table package is installed in your R environment

## Contributing

Contributions to improve the pipeline are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

Developed with ❤️ for RNA-seq analysis
