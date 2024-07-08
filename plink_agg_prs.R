library(data.table)

## Specify PRS file ID
prs_file <- "PGS_file_name_here"

## Read files for specified PRS
get_files <- list.files(path="/path/to/pgs_chr", pattern=glob2rx(paste0("plink_prs_", prs_file, "_chr*.profile")))

read_files <- lapply(get_files, function(i) fread(paste0("/path/to/pgs_chr/", i)))
read_files_dt <- rbindlist(read_files)

## Aggregate by sample ID
read_files_comb <- read_files_dt[, .(SCORESUM_AGG=sum(SCORESUM), CNT_SUM=sum(CNT), CNT2_SUM=sum(CNT2)), by=FID]

## Subset for EUR probands used in association analysis
get_ancs <- fread("/path/to/EUR/probands.txt", header=F)
read_files_eur <- read_files_comb[FID %in% get_ancs[, V1]]

## Scale PRS (Z-score)
read_files_eur[, SCORESUM_AGG_Z := scale(SCORESUM_AGG)]

## Write final file
fwrite(read_files_eur[, .(FID, SCORESUM_AGG, SCORESUM_AGG_Z, CNT_SUM, CNT2_SUM)], file=paste0("/path/to/prs_comb/", prs_file, "_full_eur.txt"), sep="\t")

