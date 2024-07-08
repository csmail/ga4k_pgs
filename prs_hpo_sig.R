
## <----------------- LIBRARIES

library(data.table)
library(fmsb)

## <--------------- MAIN

## Specify HPO ID for case cohort
h <- "hpo_id_here"

## Get all HPO terms
get_hpo_terms <- fread("/path/to/hpos.tsv")
colnames(get_hpo_terms) <- c("sample_id", "hpo_term")

## Read GA4K diagnostic status
ga4k_meta <- fread("/path/to/dx.csv")
ga4k_meta[, CAT := tolower(CAT)]

## Get PGS file names
get_prs_files <- fread("/path/to/prs_ids.txt", header=F)[, V1]

## Process PGS for each HPO term

collect <- list()
collect_sig <- list()

## Get samples with HPO match
hpo_i <- get_hpo_terms[hpo_term==h]

for (get_prs_i in get_prs_files) {

        message(get_prs_i)

        ## Get PGS file (EUR only)
        prs_i <- fread(paste0("/path/to/pgs_comb_join/", get_prs_i, "_filt.pc.sex.txt"))

        ## Add case/control
        prs_i[, cohort := ifelse(FID %in% hpo_i[, sample_id], 1, 0)]

        ## Add diagnosis status
        prs_i[, dx := ga4k_meta[match(FID, sample), CAT]]

        ## Add metadata
        prs_i[, prs_id := get_prs_i]
        prs_i[, hpo_id := h]

        ## Write cases to list
        collect[[length(collect)+1]] <- prs_i[cohort==1]

        ## Logistic regression
        get_mod <- glm(cohort~sex+PC1+PC2+PC3+PC4+PC5+SCORESUM_AGG_Z, data=prs_i)
        get_mod_no.prs <- glm(cohort~sex+PC1+PC2+PC3+PC4+PC5, data=prs_i)

        r2_mod <- NagelkerkeR2(get_mod)$R2
        r2_mod_no.prs <- NagelkerkeR2(get_mod_no.prs)$R2

        get_mod_dt <- data.table(summary(get_mod)$coefficients)

        collect_sig[[length(collect_sig)+1]] <- data.table(prs_id=get_prs_i,
                hpo_id=h,
                case_n=length(unique(prs_i[cohort==1, FID])),
                coef=as.numeric(get_mod_dt[8,1]),
                std_err=as.numeric(get_mod_dt[8,2]),
                z_val=as.numeric(get_mod_dt[8,3]),
                p_val=as.numeric(get_mod_dt[8,4]),
                r_sq=r2_mod,
                r_sq_inc=r2_mod-r2_mod_no.prs)
}

collect_dt <- rbindlist(collect)
collect_sig_dt <- rbindlist(collect_sig)

## Write files
out_dir <- "/path/to/hpo_prs_sig/"
h_sub <- gsub(":","-",h)

fwrite(collect_dt, file=paste0(out_dir, "collect_dt_", h_sub, ".txt"), sep="\t")
fwrite(collect_sig_dt, file=paste0(out_dir, "collect_sig_dt_", h_sub, ".txt"), sep="\t")

