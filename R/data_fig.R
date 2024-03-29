# image of genotypes + phenotypes

library(here)
library(broman)
library(qtl)



color <- c("white", broman::brocolors("crayons")[c("Cornflower", "Dandelion", "Blush")])

file <- here("R/_cache/data_fig.RData")
if(file.exists(file)) {
    load(file)
} else {

    load("~/Projects/Attie/GoldStandard/FinalData/aligned_geno_with_pmap.RData")
    load("~/Projects/Attie/GoldStandard/FinalData/lipomics_final_rev2.RData")
    phe <- lipomics[,c("MouseNum","INSULIN (ng/ml) 10 wk"),drop=FALSE]

    # reduce markers
    reduced <- NULL
    for(i in 1:nchr(f2g))
        reduced <- c(reduced, pickMarkerSubset(f2g$geno[[i]]$map, 1))
    f2g <- pull.markers(f2g, reduced)

    id <- lineup::findCommonID(f2g$pheno$MouseNum, phe$MouseNum)
    f2g <- subset(f2g, ind=id$first)
    f2g$pheno <- cbind(f2g$pheno, insulin=phe[id$second,2])
    names(f2g$geno)[20] <- ""

    save(f2g, phe, file=file)
}



png(here("Figs/data_fig.png"), height=1000, width=1800, pointsize=28)
layout(cbind(1,2), width=c(1, 0.12))

par(mar=c(6.1,4.1,2.6,0.6))
geno.image(f2g, col=color, main="", ylab="Mice", reorder=nphe(f2g))
u <- par("usr")
axis(side=3, at=u[2]-5, labels="X", xpd=TRUE, line=-0.5)

y <- log10( f2g$pheno$insulin[order(f2g$pheno$insulin)] )
par(mar=c(6.1,2.3,2.6,2.3))

source("viridis.R")

image(1, seq(along=y), rbind(y), col=viridis_qtl(256),
      xlab="", xaxt="n", ylab="", yaxt="n")
axis(side=2, at=seq(100, 500, by=100), label=rep("", 5))
axis(side=3, at=mean(par("usr")[1:2]), label="phenotype",
     line=-0.5, xpd=TRUE, tick=FALSE)

dev.off()
