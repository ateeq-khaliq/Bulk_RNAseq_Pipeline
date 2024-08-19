#!/bin/bash
#SBATCH --mail-user=akhaliq@iu.edu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --job-name=salmon_quantification
#SBATCH --error=salmon_quantification.error
#SBATCH --output=salmon_quantification.out
#SBATCH --time=24:00:00
#SBATCH --mem=32G
#SBATCH --partition=general
#SBATCH --account=r00583

# RNA-seq quantification pipeline for masood_colon_300 project

# Set up error handling
set -e

# Load necessary modules (adjust as needed for your system)
module load salmon
module load r

# Set the base directory
BASE_DIR="/N/project/cytassist/masood_colon_300"
OUTPUT_DIR="${BASE_DIR}/salmon_output"
mkdir -p $OUTPUT_DIR

# Step 1: Generate transcriptome file (if not already present)
if [ ! -f "${BASE_DIR}/GRCh38_no_alt_analysis_set_gencode.v36.transcripts.fa" ]; then
    echo "Generating transcriptome file..."
    gffread -w ${BASE_DIR}/GRCh38_no_alt_analysis_set_gencode.v36.transcripts.fa \
            -g ${BASE_DIR}/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna \
            ${BASE_DIR}/gencode.v36.annotation.gtf
fi

# Step 2: Create Salmon index (if not already present)
if [ ! -d "${BASE_DIR}/salmon_index" ]; then
    echo "Creating Salmon index..."
    salmon index -t ${BASE_DIR}/GRCh38_no_alt_analysis_set_gencode.v36.transcripts.fa \
                 -i ${BASE_DIR}/salmon_index
fi

# Step 3: Run Salmon quantification on all samples
echo "Running Salmon quantification..."

# Find all directories containing BAM files
for dir in ${BASE_DIR}/*/RS.v2-RNA-*/; do
    if [ -d "$dir" ]; then
        sample=$(basename $(dirname "$dir"))
        bam_file=$(find "$dir" -name "*_T_sorted.bam" | head -n 1)
        
        if [ -f "$bam_file" ]; then
            echo "Processing $sample..."
            salmon quant -i ${BASE_DIR}/salmon_index \
                         -l A \
                         -a "$bam_file" \
                         -o ${OUTPUT_DIR}/${sample}_quant \
                         --gcBias --seqBias \
                         -p $SLURM_CPUS_PER_TASK
        fi
    fi
done

# Step 4: Create sample sheet
echo "Creating sample sheet..."
> ${BASE_DIR}/samples.txt
for dir in ${OUTPUT_DIR}/*_quant; do
    sample=$(basename "$dir" | sed 's/_quant//')
    echo "${sample} $dir/quant.sf" >> ${BASE_DIR}/samples.txt
done

# Step 5: Create R script for generating count matrix
echo "Creating R script..."
cat << EOF > ${BASE_DIR}/generate_count_matrix.R
library(tximport)
library(readr)
library(dplyr)

# Read the sample sheet
samples <- read_tsv("${BASE_DIR}/samples.txt", col_names = c("sample", "file"))

# Read in transcript to gene mapping
tx2gene <- read_tsv("${BASE_DIR}/tx2gene_gencodev36-unique.txt", col_names = c("TXNAME", "GENEID"))

# Import quantifications
txi <- tximport(samples\$file, type = "salmon", tx2gene = tx2gene)

# Extract counts
counts <- txi\$counts

# Write counts to file
write.csv(counts, file = "${BASE_DIR}/gene_count_matrix.csv")

# Write normalized counts (TPM)
tpm <- txi\$abundance
write.csv(tpm, file = "${BASE_DIR}/gene_tpm_matrix.csv")
EOF

# Step 6: Run R script
echo "Running R script to generate count matrix..."
Rscript ${BASE_DIR}/generate_count_matrix.R

echo "Pipeline completed. Output files are in ${BASE_DIR}."