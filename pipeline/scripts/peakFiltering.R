#!/usr/bin/Rscript

.libPaths(new="/hpc/local/CentOS7/dbg_mz/R_libs/3.2.2")

run <- function(indir, outdir, scanmode, thresh, resol, version, scripts) {
  # scripts="./scripts"
  # outdir="./results"
  # version=2.0
  # indir="./data"
  # scanmode="positive"
  
  # filtering moved to grouping! Only in 2.0
  
  startcol=7
  
  tmp=NULL
  rdata = list.files(paste(outdir, "peak_grouping", sep="/"), full.names=TRUE, pattern=paste(scanmode, "*", sep="_"))
  
  for (i in 1:length(rdata)){
    load(rdata[i])
    tmp=rbind(tmp, outpgrlist)
    rm(outpgrlist)
  }
  
  outpgrlist=tmp[order(as.numeric(tmp[,"mzmed.pgrp"])),]
  
  # filtering moved to grouping! Only in 2.0
  
  source(paste(scripts, "AddOnFunctions/sourceDir.R", sep="/"))
  sourceDir(paste(scripts, "AddOnFunctions", sep="/"))
  
  outlist.single = remove.dupl(outpgrlist) # 4738 => 4735
  save(outlist.single, file=paste(outdir, paste("filtered_", scanmode, ".RData", sep=""), sep="/"))
  
  dir.create(paste(outdir, "samplePeaks", sep="/"))
  
  for (i in startcol:ncol(outlist.single)) {
    samplePeaks=outlist.single[,i]
    names(samplePeaks)=outlist.single[,"mzmed.pgrp"]
    save(samplePeaks, file=paste(outdir,"/samplePeaks/", colnames(outlist.single)[i],"_", scanmode, ".RData", sep=""))
  }
}

message("\nStart peakFiltering.R")
cat("==> reading arguments:\n", sep = "")

cmd_args = commandArgs(trailingOnly = TRUE)

for (arg in cmd_args) cat("  ", arg, "\n", sep="")

run(cmd_args[1], cmd_args[2], cmd_args[3], as.numeric(cmd_args[4]), as.numeric(cmd_args[5]), as.numeric(cmd_args[6]), cmd_args[7])

message("Ready peakFIltering.R")
