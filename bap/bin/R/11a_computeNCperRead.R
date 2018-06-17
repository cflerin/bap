options(warn=-1)

suppressMessages(suppressWarnings(library(Rsamtools)))
suppressMessages(suppressWarnings(library(GenomicAlignments)))
suppressMessages(suppressWarnings(library(GenomicRanges)))
suppressMessages(suppressWarnings(library(data.table)))
suppressMessages(suppressWarnings(library(dplyr)))
suppressMessages(suppressWarnings(library(tools)))

"%ni%" <- Negate("%in%")

# This script takes a given bam file

args <- commandArgs(trailingOnly = TRUE)

if(file_path_sans_ext(basename(args[1])) == "R"){
  i <- 2
} else { # Rscript
  i <- 0
}
bamfile <- args[i+1]
barcodeTag <- args[i+2]

if(FALSE){
  base <- "/Volumes/dat/Research/BuenrostroResearch/lareau_dev/bap/tests"
  bamfile <- paste0(base, "/", "bap_out/temp/filt_split/test.small.chr21.bam")
  barcodeTag <- "CB"
}

tsvOut <- gsub(".bam", "_ncRead.tsv", bamfile)

# Import Reads and make a data.frame
GA <- readGAlignments(bamfile, param = ScanBamParam(tag = c(barcodeTag)), use.names = TRUE)
df <- data.frame(read = names(GA), barcode = mcols(GA)[,barcodeTag], chr = as.character(seqnames(GA)), bp = start(GA), stringsAsFactors = FALSE)
rm(GA)

# Do read pairing
df %>% group_by(read) %>% summarize(barcode = min(barcode), chr = min(chr), bp1 = min(bp), bp2 = max(bp)) %>%
  group_by(chr, bp1, bp2) %>% mutate(count = n()) -> odf

write.table(odf[,c("read", "count")], file = tsvOut, sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)

                                    