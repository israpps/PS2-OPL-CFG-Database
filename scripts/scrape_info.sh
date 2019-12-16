#!/bin/bash

# Configurable Options

MAX_DESCR_LENGTH=255						# Maximum description length to be used. As of now OPL Manager has a limit of 255 chars.
FORCE_CACHE_ONLY=false						# Forces SkyScraper to use the local cache. Useful if you have been through a first successful scraping already.
MISSING_GAMES_LIST_NAME=missing_games.txt	# The name of the list containing the game names that are not present on the scraping site.
OVERWRITE_EXISTING_FIELDS=true				# If true, update fields in the CFG file with new information in they already exists.		
CREDENTIALS=								# Screenscraper.fr credentials in username:password format. Leave empty for anonymous.
WORK_DIR_PATH=${PWD}						# Location of the work folder to be used by the script.
WORK_DIR_NAME=work_dir						# Name of the work folder to be used by the script.

# Script internal variables (do not touch)
GAMELIST_FILE=gamelist.xml					# the name of the gamelist file created by SkyScraper to be parsed by the script.
WORK_DIR=${WORK_DIR_PATH}/${WORK_DIR_NAME}

# Functions

# arg1: destination folder
function setup () {
	if [[ -n ${1} ]]; 
    then 
         mkdir -p ${1}
    fi

	if [[ -e ${WORK_DIR} ]]; 
    then 
         rm -rf ${WORK_DIR}
    fi
    
    mkdir -p ${WORK_DIR}
}

# arg1: A .cfg file to extract 
function get_game_name_from_cfg_file () {
	local IFS="="
	while read -r key value; do
		if [[ "$key" == "Title" ]]; then
			# Also remove Windows carriage returns, in case the CFG is coming from Windows
			echo "${value}" | tr -d '\r'
			break
		fi
	done < "${1}"
}

# arg1: Game list to process.
function is_game_list_empty () {
	[[ $(wc -l ${WORK_DIR}/${GAMELIST_FILE} | awk '{ print $1 }') -le 5 ]]
	return
}

# arg1: Name of the game to be scraped.
function fetch_game_info () {
	# Create a fake file to be scraped by SkyScraper
	FAKE_FILE_PATH="${WORK_DIR}/${1}.iso"
	echo $FAKE_FILE_PATH
	touch "${FAKE_FILE_PATH}"
	
	if [[ ! -z $CREDENTIALS ]] ; then
		CREDARG="-u ${CREDENTIALS}"
	fi 

	echo $CREDARG

	# Scrape the info, if not in the Skyscraper cache.
	if [[ "$FORCE_CACHE_ONLY" = false ]]; then
		Skyscraper -p ps2 -s screenscraper ${CREDARG} --nocovers --noscreenshots --nowheels --nomarquees --nobrackets --unattend -i ${WORK_DIR} "${FAKE_FILE_PATH}"
	fi
	
	# Generate 1-entry gamelist to save the info
	Skyscraper -p ps2 -f emulationstation --unattend -i ${WORK_DIR} -g ${WORK_DIR} 
	
	# Convert XML special characters into normal characters, e.g.
	# " from &quot;
	# ' from &apos;
	# < from &lt;
	# > from &gt;
	# & from &amp;
	# See https://stackoverflow.com/questions/5929492/bash-script-to-convert-from-html-entities-to-characters
	GAME_LIST_PATH="${WORK_DIR}/${GAMELIST_FILE}"
	sed -i.orig "s/&apos;/\'/g"  "${GAME_LIST_PATH}" # Take care of apostrophes first
	sed -i.orig 's/&nbsp;/ /g; s/&amp;/\&/g; s/&lt;/\</g; s/&gt;/\>/g; s/&quot;/\"/g; s/#&#39;/\'"'"'/g; s/&ldquo;/\"/g; s/&rdquo;/\"/g;' "${GAME_LIST_PATH}"
	# Remove fake file
	rm "${FAKE_FILE_PATH}"
}

# XML to .cfg fields conversion table
#
# 	desc 		-> Description
# 	players 	-> Players + PlayersText
# 	genre 		-> genre
# 	releasedate -> Release
# 	developer 	-> Developer
#	rating 		-> Rating + RatingText

# arg1: Original CFG file path
# arg2: Reworked CFG file path
function generate_cfg_from_original () {
	while read_dom; do	
		if [[ -z "${CONTENT}" ]]; then continue; fi
		
		if [[ $TAG_NAME = "desc" ]] ; then
			# Truncate description to max length defined above
			local SHORTENED_DESCR=${CONTENT:0:MAX_DESCR_LENGTH}
			
			# We may have truncated sentences in half, so keep the resulting text
			# up to the last period.
			SHORTENED_DESCR=$(echo ${SHORTENED_DESCR} | sed 's/\.[^.]*$//').
			
			set_field ${2} "Description" "${SHORTENED_DESCR}"
		elif [[ $TAG_NAME = "players" ]] ; then	
			set_field ${2} "Players" "players/${CONTENT}" STATS_NUM_PLAYERS
			set_field ${2} "PlayersText" "${CONTENT}"
		elif [[ $TAG_NAME = "genre" ]] ; then
			set_field ${2} "Genre" "${CONTENT}" STATS_NUM_GENRE
		elif [[ $TAG_NAME = "releasedate" ]] ; then
			# Format original string in MM/DD/YY format
			local YEAR=$(echo ${CONTENT} | cut -c1-4)
			local MONTH=$(echo ${CONTENT} | cut -c5-6)
			local DAY=$(echo ${CONTENT} | cut -c7-8)
			
			set_field ${2} "Release" "${MONTH}-${DAY}-${YEAR}"
		elif [[ $TAG_NAME = "developer" ]] ; then
			set_field ${2} "Developer" "${CONTENT}"
		elif [[ $TAG_NAME = "rating" ]] ; then
			STAR_RATING=$(awk -vc=$CONTENT 'BEGIN{printf "%.0f" ,c * 5}')
		
			set_field ${2} "Rating" "rating/${STAR_RATING}" STATS_NUM_PLAYERS
			set_field ${2} "RatingText" "${STAR_RATING}"
		fi
	done < ${WORK_DIR}/${GAMELIST_FILE}
}

# arg1: cfg file
# arg2: field name
# arg3: field value
function set_field () {
	local SHOULD_SET=true
	grep -Fq "$2=" "${1}"
	if [[ $? -eq 0 ]] ; then
		if $OVERWRITE_EXISTING_FIELDS ; then
			awk "!/${2}=/" "${1}" > temp && mv temp "${1}"
		else
			SHOULD_SET=false
		fi
	fi
	
	if $SHOULD_SET ; then
		echo "${2}=${3}" >> "${1}"
	fi
}

# from https://stackoverflow.com/questions/893585/how-to-parse-xml-in-bash
function read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
    local ret=$?
    TAG_NAME=${ENTITY%% *}
    ATTRIBUTES=${ENTITY#* }
    # Remove leading and trailing whitespaces from CONTENT.
    CONTENT=$(echo ${CONTENT} | awk '{$1=$1;print}')
    return $ret
}

print_usage () {
	echo -e "\n\nUsage:\n"
	echo -e "${0} <input CFG folder> <output CFG folder>\n\n"
}

# Main

if [[ "$#" -eq 0 ]]; then
	print_usage
	exit 0
else
	setup "${2}"
	for file in "${1}"/*
	do
		# Copy the current CFG file in the output directory
		cp "${file}" "${2}/$(basename ${file})"
	
		GAME_TO_PARSE=$(get_game_name_from_cfg_file ${file})
		fetch_game_info "${GAME_TO_PARSE}"
		
		if is_game_list_empty; then 
			echo "${GAME_TO_PARSE}" >> "${WORK_DIR}/${MISSING_GAMES_LIST_NAME}"
			continue
		else
			generate_cfg_from_original "${file}" "${2}/$(basename ${file})"
		fi
		
		rm ${WORK_DIR}/${GAMELIST_FILE}
	done
fi
