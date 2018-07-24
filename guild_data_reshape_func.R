### function to output required
### subset of guild data

### change this to the same working directory as the 
### swgoh.gg_guild_data script uses
setwd("/path/to/your/working/directory")

### change repo to suit or use the one given
repo <- "https://cran.csiro.au/"

libraries <- c("data.table", "magrittr")
to_be_installed <- libraries[!libraries %in% installed.packages()[,"Package"]]
if(length(to_be_installed)) install.packages(to_be_installed,  repos = )

sapply(libraries, library, character.only = T, quietly = T)

subset_args <- commandArgs(trailingOnly = T)

### use nickname, look up in table
char_nickname <- subset_args[which(is.na(as.integer(subset_args)))]
char_name_tbl <- fread("char_ships_nicknames.csv")
baseid <- char_name_tbl[which(Nickname==char_nickname), base_id]

char_stars <- na.omit(as.integer(subset_args))

### recently updated guild data from the 
### swgoh.gg_guild_data script
guild_data <- fread("final_output.csv")

### change which columns you want to keep
in_cols <- c("name", "player", "stars", "level", "gear_level", "power", "zeta_1", "zeta_2", "zeta_3")

### get all columns
### remove NA columns

subset_data <- guild_data[base_id == baseid & stars == char_stars,  
           lapply(.SD, function(x) if(all(!is.na(x))) return(x)),
           .SDcols = in_cols]


### output in both csv and tsv
write.table(subset_data, "subset_data.csv", sep=',', row.names = F)
write.table(subset_data, "subset_data.tsv", sep='\t', row.names = F)

 
 
 
 