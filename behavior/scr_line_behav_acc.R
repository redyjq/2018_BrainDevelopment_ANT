# written by hao (2017/08/06)
# rock3.hao@gmail.com
# qinlab.BNU

rm(list = ls())
library(ggplot2); library(psych)
Fig.dpi <- 100; Fig.wid <- 20; Fig.hei <- 15

# Data.Sample <- "CBD"
# Data.Group  <- c(rep("CBDC", 8), rep("CBDA", 8))
Data.Sample <- "SWU"
Data.Group  <- c(rep("SWUC", 8), rep("SWUA", 8))

WorkDir     <- "~/Desktop/Docum/Projects/DataAnaly/BrainDev_ANT/AnalyDocs"
Fig.SaveDir <- "~/Desktop/Docum/Projects/DataAnaly/BrainDev_ANT/Figure"

# =============================================================================================== #
setwd (WorkDir)
GroupAll <- unique(Data.Group)
for (grp in  c(1:length(GroupAll))) {
  assign(GroupAll[grp], read.csv(paste("res_", GroupAll[grp], "_img5behav.csv", sep = "")))
}

#ACC Line Chart
Cond.Fig    <- rep(c("Con_No", "Con_Cent", "Con_Doub", "Con_Spat", 
                     "Incon_No", "Incon_Cent", "Incon_Doub", "Incon_Spat"), 2)
Cond.Fig    <- factor(Cond.Fig, order = T, 
                      levels = c("Con_No", "Con_Cent", "Con_Doub", "Con_Spat", 
                                 "Incon_No", "Incon_Cent", "Incon_Doub", "Incon_Spat"))

mACC.Fig  <- vector(mode = "numeric", length = 0)
seACC.Fig <- vector(mode = "numeric", length = 0)
for (i in GroupAll){
  mACC.Fig <- c(mACC.Fig, 
                c(mean(get(i)$ACC_Con_No), mean(get(i)$ACC_Con_Cent),
                  mean(get(i)$ACC_Con_Doub), mean(get(i)$ACC_Con_Spat),
                  mean(get(i)$ACC_Incon_No), mean(get(i)$ACC_Incon_Cent),
                  mean(get(i)$ACC_Incon_Doub), mean(get(i)$ACC_Incon_Spat)))
  seACC.Fig <- c(seACC.Fig, 
                 c(describe(get(i)$ACC_Con_No)$se, describe(get(i)$ACC_Con_Cent)$se,
                   describe(get(i)$ACC_Con_Doub)$se, describe(get(i)$ACC_Con_Spat)$se,
                   describe(get(i)$ACC_Incon_No)$se, describe(get(i)$ACC_Incon_Cent)$se,
                   describe(get(i)$ACC_Incon_Doub)$se, describe(get(i)$ACC_Incon_Spat)$se))
}

ACC.Fig  <- data.frame(Data.Group, Cond.Fig, mACC.Fig, seACC.Fig)
ACC.Line <- ggplot(data = ACC.Fig, 
                   aes(x = as.factor(Cond.Fig), y = mACC.Fig,
                       colour = Data.Group, group = Data.Group, shape = Data.Group)) + 
  geom_errorbar(aes(ymin = mACC.Fig - seACC.Fig, ymax = mACC.Fig+seACC.Fig), width = 0.08) +
  # geom_point(size = 2.5) +
  geom_line(size = 1.8) +
  labs(x = "Cue Condition", y = "mean ACC", 
       title = paste("The difference between Children and Adults (",Data.Sample, ")",sep = "")) + 
  scale_color_manual (values=c("gray60", "salmon1"), name="Group", labels=c("Adults", "Children")) +
  scale_shape_manual (values=c("gray60", "salmon1"), name="Group", labels=c("Adults", "Children"), guide=FALSE) +
  theme(
    plot.title = element_text(size = 15, colour = "black", face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 0.6, colour = "black"),
    axis.ticks.length = unit(0.2, "cm"),
    axis.line.x = element_line(colour = "black", size = 0.8),
    axis.line.y = element_line(colour = "black", size = 0.8),
    axis.text = element_text(size = 15, colour = 'black'),
    axis.text.x = element_text(vjust = 1, hjust = 1, angle = 45),
    axis.title = element_text(size = 20, colour = "black"),
    panel.background = element_rect(fill = "white"),
    legend.title = element_text(size = 18),
    legend.text = element_text(size = 15),
    legend.position = "top",
    legend.justification = c(0.5,1))
ACC.Line

Fig.Name <- paste("fig_line_behav_acc_", Data.Sample, ".tiff", sep = "")
ggsave(Fig.Name, path = Fig.SaveDir, ACC.Line, width=Fig.wid, height=Fig.hei, units="cm", dpi=Fig.dpi)
