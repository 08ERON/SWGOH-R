# SWGOH-R
R Scripts for pulling and reshaping swgoh.gg guild data 

Use these scripts to provide your app with up-to-date information about your SWGOH guild members using swgoh.gg as a data source and writing the output as both TSV and CSV tables, with automatic removal of columns with no data and using abbreviations for toon names.

We recommend using the data scraper as a daily task (eg a cronjob) to avoid hitting the swgoh.gg servers too often. There are no args required, just run as (on Windows)  
`Rscript.exe swgoh.gg_guild_data.R`



`guild_data_reshape_func.R` is a separate data subsetting/reshaping function to subset the data from the previous script. For this you need to provide two args, the toon nickname and number of stars of that toon, and you can edit the `char_ships_nicknames.csv` file to change the nicknames and abbreviations as you want. They don't need to be in any specific order. An example:  
`Rscript.exe guild_data_reshape_func.R AA 7`  
  
`team_builder_func.R` is a data subsetting function allows guild members to search their own toons for suitable team candidates. Searchable fields are:  
`player, type, gear_level, power, level, stars, Alignment, Role, Affiliation, zeta`  
`player` = player name  
`type` = either "ships" or "characters"  

Run the script with args describing the columns you want and the allowable values of the subset of data in which you're interested. If you have multiple search terms for a field (think a regex "or") separate the field values with commas.  

For example if you want to find all of guild member Oberon's  level 85, 7 star toons at gear level greater than 8 and Affiliation with either Sith or Empire and any role or power level:  
`Rscript.exe guild_data_reshape_func.R player=Oberon stars=7 level=85 power=any gear_level=9,10,11,12 Affiliation=Sith,Empire Role=any`

