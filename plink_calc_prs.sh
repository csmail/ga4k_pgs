plink_dir="/path/to/plink/v1.9"
geno_dir="/path/to/genotype/beds"
out_dir="/out_dir" # output directory

for chr in `seq 1 22`; do
${plink_dir}/./plink --bfile ${geno_dir}/chr${chr}.topmed.hg38 \
 --score /path/to/polygenic/score/weights/${file_in} \
 sum \
 --out ${out_dir}/plink_prs_${file_out}_chr${chr}
done