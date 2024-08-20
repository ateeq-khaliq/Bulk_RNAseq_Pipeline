# MultiQC Analysis of FastQC Results

![MultiQC Logo](https://raw.githubusercontent.com/MultiQC/MultiQC/master/docs/images/MultiQC_logo.png)

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Usage](#usage)
- [MultiQC Results Summary](#multiqc-results-summary)
- [Detailed Findings](#detailed-findings)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Overview

This project performs a comprehensive quality control analysis on high-throughput sequencing data using MultiQC. It aggregates results from FastQC runs on multiple samples, providing a centralized and interactive report for easy interpretation of sequencing quality metrics.

## Project Structure

```
project/
│
├── fastqc_output/        # Directory containing FastQC results
├── multiqc_output/       # Directory for MultiQC report output
├── multiqc_analysis.sh   # SLURM job script for running MultiQC
├── multiqc_analysis.log  # Log file for MultiQC execution
└── README.md             # This file
```

## Requirements

- SLURM workload manager
- Conda
- MultiQC (installed in a conda environment named 'spatial')
- FastQC (results should be available in the fastqc_output directory)

## Usage

To run the MultiQC analysis:

1. Ensure all FastQC results are in the `fastqc_output` directory.
2. Submit the SLURM job:

```bash
sbatch multiqc_analysis.sh
```

The script will:
- Activate the 'spatial' conda environment
- Run MultiQC on the FastQC output
- Generate an interactive report in the `multiqc_output` directory

## MultiQC Results Summary

The MultiQC analysis was performed on 123 samples. Here are the key findings:

- **Sequence Quality**: Overall, the sequence quality across all samples is high, with most bases having quality scores above 28.
- **GC Content**: The average GC content across samples is 50%, which is within the expected range for human genomic data.
- **Sequence Duplication**: The duplication levels are generally low, with an average of 16.8% duplicated reads across all samples.
- **Adapter Content**: Minimal adapter contamination was observed, with less than 0.1% of reads containing adapters in most samples.
- **Overrepresented Sequences**: 123 samples had less than 1% of reads made up of overrepresented sequences, indicating good library complexity.

## Detailed Findings

1. **Per Base Sequence Quality**: 
   - All samples showed high quality scores across the entire read length.
   - The median quality score remained above 30 for all bases in most samples.

2. **Per Sequence Quality Scores**:
   - The majority of sequences in all samples had average quality scores above 30.
   - No samples showed abnormal distributions of per-sequence quality scores.

3. **Per Base Sequence Content**:
   - The base composition was consistent across read positions for most samples.
   - Some samples showed slight fluctuations in base composition at the start of reads, which is common in RNA-Seq data due to random hexamer priming.

4. **Per Sequence GC Content**:
   - The observed GC content distribution closely matched the theoretical distribution in most samples.
   - No signs of contamination or abnormal library preparation were observed based on GC content.

5. **Sequence Length Distribution**:
   - All samples showed a consistent read length of 77 bp, indicating no issues with read trimming or fragmentation.

6. **Sequence Duplication Levels**:
   - The average duplication rate of 16.8% is acceptable for RNA-Seq data.
   - No samples showed extremely high duplication rates that would indicate PCR bias.

7. **Overrepresented Sequences**:
   - The low percentage of overrepresented sequences suggests good library complexity and absence of significant contamination.

8. **Adapter Content**:
   - The minimal adapter contamination indicates effective adapter trimming or high-quality library preparation.

## Troubleshooting

If you encounter any issues:

1. Check the `multiqc_analysis.log` file for error messages.
2. Ensure all required modules are available and the 'spatial' conda environment is properly set up.
3. Verify that the FastQC output files are present in the correct directory.

## Contributing

Contributions to improve the analysis pipeline are welcome. Please fork the repository and submit a pull request with your proposed changes.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contact

For any queries regarding this analysis, please contact:

**Ateeq Khaliq**  
Email: akhaliq@iu.edu

---

<p align="center">Created with ❤️ by Ateeq Khaliq</p>
