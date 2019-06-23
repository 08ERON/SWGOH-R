## Script to summarise important leader toon data 
## from guild members

setwd("/path/to/your/working/directory")
repo            <- "https://cran.csiro.au/"

#### call libraries and if absent install and call them
libraries <- c("stringr", "data.table", "plyr", "dplyr")
to_be_installed <- libraries[!libraries %in% installed.packages()[,"Package"]]
if(length(to_be_installed)) install.packages(to_be_installed,  repos = repo)

sapply(libraries, library, character.only = T, quietly = T)

guild_data <- fread("final_output.csv")

important_leaders <- c("Darth Revan","Jedi Knight Revan", "Darth Traya", "Commander Luke Skywalker", "Padmé Amidala",
                       "General Grievous", "Asajj Ventress", "Mother Talzin", "Kylo Ren (Unmasked)", "Bossk", "Jango Fett", 
                       "Carth Onasi", "Emperor Palpatine", "Qi'ra", "Rey (Jedi Training)", "Bastila Shan" , "Chief Chirpa",
                       "General Veers", "Wedge Antilles", "Hera Syndulla", "Jyn Erso")

leader_data <- guild_data[name %in% important_leaders]
leader_data[, no_of_zetas := apply(leader_data[, list(zeta_1,zeta_2,zeta_3)], 1, function(x) length(which(!is.na(x))))]

write.table(leader_data[, list(name, player, alignment, level, stars, gear_level, power, no_of_zetas)], "leader_data.csv", sep=",", row.names=F, qmethod='double')
write.table(leader_data[, list(name, player, alignment, level, stars, gear_level, power, no_of_zetas)], "leader_data.tsv", sep="\t", row.names=F, qmethod='double')


