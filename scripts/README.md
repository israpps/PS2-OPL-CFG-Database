# PS2 Game Info Scraping Scripts

This is a collection of hacky scripts used to midify a collection of CFG files by adding game information for:

* Game Description
* Number Of Players
* Genre
* Release Date
* Developer
* Rating

The scripts take your CFG folder as an argument, and will attempt to add game information scraped using an online service. The enriched CFG files will be saved in a new folder, so the original ones can be preserved.

## Pre-requisites to run the scripts

1. These are bash scripts. You need a UNIX-like environment to run them. They have been tested on a Debian derivative. If you have Windows, they should work with [WSL]( * Game Description * Number Of Players * Genre * Release Date * Developer * Rating).

2. Before running the scripts, you need to install [SkyScraper](https://github.com/muldjord/skyscraper).

3. It is strongly reccommended you create an account on [Screenscraper.fr](https://www.screenscraper.fr). There are different sunscription tiers that allow you to use different numbers of threads for scraping. If you feel the service is useful for you, support them through Patreon!

## Disclaimer

**Before trying anything with these scripts, MAKE A BACKUP COPY OF YOUR EXISTING CFG FILES. I AM NOT RESPONSIBLE FOR ANY LOSS OF DATA.**

## Using The Scraping Script

### How scrape_info.sh Works

scrape.info.sh takes two arguments:

```
Usage:

./scrape_info.sh <input CFG folder> <output CFG folder>

```

It is STRONGLY advised thast your input forlder is different from your output folder.

For each CFG file in the input folder, the scripts will:

1. Make a copy of the CFG file in the output folder.
2. Extract the game name from the CFG file.
3. Create a fake GAME_NAME.iso file (0 bytes) to give to Skyscraper.
4. Skyscraper will contact Screenscaper.fr and try to generate a gamelist file containing only that game.
5. The script will parse the 1-game gamelist.xml file to extract informatino about the game, and save it to the copied CFG file in a format that OPL understands.

As you can see it's all very hacky and buggy, but it worked for my needs.

### Using your Screenscraper.fr account

If have an account on Screenscraper.fr, you can add it in the username:password format by editing the CREDENTIALS option in the _Configurable Options_ section of the script.
If you don't create an account, you might be severely limited in how many requests you can perform on their webite. Read the [SkyScraper](https://github.com/muldjord/skyscraper) documentation for more info.

### Using The Local Cache

*After* you complete a scraping pass, Skyscraper will save data in its local cache. If you don't have any new games to scrape, you an disable querying the online service and tap directly form the local cache by setting the FORCE_CACHE_ONLY option to true inside the script under the _Configurable Options_ section.

### Other Options For The Script

You can configure additinoal options by opening the script and editing values under the _Configurable Options_ section. There are comments that briefly describe what the options do.

## Generating Stats

Use the create_stats.sh script, by passing your CFG folder as an argument. This will generate statistics regarding how many CFG files have a certain kind of information.

## License

The MIT License

Copyright (c) 2011 Dominic Tarr

Permission is hereby granted, free of charge, 
to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to 
deal in the Software without restriction, including 
without limitation the rights to use, copy, modify, 
merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom 
the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice 
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 