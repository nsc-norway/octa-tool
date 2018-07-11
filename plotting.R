library(ggplot2)

stats <- read.delim("all-stats.txt")
s <- stats[(stats$Instrument != "NS" | stats$LANE == 1) & !is.na(stats$LibraryPrep),]
s$UDI <- as.factor(s$UDI)
ggplot(s, aes(x=LibraryPrep, fill=UDI)) + facet_grid(Instrument~.) + 
  geom_bar() + coord_flip() + ggtitle("Number of lanes with mis-ID and sample prep information")

ggplot(s, aes(x=LibraryPrep, y=SingleMisID)) + facet_grid(Instrument~.) +
  geom_boxplot() + coord_flip() + ggtitle("MisID % [ALL]")
s_udi_only <- s[s$UDI==1,]
ggplot(s_udi_only, aes(x=LibraryPrep, y=SingleMisID)) + facet_grid(Instrument~.) +
  geom_boxplot() + coord_flip() + ggtitle("MisID % [UDI ONLY]")

s_patterned_udi <- s_udi_only[s_udi_only$Instrument %in% c("HX", "H4"),]

ggplot(s_patterned_udi, aes(x=LibraryPrep, y=SingleMisID, fill=Instrument)) +
  geom_dotplot(binaxis = "y", binwidth=0.02) + ggtitle("MisID %, patterned FC & UDI only")


ggplot(s_patterned_udi, aes(x=PF, y=SingleMisID, color=Instrument)) + geom_point() +
  ggtitle("MisID % Patterned FC, UDI, vs PF % [Known prep types]")


d_patterned_udi <- stats[stats$UDI==T & stats$Instrument %in% c("HX", "H4"),]
ggplot(d_patterned_udi, aes(x=PF, y=SingleMisID, color=Instrument)) + geom_point() + 
  ggtitle("MisID % Patterned FC, UDI, vs PF %")



ggplot(d_patterned_udi, aes(x=SingleMisID, fill=Instrument)) +
  geom_histogram(binwidth=0.1) + ggtitle("MisID %, patterned FC & UDI only [Includes unknown prep type]")

highmisid <- stats[stats$SingleMisID > 1,]
highmisid

