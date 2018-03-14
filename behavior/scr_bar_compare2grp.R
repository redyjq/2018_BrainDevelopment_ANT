# written by hao (2017/11/11)
# rock3.hao@gmail.com
# qinlab.BNU

rm(list = ls())
library(plyr);library(ggplot2);library(ggsignif)
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(psych))

fig.dpi <- 100; fig.wid <- 16; fig.hei <- 9; p.pos <- 66
fig.savedir <- "/Users/haolei/Desktop/Docum/Projects/DataAnaly/BrainDev_ANT/Figure"

condname.figshow <- c("Alert", "Orient", "Conflict")
condname.colname <- c("A_NoDoub_mean", "O_CenSpat_mean", "C_InconCon_mean")
# condname.figshow <- c("ACC","dACC")
# condname.colname <- c("AnteriorCingulate","AnteriorCingulate_from_spmT_0003")

#----------------------------------------

setwd("/Users/haolei/Desktop/Docum/Projects/DataAnaly/BrainDev_ANT/AnalyDocs")
data.grp    <- "SWU"
data.subgrp <- c("SWUC", "SWUA")
SWUC <- read.csv("res_SWUC_img5behav.csv")
SWUA <- read.csv("res_SWUA_img5behav.csv")

#----------------------------------------

# setwd("/Users/haolei/Desktop/Docum/Projects/DataAnaly/BrainDev_ANT/AnalyDocs")
# data.grp    <- "CBD"
# data.subgrp <- c("CBDC", "CBDA")
# CBDC <- read.csv("res_CBDC_img5behav.csv")
# CBDA <- read.csv("res_CBDA_img5behav.csv")

#----------------------------------------
# 
# CBDC <- ddply(CBDC, .(Group), subset,
#               A_NoDoub_mean > mean(A_NoDoub_mean)-sd(A_NoDoub_mean)*1 & A_NoDoub_mean < mean(A_NoDoub_mean)+sd(A_NoDoub_mean)*1)
# CBDA <- ddply(CBDA, .(Group), subset,
#               A_NoDoub_mean > mean(A_NoDoub_mean)-sd(A_NoDoub_mean)*1 & A_NoDoub_mean < mean(A_NoDoub_mean)+sd(A_NoDoub_mean)*1)

#----------------------------------------

data.fig <- data.frame(matrix(NA,0,3))
for (igrp in  c(1:length(data.subgrp))) {
  for (icond in c(1:length(condname.figshow))) {
    data.con <- data.frame(rep(condname.figshow[icond], nrow(get(data.subgrp[igrp]))))
    data.ned <- data.frame(get(data.subgrp[igrp])[c("Group",condname.colname[icond])])
    
    data.tem <- cbind(data.con, data.ned)
    colnames(data.tem) <- c("Index","Group","Index.Data")
    
    data.fig <- rbind(data.fig, data.tem)
  }
}

# p.sign <- c(1,2,3)
# p.line <- c(1,2,3)
# for (icond in c(1:length(condname.figshow))) {
#   subset.fig <- ddply(data.fig, .(Index), subset, Index == condname.figshow[icond] )
#   grp1  <- ddply(subset.fig, .(Index), subset, Group == data.subgrp[1])
#   grp2  <- ddply(subset.fig, .(Index), subset, Group == data.subgrp[2])
#   if (mean(grp1$Index.Data) > mean(grp2$Index.Data)) {
#     p.sign[icond] <- mean(grp1$Index.Data) + describe(grp1$Index.Data)$se * 3.5
#     p.line[icond] <- mean(grp1$Index.Data) + describe(grp1$Index.Data)$se * 2
#   } else {
#     p.sign[icond] <- mean(grp2$Index.Data) + describe(grp2$Index.Data)$se * 3.5
#     p.line[icond] <- mean(grp1$Index.Data) + describe(grp1$Index.Data)$se * 2
#   }
# }

data.barfig <- ggbarplot (data.fig, x="Index", y="Index.Data",
                          title = paste("The difference between Children and Adults (", data.grp, ")", sep = ""), 
                          # ylim = c(25,60),
                          xlab = FALSE, ylab = "Network Scores",
                          #add = c("mean_se", "jitter"),  add.params = list(size = 1),
                          add = "mean_se",  add.params = list(size = 1.6),
                          color = "Group", fill = "Group", position = position_dodge(0.8)) + 
  stat_compare_means (aes(group = Group), method = "t.test", 
                      # label.y = c(p.sign[1], p.sign[2], p.sign[3]), 
                      label.y = p.pos, 
                      label = "p.signif", size = 5) +
  #geom_jitter(aes(x = Index, y = Index.Data,colour = factor(Group)), position = position_jitterdodge()) +
  scale_color_manual (values=c("salmon1","gray70"),name = "Group", labels = c("Children", "Adults"),
                      guide = FALSE) +
  scale_fill_manual (values=c("salmon1","gray70"),name = "Group", labels = c("Children", "Adults")) +
  
  # geom_signif(stat="identity", 
  #             data=data.frame(x=c(0.8, 1.8, 2.8), xend=c(1.2, 2.2, 3.2),
  #                             y=c(p.line[1], p.line[2], p.line[3]), 
  #                             annotation=c("", "", "")),
  #             aes(x=x,xend=xend, y=y, yend=y, annotation=annotation)) +
  theme(
    plot.title = element_text(size = 15, colour = "black", face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 0.6, colour = "black"),
    axis.ticks.length = unit(0.2, "cm"),
    axis.line.x = element_line(colour = "black", size = 0.8),
    axis.line.y = element_line(colour = "black", size = 0.8),
    axis.text = element_text(size = 15, colour = 'black'),
    axis.title = element_text(size = 20, colour = "black"),
    panel.background = element_rect(fill = "white"),
    legend.title = element_text(size = 18),
    legend.text = element_text(size = 15),
    legend.justification = c(0.5,1))
data.barfig

fig.name <- paste("fig_indexcomp_ANT_", data.grp, ".tiff", sep = "")
ggsave(fig.name, path = fig.savedir, data.barfig, width=fig.wid, height=fig.hei, units="cm", dpi=fig.dpi)
