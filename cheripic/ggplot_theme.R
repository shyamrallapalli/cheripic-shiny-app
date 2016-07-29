library(grid)
library(gridExtra)
library(ggplot2)

## my ggplot theme custamizations
mytheme = theme(panel.background = element_rect(fill='white', colour='black'),
                 text = element_text(size = 20, face='bold', colour='black'),
                 axis.title.x = element_text(size = 19, face='bold', color='black', vjust = -1),
                 axis.text = element_text(size = 17, face='bold', color='black'),
                 panel.grid.major = element_line(linetype = 'dotted', colour='black'),
                 panel.border = element_rect(fill=NA, linetype = "solid", colour='black'),
                 plot.margin=unit(c(2,2,5,2),'mm'), legend.position=c(0.1,0.9), legend.title = element_blank(),
                 legend.text = element_text(colour = 'black', size = 15, face = 'bold'), legend.box = "horizontal",
                 legend.key.width=unit(2, "cm"), legend.key = element_rect(fill='white'))

# colour palette
# "#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7"
# black      orange     skyblue  bluish greeen  yellow    blue      vermillion  reddish purple
