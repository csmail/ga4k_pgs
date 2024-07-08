## <----------------- LOAD LIBRARIES

library(qvalue)

## <----------------- FUNCTIONS

## 

## <--------------- MAIN

args <- commandArgs(trailingOnly=TRUE)
obs_p <- abs(as.numeric(args[1]))
null_p <- matrix(abs(as.numeric(args[-1])), ncol=1)

as.numeric(unlist(empPvals(stat=obs_p, stat0=null_p, pool=FALSE)))
