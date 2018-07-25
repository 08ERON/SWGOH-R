#### script to obtain general classification data and specific guild member data 
#### abour SWGOH characters and ships

### edit these
setwd("/path/to/your/working/directory")
guild_api       <- "https://swgoh.gg/api/guilds/1454/units"
guild_zeta_url  <- "http://swgoh.gg/g/1454/basedeltazero/zetas/"
repo            <- "https://cran.csiro.au/"

#### call libraries and if absent install and call them
libraries <- c("xml2", "stringr", "data.table", "jsonlite", "plyr", "dplyr", "zoo")
to_be_installed <- libraries[!libraries %in% installed.packages()[,"Package"]]
if(length(to_be_installed)) install.packages(to_be_installed,  repos = repo)

sapply(libraries, library, character.only = T, quietly = T)

char_api        <- "http://swgoh.gg/api/characters/"
ships_api       <- "http://swgoh.gg/api/ships/"
light_side_url  <- "https://swgoh.gg/characters/f/light%20side/"
dark_side_url   <- "https://swgoh.gg/characters/f/dark%20side/"

# guild data
data_dt_0 <- fromJSON(guild_api) %>% rbindlist(fill=T, use.names=TRUE, idcol=T) 
setnames(data_dt_0, c(".id", 'rarity'), c("base_id", 'stars'))

#### alignment
html_convert_func   <- function(u){
  alignment_html    <- read_html(u)
  vec_0 <- str_split(xml_text(alignment_html), "\n")[[1]]
  vec_1 <- str_split(vec_0[grep("Side", vec_0)], " . ") 
  dt_0  <- llply(vec_1, function(x) data.table(rbind(x))) %>% rbindlist(fill=T)
  dt_1  <- cbind(name = vec_0[grep("Side", vec_0)+1], dt_0)
  dt_1  <- dt_1[name!=""]
  dt_1[, name := gsub("^ ", "", name)]
  aff_names <- paste0("Affiliation_", 1:(ncol(dt_1)-3))
  setnames(dt_1, colnames(dt_1)[-1], c("Alignment", "Role", aff_names))
  return(dt_1)
}

alignment_dt <- rbind(html_convert_func(light_side_url), html_convert_func(dark_side_url), fill=T)

#### other general data
char_dt0 <- fromJSON(char_api) %>% data.table 
ships_dt0 <- fromJSON(ships_api) %>% data.table 

char_ships_dt0 <- rbind(char_dt0[, list(base_id, name, type="characters")], 
                        ships_dt0[, list(base_id, name, type="ships")])

### join with guild data
data_dt <-  left_join(char_ships_dt0, data_dt_0, by="base_id") %>% data.table
data_dt[is.na(stars), stars := 0]
data_dt_1 <- left_join(data_dt, alignment_dt, by='name') %>% data.table

##### zetas 
guild_zeta_html <- read_html(guild_zeta_url)

#### groups data referring to a player
guild_member_html_data <- xml_find_all(guild_zeta_html, ".//tr")

guild_member_zetas <- sapply(2:length(guild_member_html_data), function(x){
        player_data <- guild_member_html_data[x]
        player <- xml_find_first(player_data, ".//strong") %>% xml_text
        zeta_attrs <- xml_attrs(xml_find_all(player_data, ".//img"))
        player_zetas_0 <- lapply(zeta_attrs, function(x) rbind(x) %>% data.table) %>%
                                rbindlist(fill=T)
        player_zetas_0[, alt := na.locf(alt)]
        player_zetas_0 <- player_zetas_0[!is.na(title), list(player, name = alt, zeta = title)]
        player_zetas_0[, zeta_cols := paste0("zeta_", 1:.N), by=name]
        player_zetas <- dcast(player_zetas_0, player+name~zeta_cols, value.var = "zeta")
        return(player_zetas)
}, simplify=F) %>% rbindlist(fill=T)


final_output <- left_join(data_dt_1, guild_member_zetas, by=c("player","name")) %>% data.table

write.table(final_output, "final_output.csv", sep=",", row.names=F, qmethod='double')
write.table(final_output, "final_output.tsv", sep="\t", row.names=F, qmethod='double')
