#!/bin/bash
#SBATCH --mail-user=akhaliq@iu.edu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=FAIL,BEGIN,END
#SBATCH --job-name=bulk_rnaseq_pipeline
#SBATCH --error=bulk_rnaseq_pipeline.error
#SBATCH --output=bulk_rnaseq_pipeline.out
#SBATCH --time=72:00:00
#SBATCH --mem=400G
#SBATCH --partition=general
#SBATCH --account=r00583

# Load necessary modules
module load miniconda

# Activate conda environment
source activate spatial

# Set up error handling
set -euo pipefail

# Set the base directory
BASE_DIR="/N/project/cytassist/masood_colon_300"
OUTPUT_DIR="${BASE_DIR}/salmon_output"
mkdir -p $OUTPUT_DIR

# Check disk space before starting
REQUIRED_SPACE=10000000 # in kilobytes (10GB)
AVAILABLE_SPACE=$(df "$BASE_DIR" | tail -1 | awk '{print $4}')

if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
    echo "Error: Not enough disk space available in $BASE_DIR. Required: ${REQUIRED_SPACE}KB, Available: ${AVAILABLE_SPACE}KB."
    exit 1
fi

# Download and extract reference files if they don't exist
cd $BASE_DIR

if [ ! -f "GRCh37.primary_assembly.genome.fa" ]; then
    echo "Downloading and extracting reference genome..."
    wget -c ftp://ftp.ensembl.org/pub/grch37/current/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz
    gunzip -f Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz
    mv Homo_sapiens.GRCh37.dna.primary_assembly.fa GRCh37.primary_assembly.genome.fa
else
    echo "Reference genome file already exists. Skipping download."
fi

if [ ! -f "gencode.v19.annotation.gtf" ]; then
    echo "Downloading and extracting gene annotation..."
    wget -c ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz
    gunzip -f gencode.v19.annotation.gtf.gz
else
    echo "Gene annotation file already exists. Skipping download."
fi

# Remove 'chr' prefix from GENCODE GTF file
echo "Removing 'chr' prefix from GENCODE GTF file..."
sed 's/^chr//' gencode.v19.annotation.gtf > gencode.v19.annotation.nochr.gtf

# Ensure consistency in chromosome naming (e.g., replace 'M' with 'MT')
echo "Ensuring chromosome naming consistency..."
sed -i 's/^M/MT/' gencode.v19.annotation.nochr.gtf

# Generate tx2gene file
if [ ! -f "tx2gene_gencodev19.txt" ]; then
    echo "Generating tx2gene file..."
    awk -F "	" 'BEGIN{OFS="	"} $3=="transcript" {match($9, /transcript_id "([^"]+)"/, tid); match($9, /gene_id "([^"]+)"/, gid); print tid[1], gid[1]}' gencode.v19.annotation.nochr.gtf > tx2gene_gencodev19.txt
else
    echo "tx2gene file already exists. Skipping generation."
fi

# Run Salmon quantification on all samples
echo "Running Salmon quantification..."

for dir in ${BASE_DIR}/*/RS.v2-RNA-*/; do
    if [ -d "$dir" ]; then
        sample=$(basename $(dirname "$dir"))
        bam_file=$(find "$dir" -name "*_T_sorted.bam" | head -n 1)
        
        if [ -f "$bam_file" ]; then
            echo "Processing $sample..."
            salmon quant                    -a "$bam_file"                    --targets GRCh37.primary_assembly.genome.fa                    -l A                    -o ${OUTPUT_DIR}/${sample}_quant                    --gcBias --seqBias                    -p $SLURM_CPUS_PER_TASK || { echo "Error in Salmon quantification for $sample."; exit 1; }
        else
            echo "No BAM file found for $sample. Skipping..."
        fi
    else
        echo "Directory $dir does not exist. Skipping..."
    fi
done

# Create sample sheet
echo "Creating sample sheet..."
> ${BASE_DIR}/samples.txt
for dir in ${OUTPUT_DIR}/*_quant; do
    sample=$(basename "$dir" | sed 's/_quant//')
    echo "${sample} $dir/quant.sf" >> ${BASE_DIR}/samples.txt
done

# Create R script for generating count matrix
echo "Creating R script..."
cat << EOF > ${BASE_DIR}/generate_count_matrix.R
library(tximport)
library(readr)
library(dplyr)

# Read the sample sheet
samples <- read_tsv("${BASE_DIR}/samples.txt", col_names = c("sample", "file"))

# Read in transcript to gene mapping
tx2gene <- read_tsv("${BASE_DIR}/tx2gene_gencodev19.txt", col_names = c("TXNAME", "GENEID"))

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

# Run R script
echo "Running R script to generate count matrix..."
Rscript ${BASE_DIR}/generate_count_matrix.R || { echo "Error running R script."; exit 1; }

echo "Pipeline completed successfully. Output files are in ${BASE_DIR}."
