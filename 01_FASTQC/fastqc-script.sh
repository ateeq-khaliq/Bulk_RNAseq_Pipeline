#!/bin/bash
#SBATCH --mail-user=akhaliq@iu.edu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --job-name=fastqc_analysis
#SBATCH --error=fastqc_analysis.error
#SBATCH --output=fastqc_analysis.out
#SBATCH --time=1-00:00:00
#SBATCH --mem=400G
#SBATCH --partition=general
#SBATCH --account=r00583

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${BASE_DIR}/fastqc_analysis.log"
}

# Set the base directory
BASE_DIR="/N/project/cytassist/masood_colon_300"

# Start logging
log_message "Starting FastQC analysis job on BAM files"

# Load necessary modules
module load miniconda
conda activate spatial

# Check if FastQC is available
if ! command -v fastqc &> /dev/null; then
    log_message "ERROR: FastQC not found. Please ensure it's installed in the 'spatial' conda environment."
    exit 1
fi

# Create output directory
OUTPUT_DIR="${BASE_DIR}/fastqc_output"
mkdir -p "$OUTPUT_DIR"

# Find all RNA folders
RNA_FOLDERS=$(find "$BASE_DIR" -type d -name "RS.v2-RNA-*")

# Check if any RNA folders were found
if [ -z "$RNA_FOLDERS" ]; then
    log_message "ERROR: No RNA folders found in ${BASE_DIR}"
    exit 1
fi

# Process each RNA folder
echo "$RNA_FOLDERS" | while read -r rna_folder; do
    sample_name=$(basename "$(dirname "$rna_folder")")
    log_message "Processing sample: ${sample_name}"
    
    # Create sample-specific output directory
    sample_output_dir="${OUTPUT_DIR}/${sample_name}"
    mkdir -p "$sample_output_dir"
    
    # Find the BAM file
    bam_file=$(find "$rna_folder" -name "*_T_sorted.bam" | head -n 1)
    
    if [ -z "$bam_file" ]; then
        log_message "WARNING: No BAM file found in ${rna_folder}"
        continue
    fi
    
    # Run FastQC on the BAM file
    fastqc -t $SLURM_CPUS_PER_TASK "$bam_file" -o "$sample_output_dir"
    
    log_message "Completed processing for sample: ${sample_name}"
done

log_message "FastQC analysis complete. Results are in $OUTPUT_DIR"

# Deactivate conda environment
conda deactivate

exit 0
