#### script to obtain general classification data and specific guild member data 
#### abour SWGOH characters and ships

### edit these
setwd("/path/to/your/working/directory")
guild_api       <- "https://swgoh.gg/api/guild/1454"
repo            <- "https://cran.csiro.au/"

#### call libraries and if absent install and call them
libraries <- c("xml2", "stringr", "data.table", "jsonlite", "plyr", "dplyr", "zoo")
to_be_installed <- libraries[!libraries %in% installed.packages()[,"Package"]]
if(length(to_be_installed)) install.packages(to_be_installed,  repos = repo)

sapply(libraries, library, character.only = T, quietly = T)

char_api        <- "http://swgoh.gg/api/characters/"
ships_api       <- "http://swgoh.gg/api/ships/"

# guild data
data_list <- fromJSON(guild_api) 

# get player data for the player url
# (this is used as the index in the JS object)
guild_summary_dt <- data_list$players$data %>% data.table
guild_player_dt_0 <- ldply(data_list$players$units, function(x) x$data[, c("url", "base_id", "gear_level", "power", "rarity", "level", "zeta_abilities")]) %>% data.table
guild_player_dt_0[, ally_code := str_extract(url, "[0-9]{9}") %>% as.integer]
guild_player_dt <- left_join(guild_player_dt_0, guild_summary_dt[, list(name, ally_code)], by='ally_code') %>% data.table
setnames(guild_player_dt, "name", "player")

##### stats definitions
## 1: Health
## 2: Strength
## 3: Agility
## 4: Tactics
## 5: Speed
## 6: Physical Damage
## 7: Special Damage
## 8: Armor
## 9: Resistance
## 10: Armor Penetration
## 11: Resistance Penetration
## 12: Dodge Chance ? Deflection Chance
## 13: Dodge Chance ? Deflection Chance 
## 14: Physical Critical Chance
## 15: Special Critical Chance
## 16: Critical Damage
## 17: Potency
## 18: Tenacity
## 27: Health Steal
## 28: Protection
## 37: Physical Accuracy ? Special Accuracy
## 38: Physical Accuracy ? Special Accuracy
## 39: Physical Critical Avoidance ? Special Critical Avoidance
## 40: Physical Critical Avoidance ? Special Critical Avoidance

#### char and ship data

char_dt0 <- fromJSON(char_api) %>% data.table
char_dt <- char_dt0[, list(name, base_id, url, alignment , role, categories)]
ships_dt0 <- fromJSON(ships_api) %>% data.table 
ships_dt <- ships_dt0[, list(name, base_id, url, alignment , role, categories)]

char_ships_alignment <- rbind(cbind(char_dt, type="characters"), 
                              cbind(ships_dt, type="ships"))

saveRDS(char_ships_alignment, "output_data/char_ships_alignment.rds")

### join with guild data
data_dt_0 <-  inner_join(char_ships_alignment, guild_player_dt, by="base_id") %>% data.table
data_dt_0[is.na(rarity), rarity := 0]
setnames(data_dt_0, "rarity", "stars")

data_dt_1 <- data_dt_0[, list(player, ally_code, name, base_id, alignment, role, gear_level, power, stars, level)]

#### fixing categories and zeta abilities
categories <- llply(data_dt_0$categories, function(x) {
    DT <- data.table(rbind(x))
    if(nrow(DT) == 0) DT <- data.table(V1=NA)
    return(DT)}) %>% rbindlist(fill=T)

setnames(categories, paste0("V", 1:ncol(categories)), paste0("Affiliation", 1:ncol(categories)))

zeta_abilities <- llply(data_dt_0$zeta_abilities, function(x) {
    DT <- data.table(rbind(x))
    if(nrow(DT) == 0) DT <- data.table(V1=NA)
    return(DT)}) %>% rbindlist(fill=T)
setnames(zeta_abilities, paste0("V", 1:ncol(zeta_abilities)), paste0("zeta_", 1:ncol(zeta_abilities))) 

final_output <- cbind(data_dt_1, categories, zeta_abilities)

write.table(final_output, "final_output.csv", sep=",", row.names=F, qmethod='double')
write.table(final_output, "final_output.tsv", sep="\t", row.names=F, qmethod='double')

