### function to help
### guild members put together a synergistic team
### args should be: 


### change this to the same working directory as the 
### swgoh.gg_guild_data script uses
#setwd("/path/to/your/working/directory")
setwd("C:/Users/Andy/Google Drive/swgoh/swgoh.gg_scraping/guild_data_git")
### change repo to suit or use the one given
repo <- "https://cran.csiro.au/"

libraries <- c("data.table", "magrittr", "stringr")
to_be_installed <- libraries[!libraries %in% installed.packages()[,"Package"]]
if(length(to_be_installed)) install.packages(to_be_installed,  repos = )

sapply(libraries, library, character.only = T, quietly = T)

subset_args <- commandArgs(trailingOnly = T)

###testing
# subset_args <- c("player=Oberon","stars=7", "level=85", "power=any", "gear_level=9,10,11,12", "Affiliation=Sith,Empire", "Role=any")

### interpreting args
subset_args <- gsub(",", "|", subset_args)
subset_cols <- gsub("=", "", str_extract(subset_args, "^.+="))
subset_vals <- gsub("=", "", str_extract(subset_args, "=.+$"))

### recently updated guild data from the 
### swgoh.gg_guild_data script
guild_data <- fread("final_output.csv")

#### combine affiliations and zetas for easier reference
aff_cols_inds <- grep("Affiliation_", colnames(guild_data))
zeta_cols_inds <- grep("zeta_", colnames(guild_data))

guild_data[, Affiliation := gsub(",NA", "", do.call(paste, c(.SD, sep=","))), by=list(player, name), .SDcols=aff_cols_inds]
guild_data[, zeta := gsub(",NA", "", do.call(paste, c(.SD, sep=","))), by=list(player, name), .SDcols=zeta_cols_inds]

player_data <- guild_data[, list(type, gear_level, power, level, stars,
                                 Alignment, Role, Affiliation, zeta), 
                            by=list(player, name)]


match_cols <- subset_cols[subset_vals != "any"]
match_vals <- subset_vals[subset_vals != "any"]

sapply(1:length(match_cols), function(x) {
    player_data <<- player_data[grep(match_vals[x], get(match_cols[x]))]
    })  %>% invisible

### output in both csv and tsv
write.table(player_data, "subset_data.csv", sep=",", row.names=F, qmethod='double')
write.table(player_data, "subset_data.tsv", sep="\t", row.names=F, qmethod='double')




 
 
 
 