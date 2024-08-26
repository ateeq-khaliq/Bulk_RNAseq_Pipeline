#!/bin/bash
#SBATCH --mail-user=akhaliq@iu.edu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --job-name=bulk_rnaseq_pipeline
#SBATCH --error=bulk_rnaseq_pipeline.error
#SBATCH --output=bulk_rnaseq_pipeline.out
#SBATCH --time=48:00:00
#SBATCH --mem=500G
#SBATCH --partition=gpu
#SBATCH --account=r00583

# Load necessary modules
module load miniconda

# Activate conda environment
source activate spatial

# Set up error handling
set -euo pipefail

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a BAM file is paired-end
is_paired_end() {
    local bam_file=$1
    local paired_reads=$(samtools view -f 1 -c "$bam_file")
    local total_reads=$(samtools view -c "$bam_file")
    
    if [ "$paired_reads" -eq "$total_reads" ]; then
        return 0  # true, it's paired-end
    else
        return 1  # false, it's not paired-end (either single-end or mixed)
    fi
}

# Set the base directory
BASE_DIR="/N/project/cytassist/masood_colon_300"
OUTPUT_DIR="${BASE_DIR}/featurecounts_output"
mkdir -p $OUTPUT_DIR

# Check if necessary tools are installed in the conda environment
for tool in featureCounts samtools; do
    if ! command_exists $tool; then
        echo "$tool not found. Please install it in your 'spatial' conda environment."
        echo "You can do this by running: conda install -c bioconda $tool"
        exit 1
    fi
done

# Verify installations
featureCounts -v
samtools --version

# Check if the annotation file exists, if not, download it
if [ ! -f "${BASE_DIR}/gencode.v19.annotation.gtf" ]; then
    echo "Downloading gene annotation..."
    wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz
    gunzip -f gencode.v19.annotation.gtf.gz
else
    echo "Gene annotation file already exists. Skipping download."
fi

# Create a list of BAM files
echo "Locating BAM files..."
find ${BASE_DIR} -path "*/RS.v2-RNA-*/*_T_sorted.bam" > ${BASE_DIR}/bam_files.txt

# Check if any BAM files were found
if [ ! -s ${BASE_DIR}/bam_files.txt ]; then
    echo "Error: No BAM files found. Please check the directory structure and file names."
    exit 1
fi

echo "Found $(wc -l < ${BASE_DIR}/bam_files.txt) BAM files."

# Check the first BAM file to determine if it's paired-end
first_bam=$(head -n 1 ${BASE_DIR}/bam_files.txt)
if is_paired_end "$first_bam"; then
    paired_option="-p"
    echo "Detected paired-end data. Using -p option in featureCounts."
else
    paired_option=""
    echo "Detected single-end or mixed data. Not using -p option in featureCounts."
fi

# Run featureCounts
echo "Running featureCounts..."
featureCounts \
    -a ${BASE_DIR}/gencode.v19.annotation.gtf \
    -o ${OUTPUT_DIR}/gene_counts.txt \
    -T $SLURM_CPUS_PER_TASK \
    $paired_option \
    -t exon \
    -g gene_id \
    $(cat ${BASE_DIR}/bam_files.txt)

echo "featureCounts completed. Output is in ${OUTPUT_DIR}/gene_counts.txt"

# Create an R script to process the output into a more convenient format
cat << EOF > ${BASE_DIR}/process_counts.R
library(data.table)

# Read the featureCounts output
counts <- fread("${OUTPUT_DIR}/gene_counts.txt", skip = 1)

# Keep only gene ID and count columns
counts <- counts[, c(1, 7:ncol(counts)), with = FALSE]

# Set gene ID as row names
setkey(counts, Geneid)
counts_matrix <- as.matrix(counts[, -1])
rownames(counts_matrix) <- counts\$Geneid

# Write out the processed matrix
write.csv(counts_matrix, "${OUTPUT_DIR}/processed_gene_counts.csv")
EOF

# Run the R script
Rscript ${BASE_DIR}/process_counts.R

echo "Pipeline completed successfully. Processed output file is in ${OUTPUT_DIR}/processed_gene_counts.csv"