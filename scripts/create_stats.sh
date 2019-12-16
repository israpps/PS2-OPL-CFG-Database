print_usage () {
	echo -e "\n\nUsage:\n"
	echo -e "${0} <input CFG folder>\n\n"
}

# Main

if [[ "$#" -eq 0 ]]; then
	print_usage
	exit 0
else
    echo -e "Total CFG files          = " $(ls "${1}" | wc -l)
    echo -e "CFGs with Descriptions   = " $(grep -r "${1}" -e "Description=" | wc -l)
    echo -e "CFGs with Players info   = " $(grep -r "${1}" -e "PlayersText=" | wc -l)
    echo -e "CFGs with Genre info     = " $(grep -r "${1}" -e "Genre=" | wc -l)
    echo -e "CFGs with Release date   = " $(grep -r "${1}" -e "Release=" | wc -l)
    echo -e "CFGs with Developer info = " $(grep -r "${1}" -e "Genre=" | wc -l)
	echo -e "CFGs with Ratings        = " $(grep -r "${1}" -e "RatingText=" | wc -l)
fi