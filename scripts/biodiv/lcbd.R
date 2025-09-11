library(vegan)
library(ade4)
library(tidyverse)
library(gridExtra)
data(doubs)
y = doubs$fish[c(1:3, 9, 18:21, 23:25),c('Satr', 'Phph', 'Neba', 'Cyca', 'Titi', 'Ruru','Alal')]
doubs$species 
y = doubs$fish[-8,]
ct = function(m) {
	apply(m, MARGIN = 1, FUN = function(x) sum(x^2))
}

y_ct = decostand(y, method = 'normalize') # Same thing y_ct = sweep(y, MARGIN = 1, sqrt(ct(y)), FUN = '/') # Chord transformation
# y_s_c_chord = vegdist(y, method = 'chord') # This is the chord DISTANCE
s = scale(y_ct, scale = F)^2 # Squared difference (center)^2
ss = sum(s) # Sum of square_total
bd = ss/(nrow(y)-1) # BD_total

# LCBD
lcbd = apply(s, 1, function(x) sum(x))/ss# SCBD 
scbd = apply(s, 2, function(x) sum(x))/ss

lcbd_df = as.data.frame(lcbd) 
lcbd_df$site = rownames(lcbd_df)
lcbd_df = lcbd_df |> 
	mutate(site = factor(site, levels = site), 
				 sp = 'LCBD',
				 type = 'LCBD')|> 
	rename(val = 'lcbd')
scbd_df = as.data.frame(scbd) 
scbd_df$sp = rownames(scbd_df)
scbd_df = scbd_df |> 
	mutate(site = factor('SCBD', levels = c(rownames(y), 'SCBD')),
				 sp = factor(sp, levels = sp),
				 type = 'SCBD') |> 
	rename(val = 'scbd')

plot(doubs$xy[-8,], cex = 50*lcbd, pch = 19)

nmds = metaMDS(y, distance = 'bray')
nmds$stress
# nmds = rda(s)
plot(nmds, type = 't')

y_df = as.data.frame(y) |> 
	mutate(site = rownames(y)) |> 
	pivot_longer(-site, names_to = 'sp', values_to = 'val') |> 
	mutate(sp = factor(sp, levels = names(y)), 
				 site = factor(site, levels = c(rownames(y), 'SCBD')), 
				 type = 'sp') 
all_var = rbind(y_df, lcbd_df,scbd_df)

xx = all_var |> 
	mutate(val2 = ifelse(type == 'LCBD', (val *20)^2, val), 
				 val2 = ifelse(type == 'SCBD', (val2 *15)^2, val2)) |> 
	ggplot(aes(x = sp, y = site, colour = type, fill = type)) + 
	geom_point(aes(size = val2), alpha = 0.75, shape = 21) + 
	geom_text(aes(x = as.numeric(sp)+.3, label = round(val, 2)), color = 'black') + 
	scale_size_continuous(limits = c(0.001, 100), range = c(1,17), breaks = c(1,10,50,75)) + 
	labs( x= "", y = "", size = "Abundance", fill = "")  + 
	theme(legend.key=element_blank(), 
				axis.text.x = element_text(colour = "black", size = 12, face = "bold", angle = 90, vjust = 0.3, hjust = 1), 
				axis.text.y = element_text(colour = "black", face = "bold", size = 11), 
				legend.text = element_text(size = 10, face ="bold", colour ="black"), 
				legend.title = element_text(size = 12, face = "bold"), 
				panel.background = element_blank(), panel.border = element_rect(colour = "black", fill = NA, size = 1.2), 
				legend.position = "none") +  
	scale_y_discrete(limits=rev);xx
