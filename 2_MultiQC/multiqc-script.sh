#!/bin/bash
#SBATCH --mail-user=akhaliq@iu.edu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --job-name=multiqc_analysis
#SBATCH --error=multiqc_analysis.error
#SBATCH --output=multiqc_analysis.out
#SBATCH --time=4:00:00
#SBATCH --mem=32G
#SBATCH --partition=general
#SBATCH --account=r00583

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "/N/project/cytassist/masood_colon_300/multiqc_analysis.log"
}

# Start logging
log_message "Starting MultiQC analysis job"

# Load necessary modules
module load miniconda
conda activate spatial

# Check if MultiQC is available
if ! command -v multiqc &> /dev/null; then
    log_message "ERROR: MultiQC not found. Please ensure it's installed in the 'spatial' conda environment."
    exit 1
fi

# Set the FastQC output directory (input for MultiQC)
FASTQC_DIR="/N/project/cytassist/masood_colon_300/fastqc_output"

# Set the MultiQC output directory
MULTIQC_DIR="/N/project/cytassist/masood_colon_300/multiqc_output"
mkdir -p "$MULTIQC_DIR"

# Run MultiQC
log_message "Running MultiQC on FastQC output"
multiqc "$FASTQC_DIR" -o "$MULTIQC_DIR" --interactive --filename "multiqc_report_$(date +%Y%m%d)"

log_message "MultiQC analysis complete. Results are in $MULTIQC_DIR"

# Deactivate conda environment
conda deactivate

exit 0
