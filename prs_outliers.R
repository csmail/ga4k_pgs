
## Identify PRS outliers

library(data.table)

in_dir <- "/path/to/prs_comb"
get_prs_n_files <- list.files(path=in_dir, pattern="*_eur.txt")

prs_ids <- gsub("_full_eur.txt", "", get_prs_n_files)

## Identify sample IDs passing global PGS outlier threshold
get_out <- lapply(prs_ids, function(prs_i) {

	## Get PGS
	get_prs_i <- fread(paste0(in_dir, "/", prs_i, "_full_eur.txt"))

	## Add metadata
	get_prs_i[, prs_id := prs_i]

	## Return outlier
	return(get_prs_i[abs(SCORESUM_AGG_Z)>=6])

})

get_out_dt <- rbindlist(get_out)

## Write list
fwrite(unique(get_out_dt[, .(FID)]), file="fid_abs.z6.txt", col.names=F)