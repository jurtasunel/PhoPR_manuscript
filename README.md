## PhoPR_manuscript
Code and data used for the PhoPR manuscript comparing the expression of M. tb and M. bovis PhoPR orthologues
------------------------------------------------------------------------------------------------------------
1 - `DataProcessingRNAseq.py` is the file to process the raw sequencing files, available at the NCBI Sequence Read Archive (SRA) under the BioProject ID PRJNA1129457.

2 - `DEApipeline.Rmd` runs the Differential Expression Analysi. Count matrix and metadata files are available as supplementary data of the manuscript.

3 - `GeneCategories_piechart.R` uses the `mbovis_categories.csv` and the common upregulation files produced by `DEApipeline.Rmd`
