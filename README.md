# GA4K polygenic score paper code

Scripts are provided to calculate and aggregate polygenic scores (PGS) for a given set of individuals, perform QC, and run regression modeling with permutation testing for rare disease (HPO) case/control cohorts.

# Resource availability
* GA4K data is available via dbGAP using accession number phs002206.v5.p1 and AnVIL at https://anvilproject.org/data/studies/phs002206
* Polygenic scores are available from PGS Catalog at https://www.pgscatalog.org/

# Pipeline

Scripts are designed for parallel processing in a cluster environment. See `job_submit_slurm.sh` for an example job submission scripts using Slurm Workload Manager.

**1. Calculating and post-processing polygenic scores**

`plink_calc_prs.sh` uses a PGS file to calculate individual-level polygenic scores for each individual. Inputs: genotype BED files (one per chromosome); PGS variant weights (one file per polygenic score of interest). Requirements: genome build must be the same for both genotype BED and polygenic score files; PGS file must have three columns: variant ID (chr:pos:ref:alt), effect allele, effect weight.

`plink_agg_prs.r` takes PGS output files from `plink_calc_prs.sh`, sums PGS across chromosomes, applies genetic ancestry file, and transforms aggregated scores to Z-scores.

`prs_outliers.r` checks aggregated PGS files for individuals with extreme outlier PGS and records sample ID for removal.

`prs_pc_join.r` joins PGS files with covariates for downstream regression modeling.

**2. Associating PGS with rare disease phenotypes**

`prs_hpo_sig.r` performs logistic regression modelling for a given case/control cohort defined by user-input human phenotype ontology (HPO) ID using PGS and demographic covariates.

`prs_hpo_perm.r` performs permutation testing of HPO-PGS associations.

`calc_emp_p.sh` computes empirical P-value based on results of permutation tests from `prs_hpo_perm.r`.

`calc_emp_p.r` helper script for `calc_emp_p.sh` to calculate q-values/false discovery rate using the qvalue package in R. 

