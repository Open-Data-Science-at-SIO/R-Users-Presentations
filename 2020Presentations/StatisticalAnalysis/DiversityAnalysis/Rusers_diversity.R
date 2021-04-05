################################################################################
################ Diversity #####################################################
################################################################################
library(vegan)

# Load Sample data below (data is species counts (columns) per site (rows))
data(BCI)

# calculate species richness per site
test_species_richness <-specnumber(BCI)
plot(test_species_richness, xlab="Site", ylab="Species Richness", 
     col=factor(BCI_effective))

# Rarefaction Curve
# Number of INDIVIDULS per site
raremax <- min(rowSums(BCI))

# rarefy, w/ raremax as input (?)
Srare <- rarefy(BCI, raremax)

#Plot rarefaction results
rarecurve(BCI, step = 20, 
          sample = raremax, 
          col = "blue", 
          cex = 0.6,
          main = "rarecurve()")
# Plot a subset of that data
rarecurve(BCI[1:5,], step = 20, sample = raremax, col = "blue", cex =      0.6,
          main = "rarecurve() on subset of data")

# Species accumulation curves
test_BCI_accum <-specaccum(BCI)
plot(test_BCI_accum, xlab = "# of samples", ylab = "# of species")
# Find the expected sp rich for site 1
test_BCI_accum[[4]][1]
# Find the sd for site 1
test_BCI_accum[[5]][1]

### Calculate Shannon Index
BCI_shannon <-diversity(BCI, index="shannon") 
# can also omit the index since Shannon is the default
plot(BCI_shannon, xlab = "Sites", ylab = "Shannon Index",
     col=factor(BCI_shannon))

### Calculate Simpson Index
BCI_simpson <-diversity(BCI, index="simpson") 
plot(BCI_simpson, xlab = "Sites", ylab = "Simpson's Index 1 - D",
     col=factor(BCI_simpson))
# 1-D so the closer to zero, the less diverse
BCI_simpson_2 <-diversity(BCI, index="invsimpson")
# This returns 1/D (also closer to zero, less diverse)

### Calculate Effective Species number 
# the exponential of Shannon Index (Hill number q=1)
BCI_effective_1 <-exp(BCI_shannon)
plot(BCI_effective_1, xlab="Site", ylab="Effective Species Number (q=1)", 
     col=factor(BCI_effective_1))

###### Fisher's log-series 
k <- sample(nrow(BCI), 1)
fish <- fisherfit(fisher_data[k,])
fish

##### Species Rank Curves
rad <- radfit(BCI[k,])
rad

##### Beta Diversity
# Sørensen index of dissimilarity, and it can be found for all sites using vegan function
# vegdist with binary data:
beta <- vegdist(BCI, binary=TRUE)
mean(beta)

#### 

# Change absolute abundance of species into relative abundance
BCI_sp_rel <-         
  decostand(BCI, method = "total")

# Bray-Curtis dissimilarity 
# Calculate distance matrix
BCI_sp_distmat <- 
  vegdist(BCI_sp_rel, method = "bray")

# Use the as.matrix function to write an easy to view distance matrix 
BCI_sp_distmat <- 
  as.matrix(BCI_sp_distmat, labels = T)

#Running NMDS using metaMDS
BCI_sp_NMS <-
  metaMDS(BCI_sp_distmat,
          distance = "bray",
          k = 3,             # selected number of dimensions
          maxit = 999,       # max number of iterations
          trymax = 500,      # maximum number of random starts
          wascores = TRUE)   # method of calculating species scores, default is TRUE

# Shepards test/goodness of fit
goodness(BCI_sp_NMS) # Produces a results of test statistics for goodness of fit for each point

stressplot(BCI_sp_NMS) # Produces a Shepards diagram

# Plotting points in ordination space
plot(BCI_sp_NMS, "sites")   # Produces distance 
orditorp(BCI_sp_NMS, "sites")   # Gives points labels

################################################################################
###### iNEXT Package ############################################################
library(iNEXT)
library(ggplot2)
# Can do individual or sample-size-based rarefaction and extrapolation (R/E)
# smaller sample sizes or extrapolated to a larger sample size

# Example 1
# Use the BCI data, but need to remove zeros
BCI_no_zero <- unlist(BCI[1,])
i_zero <- which(BCI_no_zero == 0)
BCI_out <-BCI_no_zero <- BCI_no_zero[-i_zero]

#RUN iNext for species richness (q=0), exponential of Shannon (1) or Simpson (2)
BCI_inext <-iNEXT(as.vector(BCI_out), q=0, datatype="abundance")

# Plot
ggiNEXT(BCI_inext, type=1, facet.var="site")
plot_1 <-ggiNEXT(test_ant , type=1, color.var="site") + 
  theme_bw(base_size = 18) + 
  theme(legend.position="none")

# Example 2
data(bird)
bird_out <- iNEXT(bird, q=c(0, 1, 2), datatype="abundance", endpoint=500)
# Sample-size-based R/E curves, separating plots by "site"
ggiNEXT(bird_out, type=1, facet.var="site")

# Example 3
# FOr incidence_freq, the data should be formatted:
# Row 1: Names of regions, Row 2: Sampling effort, Then rows are sums of each species
# Sample size rarefaction & extrapolation using ant data
data(ant)
# Create vector for "size"
  #"size is an integer vector of sample sizes for which diversity estimates will be computed
t <- seq(1, 700, by=10)
ant_out <- iNEXT(ant, q=0, datatype="incidence_freq", size=t)
ggiNEXT(ant_out, type=1) + theme(legend.position="bottom")
theme(legend.position="bottom", legend.title=element_blank())

# function estimateD() to compute diversity estimates with q = 0, 1, 2 (all three 
# levels of q are reported) for any particular level of sample size or any specified level of sample coverage for either abundance data or incidence data
estimateD(ant, datatype="incidence_freq", base="coverage",
          level=0.985, conf=NULL)

