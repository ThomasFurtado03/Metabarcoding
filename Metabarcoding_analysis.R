

#Packages----

BiocManager::install(c("phyloseq", "biomformat", "ANCOMBC"))
BiocManager::install("microbiome")

library(phyloseq)
library(biomformat)
library(ANCOMBC)
library(vegan)
library(ggplot2)
library(microbiome)

#Load BIOM----
#Read BIOM file
biom_data <- read_biom("biom/kraken.biom")
physeq <- import_biom(biom_data)

#Check sample names
sample_names(physeq)

#Build metadata table
metadata_df <- data.frame(
  Class = c("Omnivore", "Omnivore", "Omnivore", "Vegan", "Vegan", "Vegan")
)

rownames(metadata_df) <- c(
  "SRR8146935.bracken",
  "SRR8146936.bracken",
  "SRR8146938.bracken",
  "SRR8146944.bracken",
  "SRR8146951.bracken",
  "SRR8146952.bracken"
)
  
#Add metadata to phyloseq object
sample_data(physeq) <- metadata_df


#Quick checks

sample_names(physeq)
sample_data(physeq)
ntaxa(physeq)
rank_names(physeq)
nsamples(physeq)


#Taxonomic abundance plot----

#Convert to relative abundance
physeq_rel <- transform_sample_counts(physeq, function(x) x / sum(x))

#Phylum level (Rank 2)
physeq_phy <- tax_glom(physeq_rel, taxrank = "Rank2")

#Convert to long format for plotting
df <- psmelt(physeq_phy)

#Make stacked bar plot
ggplot(df, aes(x = Sample, y = Abundance, fill = Rank2)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(y = "Relative Abundance", x = "Sample") +
  facet_wrap(~Class, scales = "free_x") +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8)
    
  )


#Alpha diversity----

#Shannon for richness/evenness, and Simpson for dominance/evenness
plot_richness(physeq, x = "Class", measures = c("Shannon", "Simpson")) +
  geom_boxplot()



#Beta diversity----

#Attach "Class" so plot may be coloured by Class
sample_data(ps)$Class <- factor(sample_data(ps)$Class)

#PCoA with Bray-Curtis
ps <- physeq
ord.pcoa.bray <- ordinate(ps, method = "PCoA", distance = "bray")

#Collect plotting data frame from phyloseq
ord_df <- plot_ordination(ps, ord.pcoa.bray, type = "samples", justDF = TRUE)

#Manually add class form sample metadata
ord_df$Class <- sample_data(ps)$Class[match(rownames(ord_df), sample_names(ps))]


#PCA axis labels are now messed up..
#Collect % variance and add to axis labels
var_explained <- ord.pcoa.bray$values$Relative_eig * 100
x_lab <- paste0("PCoA Axis 1 (", round(var_explained[1], 1), "%)")
y_lab <- paste0("PCoA Axis 2 (", round(var_explained[2], 1), "%)")

                
#Finally plot
ggplot(ord_df, aes(x = Axis.1, y = Axis.2, color = Class)) +
  geom_point(size = 4) +
  labs(
    title = "PCoA of Bray-Curtis Dissimilarity",
    subtitle = "Beta diversity of Omnivore and Vegan samples",
    x = x_lab,
    y = y_lab,
    color = "Class"
  )


#PERMANOVA----

#Lets see if that separation is statisitcally significant

metadata <- as(sample_data(ps), "data.frame")

adonis2(phyloseq::distance(physeq, method = "bray") ~ Class,
        data = metadata)

#R^2 = 0.18. Diet (Class) explains roughly 18% of the variation in the composition of the microbiome.
#p = 0.5, therefore not statistically significiant, therefore we cannot conclude that diet causes a difference.

#Note we do have low statisticaly power here, only 3 samples vs 3 samples.


#Differential Abundance----

ancombc.out <- ancombc2(
  data = physeq,
  tax_level = "Rank6",
  fix_formula = "Class",
  rand_formula = NULL,
  p_adj_method = "holm",
  pseudo_sens = TRUE,
  prv_cut = 0,
  lib_cut = 1000,
  s0_perc = 0.05,
  group = "Class",
  struc_zero = TRUE,
  neg_lb = TRUE
)


ancombc.out$res

names(ancombc.out$res)
colnames(ancombc.out$res$res)

#Extract significant taxa


ancombc.sig <- subset(ancombc.out$res, q_ClassVegan < 0.05)
ancombc.sig
#NO significant taxa at this specific threshold!


#Lets plot the results

#Clean up labels, remove "g_" prefix
ancombc.out$res$taxon <- gsub("g__", "", ancombc.out$res$taxon)

#Plot
ggplot(ancombc.out$res, aes(x = lfc_ClassVegan, y = reorder(taxon, lfc_ClassVegan))) +
  geom_point(aes(color = q_ClassVegan < 0.05), size = 3) +
  geom_errorbar(aes(xmin = lfc_ClassVegan - se_ClassVegan,
                    xmax = lfc_ClassVegan + se_ClassVegan)) +
  geom_vline(xintercept = 0) +
  labs(x = "Log Fold Change (Vegan vs Omnivore)",
       y = "Taxon"
     ) +
  theme(
    axis.text.y = element_text(size = 6),
    plot.margin = margin(1,1,1,1)
  )

#Overall there are apparent trends, but there is also high uncertainty
#Many taxa are spread across positive and negative log-fold changes

#There is about an equal mix of taxa appearing higher in Vegan (positive, right side) and in Omnivore (negative, left side).

#Although there are several taxa that exhibit non-zero log fold changes, none remained statistically significant after multiple testing correction (q < 0.05).

