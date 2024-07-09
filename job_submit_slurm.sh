## 1. Write a slurm script (filename: plink_vcf_to_bed.sh) to convert VCFs to filtered BEDs

#!/bin/bash

# Set job time
#SBATCH --time=0-04:00:00

# Set a name for the job, visible in `squeue`
#SBATCH --job-name="plink_vcf_to_bed"

# One node
#SBATCH --nodes=1

# One task
#SBATCH --ntasks=1

# One CPU/core per task
#SBATCH --cpus-per-task=1

# Redirect output
#SBATCH --output=/path/to/err.log/vcf_to_bed.prs.out-%j.txt
#SBATCH --error=/path/to/err.log/vcf_to_bed.prs.err-%j.txt

# RAM
#SBATCH --mem=64G

plink_dir="/path/to/plink" # plink directory
in_dir="/path/to/vcfs"
out_dir="/path/to/out" # output directory

${plink_dir}/./plink2 --vcf ${in_dir}/chr${1}.dose.vcf.gz \
 --make-bed \
 --double-id \
 --vcf-idspace-to "_" \
 --exclude-if-info "R2<0.8" \
 --out ${out_dir}/chr${1}.topmed.hg38
 

## 2. Submit job for each chromosome VCF

for chr in `seq 1 22`; do
sbatch plink_vcf_to_bed.sh ${chr}
done
