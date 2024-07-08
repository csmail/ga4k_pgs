## Join PGS with covariates

## Load libraries
library(data.table)

## <--------------- MAIN

## Read GA4K PCs
get_pcs <- fread("/path/to/pcs.txt")

## Read GA4K sex
get_sex <- fread("/path/to/proband/sex.txt")

## Get PGS file names
get_prs_files <- fread("/path/to/prs_id.txt", header=F)[, V1]

## Get list of samples identified for global outlier removal
get_ads <- fread("/path/to/fid_abs.z6.txt", header=F)[, V1]

## Write joined file for each PGS

for (get_prs_i in get_prs_files) {

        message(get_prs_i)

        ## Get PGS file (EUR only)
        prs_i <- fread(paste0("/path/to/prs_comb/", get_prs_i, "_full_eur.txt"))

        ## Remove samples identified for global outlier removal
        prs_i_ads <- prs_i[!FID %in% get_ads]

        ## Filter for probands only (remove siblings if present)
        prs_i_ads[, c("FID1", "FID2") := tstrsplit(FID, "-", fixed=TRUE)]
        prs_i_filt <- prs_i_ads[is.na(FID2) | FID2=="01"]

        ## Merge PGS with covariates
        prs_pc <- merge(prs_i_filt[, .(FID, SCORESUM_AGG_Z)], get_pcs[, .(FID=sample_id, PC1=pc1, PC2=pc2, PC3=pc3, PC4=pc4, PC5=pc5)], by="FID")

        ## Add sex
        prs_pc[, sex := get_sex[match(prs_pc[, FID], get_sex[, sample_id]), sex]] 

        ## Remove NA sex
        prs_pc_na <- prs_pc[!is.na(sex)]

        ## Write file
        fwrite(prs_pc_na, file=paste0("/path/to/pgs_comb_join/", get_prs_i, "_filt.pc.sex.txt"))
}





