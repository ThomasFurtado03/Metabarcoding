# Metabarcoding

**METHODS**

Raw shotgun metagenomic sequencing data were obtained from the European Nucleotide Archive (ENA) under study accession SRP126540, consisting of human gut microbiome samples form individuals with omnivore and vegan diets. Paried-end FASTQ files were downloaded directly using 'wget' form command line, A total of six samples (three omnivore, three vegan) were selected for analysis.

Quality control of raw sequencing reads was performed using FastQC (v0.11.9), which assesses per-base sequence quality, GC content, duplication levels, and adapter contamination (Andrews, 2010). All samples passed quality control metrics, no trimming or filtering was applied prior to the downstream process.

Taxonomic classification of sequencing reads was conducted using Kraken2 (v2.1.7.1), which is a k-mer based classification tool that assigns reads to a taxa based on exact matches to a reference database (Wood et al., 2019). A pre-built standard database (k2_standard_08_GB_20251015) was used. Kraken2 was run with a confidence threshold of 0.15 to reduce false-positive instances and paired-end reads were processed using 16 threads. The --memory-mapping option was not used due to executional issues and in the Narval (Compute Canada) computing environment.

Abundance estimation at the species level was refine using Bracken (v3.0.1), which re-estimates species abundances form Kraken2 outputs, using Bayesian models of k-mer distributions (Lu et al., 2017). Bracken was run with a read length parameter of 150 base pairs ( -r 150) and the taxonomic level set to species (-l S).

Kraken2 output reports were combined into a BIOM-format table using kraken-biom (v1.2.0), enabling integration with downstream statistical analysis tools. The BIOM table was imported into R using the phyloseq (v1.44.0) package for ecological and statistical analysis (McMurdie and Holmes, 2013).

All downstream analyses were performed in R. Relative abundance transformation and taxonomic aggregation were done using phyloseq. Alpha diversity metrics, including Shannon and Simpson indices, were calculated using the 'plot-richness' function. Beta diversity was assessed using Bray-Curtis dissimilarity and visualized using principal coordinates analysis (PCoA) using the 'ordinate' and 'plot_ordination' functions.

Statistical significance of the differences in microbial community composition between diet groups was evaluated using PERMANOVA from the 'vegan' (v2.6-4) package vis the 'adonis2' function (Oksanen et al., 2022).

Differential abundance analysis was conducted using ANCOMBC2, which accounts for compositional bias in microbiome data (Lin and Peddada, 2020). Taxa were tested at the genus level (Rank 6), with significance determined by using Holm-adjusted p-values ( q < 0.05).

All code for data collection, processing, analysis, and visualization is provided in this repository.

**RESULTS**

![Figure 1](Figures/Figure1.png)

**Figure 1.** Taxonomic composition at the phylum level.Relative abundance of microbial taxa at the phylum level (Rank2) across omnivore and vegan samples. Samples are grouped by diet, with each bar representing a single sample. Bacteroidota and Bacillota dominate across all samples, with minor contributions from other phyla.



The taxonomic composition of gut microbiome samples varied across both omnivore and vegan groups, with phylum-level abundance dominated by Bacteroidotaand Bacillotain all samples (Figure 1). Although both groups displayed similar dominant phyla, variation in the relative abundance was observed between individual samples. This was particularly prevalent in the vegan group, where one sample showed a notable higher proportion of Bacillota. Minor phyla such as Actinomycetotaand Verrucomicrobiota were present at low relative abundances across all samples.




![Figure 2](Figures/Figure2.png)

**Figure 2.** Alpha diversity of microbiome samples. Alpha diversity measures (Shannon and Simpson indices) for omnivore and vegan samples. Each point represents an individual sample, with boxplots indicating group distributions. Both metrics show overlapping distributions between groups, indicating similar within-sample diversity.




Alpha diversity analysis revealed variability within both dietary groups, but there was no clear separation between omnivore and vegan samples (Figure 2). Shannon diversity values broadly separated within each group, this indicates that there are differences in both richness and evenness among individual samples. Simpson diversity showed a similar pattern, with overlapping distributions between groups. Together, these results suggest that within-sample microbial diversity is comparable between omnivore and vegan individuals in this dataset.




![Figure 3](Figures/Figure3.png)

**Figure 3.** Beta diversity (PCoA of Bray–Curtis dissimilarity). Principal coordinates analysis of Bray–Curtis dissimilarity between samples. Points are colored by diet group. The first two axes explain 52.5% and 24.9% of the variation, respectively. Partial clustering by diet is observed, though overlap and outliers indicate substantial variability.



Beta diversity analysis using Bray-Curtis dissimilarity and principal coordinates analysis (PCoA) revealed partial clustering of samples by diet (Figure 3). The first principal coordinate explained 52.5% of the variation, with omnivore samples tending to cluster on one side of the axis, and the vegan samples clustering on the other. However, overlap between groups and outlier data points suggest substantial within-group variability. Statistical test using PERMANOVA showed that the diet explained 18% of the variation in the microbial composition (R^2^ = 0.18), but this effect was found not to be statistically significant (p = 0.5).




![Figure 4](Figures/Figure4.png)

**Figure 4.** Differential abundance analysis (ANCOMBC2). Log fold change in taxon abundance between vegan and omnivore samples (Vegan vs Omnivore). Points represent taxa at the genus level (Rank6), with error bars indicating standard errors. No taxa were significantly differentially abundant after multiple-testing correction (q < 0.05).


Differential abundance analysis using ANCOMBC2 did not identify any taxa as significantly different between omnivore and vegan samples after multiple testing correction ( q < 0.05) (Figure 4). Although several taxa had positive or negative log fold changes, which would indicate potential differences in abundance between groups, none met the threshold for statistical significance. Some taxa displayed confidence intervals that did not overlap zero, however, these differences were not robust after adjustment for multiple comparisons. This alludes to the fact that there's potentially high variability and limited statistical power.
