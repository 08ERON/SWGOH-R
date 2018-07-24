# SWGOH-R
R Scripts for pulling and reshaping swgoh.gg guild data 

Use these scripts to provide your app with up-to-date information about your SWGOH guild members using swgoh.gg as a data source and writing the output as both TSV and CSV tables, with automatic removal of columns with no data and using abbreviations for toon names.

We recommend using the data scraper as a daily task (eg a cronjob) to avoid hitting the swgoh.gg servers too often. There are no args required, just run as (on Windows)  
`Rscript.exe swgoh.gg_guild_data.R`



The separate reshaping function can then subset the data as you want. For this you need to provide two args, the toon nickname and number of stars of that toon, and you can edit the `char_ships_nicknames.csv` file to change the nicknames and abbreviations as you want. They don't need to be in any specific order. An example:  
`Rscript.exe guild_data_reshape_func.R AA 7`

A more general reshape function is in the works.

