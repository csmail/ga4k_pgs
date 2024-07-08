## <----------------- LOAD LIBRARIES

library(data.table)

## <--------------- MAIN

## Store command line argument to variable
args <- commandArgs(trailingOnly=TRUE)
iter <- as.numeric(args[1]) # current iteration

message(iter)

## Get HPO terms with proband N from hpo_sig
get_hpo_n <- fread("/path/to/hpo_prs_int_count.txt")

## Get PRS file names
get_prs_files <- fread("/path/to/prs_ids.txt", header=F)[, V1]

## Randomize case/control

collect_sig <- list()

for (get_prs_i in get_prs_files) {

        message(get_prs_i)

        ## Get filtered PRS joined with PCs and sex
        prs_pc_na <- fread(paste0("/path/to/pgs_comb_join/", gsub("_full_eur.txt", "", get_prs_i), "_filt.pc.sex.txt"))

        ## Get nrow
        prs_pc_na_row <- nrow(prs_pc_na)

        ## Loop for each HPO
        collect_sig_i <- apply(get_hpo_n[case_n>=5], 1, function(hpo_n_i) {

                ## Get HPO N 
                get_hpo_n <- as.numeric(hpo_n_i[[2]])

                ## Randomize case/control
                prs_pc_na[, cohort := sample(c(rep(1, get_hpo_n), rep(0, prs_pc_na_row-get_hpo_n)))]

                ## Regression
                get_mod <- summary(glm(cohort~sex+PC1+PC2+PC3+PC4+PC5+SCORESUM_AGG_Z, data=prs_pc_na))

                ## Write
                tmp_dt <- data.table(prs_id=get_prs_i,
                        hpo_id=hpo_n_i[[1]],
                        z_stat=get_mod$coefficients[8,3],
                        p_val=get_mod$coefficients[8,4])

                return(tmp_dt)

    })

    collect_sig[[length(collect_sig)+1]] <- rbindlist(collect_sig_i)
}

collect_sig_dt <- rbindlist(collect_sig)

out_dir <- "/path/to/hpo_perm/"
fwrite(collect_sig_dt, file=paste0(out_dir, "collect_sig_perm_dt_", iter, ".txt"), sep="\t")
