### function to output required
### subset of guild data
###
### args should be toon abbreviation (as per the "char_ships_nicknames.csv") 
### and number of stars, in any order


### change this to the same working directory as the 
### swgoh.gg_guild_data script uses
setwd("/path/to/your/working/directory")

### change repo to suit or use the one given
repo <- "https://cran.csiro.au/"

libraries <- c("data.table", "magrittr", "gridExtra", "stargazer")
to_be_installed <- libraries[!libraries %in% installed.packages()[,"Package"]]
if(length(to_be_installed)) install.packages(to_be_installed,  repos = repo)

sapply(libraries, library, character.only = T, quietly = T) %>% invisible

subset_args <- commandArgs(trailingOnly = T)

### use nickname, look up in table
char_nickname <- subset_args[which(is.na(as.integer(subset_args)))]
char_name_tbl <- fread("char_ships_nicknames.csv")
baseid <- char_name_tbl[which(Nickname==char_nickname), base_id]

char_stars <- na.omit(as.integer(subset_args))

### recently updated guild data from the 
### swgoh.gg_guild_data script
guild_data <- fread("final_output.csv")

### change which columns you want to keep as default
in_cols <- c("name", "player", "stars", "level", "gear_level", "power", "zeta_1", "zeta_2", "zeta_3")


### remove NA columns
subset_data <- guild_data[base_id == baseid & stars >= char_stars,  
           lapply(.SD, function(x) if(any(!is.na(x))) return(x)),
           .SDcols = in_cols]

### if any zetas present, make zetas into one column
    if(any(grepl("zeta", colnames(subset_data)))){
        zeta_cols_inds <- grep("zeta_", colnames(subset_data))
        subset_data[, zeta := gsub(",NA", "", do.call(paste, c(.SD, sep=","))), by=list(player, name), .SDcols=zeta_cols_inds]
        subset_data <- subset_data[, list(stars, level, gear_level, power, zeta), by=list(name, player)]
    }
### output in both csv and tsv
write.table(subset_data, "subset_data.csv", sep=",", row.names=F, qmethod='double')
write.table(subset_data, "subset_data.tsv", sep="\t", row.names=F, qmethod='double')

png(filename = "subset_data.png", width=960,height=24*subset_data[, .N])
grid.table(subset_data)
dev.off()

stargazer(subset_data, type='text', out = "subset_data.txt", summary=F)
stargazer(subset_data, type='html', out = "subset_data.html", summary=F)

