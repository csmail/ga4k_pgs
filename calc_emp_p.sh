module load R

echo ${1}

## Split by HPO ID in to separate files

echo "Splitting files by HPO ID..."

hpo_i_out=`echo ${1} | awk '{ gsub(":", "-") ; print $0 }'`
awk -v pat=${1} '$2==pat {print $0}' /path/to/hpo_perm/* > /path/to/hpo_perm_split/collect_sig_${hpo_i_out}.txt

## Compute empirical pvalue

echo "Calculating empirical P-value..."

while read pgs_i; do

        echo ${pgs_i}

        mapfile -t < <( awk -v pat=${pgs_i} '$1==pat {print $3}' /path/to/hpo_perm_split/collect_sig_${hpo_i_out}.txt )

        ## Get observed Z-statistic
        out_dir="/path/to/out/dir"
        OBS_P=`awk -v pat_1=${pgs_i} -v pat_2=${1} '$1==pat_1 && $2==pat_2 {print $5}' ${out_dir}/hpo_prs_obs.stat.txt`

        ## Compute empirical P-value
        script_dir="/path/to/script/dir"

        get_emp_p=`Rscript ${script_dir}/calc_emp_p.R ${OBS_P} "${MAPFILE[@]}"`
        get_emp_p_strp=`echo ${get_emp_p} | awk '{ gsub(/\[1\] /, "") ; print $0 }'`

        ## Write to file
        printf "${pgs_i}\t${1}\t${get_emp_p_strp}\n" >> ${out_dir}/emp_p/emp_p_${hpo_i_out}.txt

done < /path/to/prs_ids.txt

echo "Finished."

