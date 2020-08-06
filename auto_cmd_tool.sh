#!/bin/bash

#######################################
###  Auto-Command-Tool				###
###  Version 2.1.4.28 beta			###
###  freeware						###
###  ©2020 suppenfritz				###
###  editor: Sublime Text3     		###
#######################################


# #####################################
# script - ToDo
# #####################################
#	[ X ] - func_menu_cmd_exec: include loop
#	[ X ] - sort functions 
#	[ X ] - include key's: POS1 & END, can't fix, putty $Term/xterm problem!
#	[ X ] - code: first clean out
#	[ X ] - release to beta tester
#	[ X ] - runtime: optimizing (replace external command's with bash included, eg.: let)
#	[  ] - code: clean out
#	[  ] - release
#	[  ] - 
#	[  ] - 


# #####################################
# global: options
# #####################################

# fix: asscii(graphic) utf8 handling
export NCURSES_NO_UTF8_ACS=1


# #####################################
# global: variables
# #####################################

# =====================================
# general:
# =====================================

# for function's: return values
G_FUNC_RET_VAL=""


# =====================================
# script-config: array
# =====================================

# declare: script config array
declare -A G_ARR_CONF

# header: script name
G_ARR_CONF['script_title']="Auto-Command-Tool"

# header: script version
G_ARR_CONF['script_version']="2.1.4.28 beta"

# header: script copyrights
G_ARR_CONF['script_copyrights']="©2020 suppenfritz"

# header: script informations
G_ARR_CONF['script_info']="${G_ARR_CONF[script_title]}(ACT) / Version: ${G_ARR_CONF['script_version']} / ${G_ARR_CONF['script_copyrights']}"


# =====================================
# file's / directory's: array
# =====================================

# directory: auto-command-tool: config
G_ARR_CONF['dir_config']="./conf/"

# file: auto-command-tool: settings
G_ARR_CONF['file_settings']="${G_ARR_CONF['dir_config']}settings.act"

# file: command file template
G_ARR_CONF['file_act_tpl']="${G_ARR_CONF['dir_config']}template.act"

# file: command file extension
G_ARR_CONF['file_act_ext']=".act"

# lock variable (read only)
declare -r G_ARR_CONF


# =====================================
# colors: array
# =====================================
declare -A G_COLORS
G_COLORS['red']="\e[91m"				# light red
G_COLORS['green']="\e[92m"				# light green
G_COLORS['yellow']="\e[93m"				# light yellow
G_COLORS['blue']="\e[94m"				# light blue
G_COLORS['magenta']="\e[95m"			# light magenta
G_COLORS['cyan']="\e[96m"				# light cyan
G_COLORS['dark_gray']="\e[90m"			# dark gray
G_COLORS['dark_orange']="\e[38;5;208m"	# orange
G_COLORS['orange']="\e[38;5;214m"		# light orange
G_COLORS['steelblue']="\e[38;5;39m"		# steel blue
G_COLORS['purple']="\e[38;5;5m"			# purple
G_COLORS['clear']="\033[0m"				# reset color to default
declare -r G_COLORS						# lock variable (only readable)


# =======================================
# act-file: general confirm description's
# =======================================
declare -A G_ARR_GENERAL_CONFIRM_DESC
G_ARR_GENERAL_CONFIRM_DESC['true']="Confirm execution all command's \Z1(ignore command_X:confirm)\Zn"
G_ARR_GENERAL_CONFIRM_DESC['false']="Don't confirm execution all command's \Z1(ignore command_X:confirm)\Zn"
G_ARR_GENERAL_CONFIRM_DESC['cmd']="Confirm execution only command's \Z1if command_X:confirm = true\Zn"
# set: only readable
declare -r G_ARR_GENERAL_CONFIRM_DESC


# ==================================================
# default settings
# ==================================================

# directory: act-command-files
# can be changed in menu settings
G_DIR_ACT_FILES="./act_files/"

# directory: backup: auto-command-files
# can be changed in menu settings
G_DIR_ACT_FILES_BKP="./act_files_bkp/"


# ####################################################################################################
# + + +   DEBUGGING   + + +
# ####################################################################################################

# this line will be enable script debugging
# set -xv

# debug: call func_debugging in func_main if true
G_DEBUG="false"

# ==================================================
# general debugging function's
# ==================================================

# debug: function debugging, call in menu main
func_debugging() {
	# function for debugging
	# check isset debugging
	if [ "${G_DEBUG}" = "false" ]; then
		return
	fi	

	# uncomment next row for disable
	clear

	func_msgbox "DEBUG" "test colors\n\n Colors_reverse=\Z1Zr\Zn[ \Zr\Z00\Z11\Z22\Z33\Z44\Z55\Z66\Z77\Zn\ZR ]...\Z1Zn\Zn"

	func_msgbox "DEBUG" "\Zr\Z2\Zr\Z7test color green\ZR"


	return
	# debug string escape to write ini value
	# "$(printf '%s' "$string" | sed 's/[.[\*^$()+?{|]/\\&/g')"
	local TMP="test1 && test2 || test3 ++ Alles -- tesATt /install_manager/. {kl} [eck] te*st =ende"
	# local RES="$(printf '%s' "$TMP" | sed 'sA[.[\*^$()+?{|&]A\\&Ag')"
	# local RES="$(printf '%s' "$TMP" | sed 'sA[[:punct:]]A\\&Ag')"
	local RES=$(func_str_regex_esc "$TMP")
	echo "resut: $RES"

	exit

	return
	
	# --form text height width formheight [ label y x item y x flen ilen ] ...

	# Store data to $VALUES variable
	# RES=$(dialog \
	# 	--backtitle "Linux User Managment" \
	# 	--title "Edit Command" \
	# 	--form "\ZUSelected-Config-File:\Zu config-file\n\n\ZUSelected command:\Zu [command_1] " 35 120 0 \
	# 	"Description (short):"	1 1	"$user"		1 10 10 0 \
	# 	"Description (long):"	2 1	"$shell"	2 10 15 0 \
	# 	"CLI-Command:"			3 1	"$groups"	3 10 8 0 \
	# 	"HOME:"					4 1	"$home"		4 10 40 0 \
	# 	3>&1 1>&2 2>&3)
	RES=$(dialog \
		--backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors \
		--title "Edit Command" \
		--ok-label "Save" --extra-button --extra-label "Delete Command" \
		--form "\n\ZuSelected-Config-File:\ZU \Z4config-file\Zn\n\n\ZuSelected command:\ZU \Z4[command_1]\Zn\n\nChange value's for selected command:" 16 100 0 \
		"Description (short, for menu's):"	1 1	"$user"		1 35 58 100 \
		"Description (long, for info's):"	2 1	"$shell"	2 35 58 300 \
		"CLI-Command:"						3 1	"$groups"	3 35 58 300 \
		3>&1 1>&2 2>&3)
	RET=$?
	if [ $RET -eq 0 ]; then
		# button: OK
		func_msgbox "DEBUG" "result:\n${RES}"
	elif [ $RET -eq 3 ]; then
		# button: extra-button: delete
		func_msgbox_yn "DEBUG" "\Z1Would you like delete follow selceted command ?\n\n\ZuSelected-Command:\ZU [command_1]\Zn"
		if [ $G_FUNC_RET_VAL -eq 0 ]; then
			func_msgbox "DEBUG" "DELETE command successfully!"
		fi
	else
		# button cancel or error
		func_msgbox "ERROR" "CANCEL or ERROR!"
	fi

	exit

	func_cfg_ini_read
}

# debug: print variable
# $1=type[str,arr], $2=description, $3=variable
func_debug_var() {
	
	local TMP_ARR
	local DEBUG_START="\n${G_COLORS['yellow']}--- debug - start: ------------------------------"
	local DEBUG_END="${G_COLORS['yellow']}--- debug - end ---------------------------------${G_COLORS['clear']}\n"
	
	# print: debug start message
	echo -e "${DEBUG_START}"

	# echo "arr - count: ${#G_DEBUG_ARR}"

	# check parameters, if p1 or p2 empty cancel
	# if [ -z $P1 ] || [ -z $P2 ] || [ -z $P3 ]; then
	if [ "${#G_DEBUG_ARR}" -lt 3 ]; then
		echo -e "${G_COLORS['red']}   requiered array(G_FUNC_DEBUG_ARR) empty or false format !!\n   you must set 'G_FUNC_DEBUG_ARR' before call function!\n   format:\n   INDEX 0: TYPE[str|arr]\n   INDEX 1: DESCRIPTION\n   INDEX 3..n: VALUES (seperator='|')\n${DEBUG_END}"
		# reset global array
		G_FUNC_DEBUG_ARR=()
		# exit function
		return 1
	fi

	local IFS_OLD="${IFS}"
	IFS='|' read -a TMP_ARR <<< $1
	IFS="${IFS_OLD}"


	# convert arguments to array
	for (( i = 0; i < "${#TMP_ARR[@]}"; i++ )); do
		echo "index: $i / val: ${TMP_ARR[$i]}"
	done

	return

	# check: if type array
	if [ "$P1" = "arr" ]; then
		# escape first two parameters
		shift
		shift
		# loop: get rest of parameters
		while $# -gt 0; do
    		echo $1; shift
    	done
	fi

	# print: arguments
	echo -e "   ${G_COLORS['yellow']}Parameters:  arg 1:${G_COLORS['clear']} $1${G_COLORS['yellow']} / arg 2:${G_COLORS['clear']} $2${G_COLORS['yellow']} / arg 3:${G_COLORS['clear']} $3"

	# check var-type [str,arr]
	if [ "${P1}" = "arr" ]; then
		# array
		# string
		echo -e "   ${G_COLORS['yellow']}Variable - ${G_COLORS['blue']}TYPE  :${G_COLORS['clear']} ${P1}"
		echo -e "   ${G_COLORS['yellow']}Variable - ${G_COLORS['blue']}DESC  :${G_COLORS['clear']} ${P3}"
		echo -e "   ${G_COLORS['yellow']}ARRAY - ${G_COLORS['blue']}LENGTH   :${G_COLORS['clear']} ${#P2[@]}"
		for (( i = 0; i < "${#P2[@]}"; i++ )); do
			echo -e "   ${G_COLORS['yellow']}ARRAY ${G_COLORS['orange']}[$i]${G_COLORS['blue']} :${G_COLORS['clear']} ${P2[$i]}"
		done
	else
		# string
		echo -e "${G_COLORS['yellow']}Variable - ${G_COLORS['orange']}TYPE  :${G_COLORS['clear']} ${P1}"
		echo -e "${G_COLORS['yellow']}Variable - ${G_COLORS['orange']}DESC  :${G_COLORS['clear']} ${P3}"
		echo -e "${G_COLORS['yellow']}Variable - ${G_COLORS['orange']}VALUE :${G_COLORS['clear']} ${P2}"
	fi

	# print: debug close message
	echo -e "${DEBUG_END}"
}

# debug: print array data
# parameters: $1=array (format: "${array[@]}")
func_debug_array() {
	# variables
	# convert parameter 1 to array, split by row-end's($)
	local TMP_ARR=( "$@" )

	# get array length
	local ARR_LEN="${#TMP_ARR[@]}"
	# set message header
	local MSG="\Z1\ZuARRAY - Info's:\ZU\Zn\n\n\Z4Length:\Zn ${ARR_LEN}\n\n\Z4Value's:\Zn\n\n"

	# array loop
	for (( i = 0; i < "${ARR_LEN}"; i++ )); do
		MSG+="index($i): ${TMP_ARR[$i]}\n"
	done

	# print message box
	func_msgbox "DEBUG" "${MSG}"
}

# debug: print variable
# $1=variable, $2=description $3=type[default:string(or any other type exept array)|array(convert by default delimiter='\n')]
func_debug_val() {
	
	# declare -p $1
	local TEMP1=$1
	local TEMP2=$2
	local TEMP3=$3
	local DEBUG_START="\n${G_COLORS['yellow']}--- debug - start: ------------------------------"
	local DEBUG_END="${G_COLORS['yellow']}--- debug - end ---------------------------------${G_COLORS['clear']}\n"
	
	# debug start message
	echo -e "${DEBUG_START}"

	# arguments
	echo -e "${G_COLORS['yellow']}arg 1:${G_COLORS['clear']} $1"
	echo -e "${G_COLORS['yellow']}arg 2:${G_COLORS['clear']} $2"
	echo -e "${G_COLORS['yellow']}arg 3:${G_COLORS['clear']} $3"
	echo -e "${G_COLORS['yellow']}arg 4:${G_COLORS['clear']} $4"
	echo -e "${G_COLORS['yellow']}arg 5:${G_COLORS['clear']} $5"
	echo -e "${G_COLORS['yellow']}arg 6:${G_COLORS['clear']} $6"
	echo -e "${G_COLORS['yellow']}arg 7:${G_COLORS['clear']} $7"
	echo -e "${G_COLORS['yellow']}arg 8:${G_COLORS['clear']} $8"
	echo -e "${G_COLORS['yellow']}arg 9:${G_COLORS['clear']} $9"

	# check var-type, if empty, set default to string
	if [ "${TEMP3}" = "" ]; then
		TEMP3="STRING"
	fi

	echo "array - length: ${#TEMP1[@]}"
	echo "array 0: ${TEMP1[0]}"
	echo "array 1: ${TEMP1[1]}"
	echo "string: ${TEMP1}"

	# check variable type
	if [ "${#TEMP1[@]}" -gt "1" ]; then
	# if [ "${TEMP3}" = "array" ]; then
		# array
		echo -e "${G_COLORS['yellow']}description:${G_COLORS['clear']} ${TEMP2}\n${G_COLORS['yellow']}type:${G_COLORS['clear']} ARRAY\n${G_COLORS['yellow']}length:${G_COLORS['clear']} ${#TEMP1[@]}\n${G_COLORS['yellow']}values:${G_COLORS['clear']}\n"
		for (( i = 0; i < "${#TEMP1[@]}"; i++ )); do
			echo "${G_COLORS['yellow']}array[$i]:${G_COLORS['clear']} ${TEMP1[$i]}"
		done
	else
		# string
		echo -e "${G_COLORS['yellow']}description:${G_COLORS['clear']} ${TEMP2}\n${G_COLORS['yellow']}type:${G_COLORS['clear']} STRING\n${G_COLORS['yellow']}value:${G_COLORS['clear']}\n${TEMP1}"
	fi

	# check input is epmty
	if [ "${TEMP1}" = "" ]; then
		echo -e "${G_COLORS['yellow']}description:${G_COLORS['clear']} ${TEMP2}\n${G_COLORS['yellow']}type:${G_COLORS['clear']} ${TEMP3}\n${G_COLORS['yellow']}value:${G_COLORS['red']} EMPTY!${G_COLORS['clear']}"
	fi

	# debug close message
	echo -e "${DEBUG_END}"
}


# ####################################################################################################
# function's - general / tools
# ####################################################################################################

# menu: dialog: message box
# param: 1:title, 2:message, 3:height, 4:width, 5:only title
func_msgbox() {
	
	# block scrolling
	clear

	# variables
	local P1 # header title
	local P2 # message text
	local P3 # height [rows]
	local P4 # width [chars]
	local P5 # header title: only return $1 value

	# check input
	[ "$1" = "" ] && P1="\Z0 ${G_ARR_CONF['script_title']} - \Z4Information \Zn" || P1="\Z0 ${G_ARR_CONF['script_title']} - \Z4$1 \Zn"
	[ "$1" = "ERROR" ] && P1="\Z0 ${G_ARR_CONF['script_title']} - \Z1ERROR \Zn"
	[ "$2" = "" ] && P2="no message set!" || P2=$2
	[ "$3" = "" ] && P3="0" || P3=$3
	[ "$4" = "" ] && P4="0" || P4=$4
	[ "$5" = "1" ] && P1="$1"

	# print dialog message box
	dialog --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --title "${P1}" --msgbox "\n$P2\n\n" $P3 $P4
}

# menu: dialog: message box[yes,no]
# param: 1:title, 2:message, 3:height, 4:width
func_msgbox_yn() {
	
	# block scrolling
	clear

	# variables
	local P1 # header title
	local P2 # message text
	local P3 # height [rows]
	local P4 # width [chars]
	local P5 # header title: only return $1 value
	local BTN_OK_LBL="Yes" # default button OK label
	local BTN_NO_LBL="No" # default button CANCEL label

	# check input
	# [ "$1" = "" ] && P1="\Z0 ${G_ARR_CONF['script_title']} \Zn" || P1="\Z0 ${G_ARR_CONF['script_title']} - \Z4$1 \Zn"
	[ "$1" = "" ] && P1="\Z0 ${G_ARR_CONF['script_title']} \Zn" || P1="$1"
	[ "$2" = "" ] && P2="no message set!" || P2=$2
	[ "$3" = "" ] && P3="10" || P3="$3"
	[ "$4" = "" ] && P4="70" || P4="$4"
	[ "$5" = "1" ] && P1="\Z0 $1 \Zn"
	# for menu backup restore: set button values
	if [ "$6" = "restore" ]; then
		BTN_OK_LBL="Restore"
		BTN_NO_LBL="Cancel"		
	fi

	# print dialog message box
	# --yesno text height width
	dialog --backtitle "${G_ARR_CONF['script_info']}" --colors --title "$P1" --yes-label "${BTN_OK_LBL}" --no-label "${BTN_NO_LBL}" --defaultno --yesno "\n${P2}" $P3 $P4

	# check result
	if [ $? -eq 0 ]; then
		# true
		G_FUNC_RET_VAL="0"
	else
		# false
		G_FUNC_RET_VAL="1"
	fi
}

# menu: dialog: information box
# param: 1:title, 2:message, 3:height, 4:width
func_infobox() {

	# block scrolling
	clear

	# variables
	local P1 # header title
	local P2 # message text
	local P3 # height [rows]
	local P4 # width [chars]

	# check input
	[ "$1" = "" ] && P1="\Z0 ${G_ARR_CONF['script_title']} - \Z4Information \Zn" || P1="\Z0 ${G_ARR_CONF['script_title']} - \Z4$1 \Zn"
	[ "$1" = "ERROR" ] && P1="\Z0 ${G_ARR_CONF['script_title']} - \Z1ERROR \Zn"
	[ "$2" = "" ] && P2="no message set!" || P2=$2
	[ "$3" = "" ] && P3="0" || P3=$3
	[ "$4" = "" ] && P4="0" || P4=$4

	# print dialog info box
	dialog --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --title "${P1}" --infobox "\n$P2\n\n" $P3 $P4
}

# menu: dialog: input box
# param: 1:title, 2:message, 3: default value 4:height, 5:width
func_inputbox() {
	
	# variables
	local P1 # header title
	local P2 # message text
	local P3 # default value
	local P4 # height [rows]
	local P5 # width [chars]

	# check arguments
	[ "$1" = "" ] && P1="\Z0 ${G_ARR_CONF['script_title']} - \Z4Input \Zn" || P1="\Z0 $1 \Zn"
	[ "$2" = "" ] && P2="no message set!" || P2=$2
	[ "$3" = "" ] && P3="" || P3=$3
	[ "$4" = "" ] && P4="0" || P4=$4
	[ "$5" = "" ] && P5="0" || P5=$5

	# print dialog input box
	dialog --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --ok-button "OK" --cancel-button "Cancel" --defaultno --title "${P1}" --inputbox "\n$P2\n\n" "${P4}" "${P5}" "${P3}"  3>&1 1>&2 2>&3
}

# menu: dialog: menu box: true/false
# param: 1:title, 2:text, 3:height, 4:width
func_menubox_tf() {
	
	# variables
	local P1 # header title
	local P2 # message text
	local P3 # height [rows]
	local P4 # width [chars]

	# check input
	[ "$1" = "" ] && P1="\Z4${G_ARR_CONF['script_title']} - Menu" || P1="$1"
	[ "$2" = "" ] && P2="no message set!" || P2=$2
	[ "$3" = "" ] && P3="0" || P3=$3
	[ "$4" = "" ] && P4="0" || P4=$4

	# dialog
	dialog --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --cancel-label "Cancel" --defaultno --title "${P1}" \
	--menu "\n${P2}" "${P3}" "${P4}" 2 \
	"1" "FALSE" \
	"2" "TRUE" \
	3>&1 1>&2 2>&3
}

# menu: dialog: menu box: true/false/cmd, for setting: ACT-file:general: confirm
# param: 1:title, 2:text, 3:height, 4:width
func_menubox_tfc() {
	
	# variables
	local P1 # header title
	local P2 # message text
	local P3 # height [rows]
	local P4 # width [chars]

	# check input
	[ "$1" = "" ] && P1="\Z4${G_ARR_CONF['script_title']} - Menu" || P1="$1"
	[ "$2" = "" ] && P2="no message set!" || P2=$2
	[ "$3" = "" ] && P3="0" || P3=$3
	[ "$4" = "" ] && P4="0" || P4=$4

	# dialog
	dialog --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --cancel-label "Cancel" --defaultno --title "${P1}" \
	--menu "\n${P2}" "${P3}" "${P4}" 3 \
	"1" "FALSE (don't confirm all, ignore act-file:command_X:confirm)" \
	"2" "TRUE (confirm all, ignore act-file:command_X:confirm)" \
	"3" "CMD (confirm, only if act-file:command_X:confirm=TRUE)" \
	3>&1 1>&2 2>&3
}

# string: escape string for regex
# param: 1:variable
func_str_regex_esc() {
	
	# variables
	local RES
	local P1="$1"
	
	# string: escape(special-chars) for regex
	if [ -n "${P1}" ]; then
		# escape string
		RES="$(printf '%s' "${P1}" | sed 'sA[[:punct:]]A\\&Ag')"
	fi
	
	# return: result
	echo "$RES"
}

# dialog: generate menu path for header
# param: $1-$9: variable
func_menu_header_path() {
	
	# variables
	local RES="\Z7 ACT-Path:"
	local SEP=" >>"
	
	# string: escape(special-chars) for regex
	[ -n "${1}" ] && RES+="  $1"
	[ -n "${2}" ] && RES+="$SEP $2"
	[ -n "${3}" ] && RES+="$SEP $3"
	[ -n "${4}" ] && RES+="$SEP $4"
	[ -n "${5}" ] && RES+="$SEP $5"
	[ -n "${6}" ] && RES+="$SEP $6"
	[ -n "${7}" ] && RES+="$SEP $7"
	[ -n "${8}" ] && RES+="$SEP $8"
	[ -n "${9}" ] && RES+="$SEP $9"

	# set color ending
	RES+=" \Zn"
	
	# return: result
	echo "${RES}"
}

# function: split string to array with delimiter
# param: $1=delimiter_id(1: ' ', 2: '\n'), $2=string
func_str_to_array() {
	
	# variables
	local TMP_DELIMITER="$1"
	local TMP_STRING="$2"
	local TMP_ARR
	local IFS_OLD

	# check parameter 1 and 2
	if [ "${TMP_DELIMITER}" = "" ] || [ "${TMP_STRING}" = "" ]; then
		# error
		return 1
	elif [ "${TMP_DELIMITER}" = "1" ]; then
		# delimiter id = space, set global return variable
		IFS_OLD="${IFS}"
		IFS=$' ' G_FUNC_RET_VAL=($TMP_STRING)
	elif [ "${TMP_DELIMITER}" = "2" ]; then
		# delimiter id = new row, set global return variable
		IFS_OLD="${IFS}"
		IFS=$'\n' G_FUNC_RET_VAL=(${TMP_STRING})
	fi

	# reset IFS
	IFS="${IFS_OLD}"
}


# ####################################################################################################
# function's - ini-file
# ####################################################################################################
# Help
# ####################################################################################################

# Here is my command "cheat-sheet"

# :  # label
# =  # line_number
# a  # append_text_to_stdout_after_flush
# b  # branch_unconditional
# c  # range_change
# d  # pattern_delete_top/cycle
# D  # pattern_ltrunc(line+nl)_top/cycle
# g  # pattern=hold
# G  # pattern+=nl+hold
# h  # hold=pattern
# H  # hold+=nl+pattern
# i  # insert_text_to_stdout_now
# l  # pattern_list
# n  # pattern_flush=nextline_continue
# N  # pattern+=nl+nextline
# p  # pattern_print
# P  # pattern_first_line_print
# q  # flush_quit
# r  # append_file_to_stdout_after_flush
# s  # substitute
# t  # branch_on_substitute
# w  # append_pattern_to_file_now
# x  # swap_pattern_and_hold
# y  # transform_chars

# Möchte man die Ersetzungen nur in einem bestimmten Bereich, beispielsweise zwischen zwei Zeilennummern, vornehmen, so ist eine Bereichsangabe unmittelbar zu Beginn der sed-Anweisung möglich. Diese kann aus einer einzelnen Adresse oder auch zwei Adressen, die einen Bereich markieren, bestehen:

# # In der Zeile 5 "alt" durch "neu" ersetzen:
# 5s/alt/neu/g

# # In den Zeilen 10-30 "alt" durch "neu" ersetzen:
# 10,30s/alt/neu/g
# Bei einer Bereichsangabe kann auch eine der beiden Adressen weggelassen werden, um eine Ersetzung vom Anfang des Textes bis zu einer beziehungsweise ab einer gegebenen Stelle bis zum Ende des Textes zu erreichen:

# # Ab Zeile 10 "alt" durch "neu" ersetzen:
# 10,s/alt/neu/g

# # Bis Zeile 30 "alt" durch "neu" ersetzen:
# ,30s/alt/neu/g
# Bereichsangaben können durch ein angefügtes Ausrufezeichen (!) umgekehrt werden. Die Anweisung bezieht sich dann auf alle Zeilen, die außerhalb der Bereichsangabe liegen:

# # In allen Zeilen außer 10-30 "alt" durch "neu" ersetzen:
# 10,30!s/alt/neu/g
# Anstelle von Zeilenangaben können Adressen auch aus Suchmustern bestehen, die ebenfalls zwischen zwei Schrägstrichen angegeben werden:

# # In allen Zeilen, die "total" enthalten, alt" durch "neu" ersetzen:
# /total/s/alt/neu/g

# # Zwischen "START" und "END" alle Vorkommnisse von alt" durch "neu" ersetzen:
# /START/,/END/s/alt/neu/g

# ########################

# #  List all [sections] of a .INI file

# sed -n 's/^[ \t]*\[\(.*\)\].*/\1/p'

# #  Read KEY from [SECTION]

# sed -n '/^[ \t]*\[SECTION\]/,/\[/s/^[ \t]*KEY[ \t]*=[ \t]*//p'

# #  Read all values from SECTION in a clean KEY=VALUE form

# sed -n '/^[ \t]*\[SECTION\]/,/\[/s/^[ \t]*\([^#; \t][^ \t=]*\).*=[ \t]*\(.*\)/\1=\2/p'

# # examples:

# sed -n 's/^[ \t]*\[\(.*\)\].*/\1/p' /etc/samba/smb.conf
# sed -n '/^[ \t]*\[global\]/,/\[/s/^[ \t]*workgroup[ \t]*=[ \t]*//p' /etc/samba/smb.conf
# sed -n '/^[ \t]*\[global\]/,/\[/s/^[ \t]*\([^#; \t][^ \t=]*\).*=[ \t]*\(.*\)/\1=\2/p' /etc/samba/smb.conf

# Set an option. Range limit from section to start of next section, then traditional s// to switch option

# sed -i '/\[SECTION\]/,/\[/ s/(.*enabled.* =.*)no/\1yes/' /etc/your/ini.file


# Sonderzeichen

# Zeichen	Hinweis Sed-Funktionalität
# (	öffnet eine Anweisung
# )	schließt die Anweisung
# {	öffnet optionale Anweisung
# }	schließt optionale Anweisung
# [	öffnet Klassenbeschreibung von Zeichen
# ]	schließt Klassenbeschreibung von Zeichen
# "	maskiert Anweisung und löst Shell-Variable auf
# '	maskiert eine Anweisung, löst Shell-Variable nicht auf
# `	schließt Anweisungsblock ein
# .	ein beliebiges Zeichen außer Zeilenvorschub
# ,	trennt Parameter, etwa Zeilenangaben
# Leerzeichen	Setzt Markierung (t– und b-Befehl)
# $	Dokumentenende, letzte Zeile oder Zeilenende
# &	Platzhalter für Suchmuster, welches in der Ersetzen-Anweisung mit ausgegeben wird
# |	oder (Abtrennen von regulären Ausdrücken)
# /	Trennzeichen in Editierkommandos
# ^	Anfang der Zeile, aber: [^Begriff] = Negierung
# \	Entwerter
# !	nach Zeilenzahl: nicht diese Zeile ausgeben
# *	nie oder beliebig oft
# +	Muster mindestens einmal vorhanden
# =	Ausgabe der Zeilennummer
# \n	neue Zeile, Zeilenvorschub
# \t	Tabulator

# # Löscht die ersten 10 Zeilen einer Datei
# sed '1,10d'

# # Lösche Zeilen die die Regex erfüllen
# sed '/pattern/d'

# get row number by regex
# sed -n '/^\[command_1\]/=' ./07_raspi_test.imconf
# sed -n '/^\[command_1\]/=' ./07_raspi_test.imconf

# ####################################################################################################

# function: handle ini-file ------------------------------------
# param: $1:file-option[(r)ead|(w)rite|(d)elete], $2:section[string|all|cmd], $3:key[string|all], $4:value[string], $5:[array|string(default)]
# optimize: https://www.uninformativ.de/blog/postings/2010-08-19/0/POSTING-de.html
func_ini_file() {
	
	# variables
	local TEMP=""
	local INI_CMD=""

	# ini options
	# read: section - start
	if [ "${1}" = "r" ]; then
		if [ "${2}" = "all" ] && [ "${3}" = "" ] ; then
			# list all sections
			TEMP=$(sed -n 's/^[ \t]*\[\(.*\)\].*/\1/p' "${G_INI_FILE_SEL}")

		elif [ "${2}" = "cmd" ] && [ "${3}" = "" ] ; then
			# list all command's sections
			TEMP=$(sed -n 's/^[ \t]*\[\(command_.*\)\].*/\1/p' "${G_INI_FILE_SEL}")

		elif [ "${2}" = "all" ] && [ "${#3}" -gt "2" ]; then
			# read all values from given key in all section
			# generate regex for sed
			INI_CMD='' # reset
			INI_CMD='s/^[ \t]*'
			INI_CMD+="${3}"
			INI_CMD+='=[ \t]*\"\(.*\)\"/\1/p'

			# execute
			TEMP=$(sed -n "${INI_CMD}" "${G_INI_FILE_SEL}")

		elif [ "${#2}" -gt "2" ] && [ "${3}" = "all" ]; then
			# read all values from given section
			# nfo: after comma, cycle: checked beginning line with '[' exit cycle !!
			# nfo: Selection-START,Selection-STOP/s/SEARCH/REPLACE/\2(2nd result)/p ([p]rint: return, no replace)
			# generate regex for sed
			INI_CMD='' # reset
			INI_CMD='/^[ \t]*\['
			INI_CMD+="${2}"
			INI_CMD+='\]/,/\[/s/^[ \t]*\([^#; \t][^ \t=]*\).*=[ \t]*\"\(.*\)\"/\2/p'

			# execute
			TEMP=$(sed -n "${INI_CMD}" "${G_INI_FILE_SEL}")

		elif [ "${#2}" -gt "2" ] && [ "${3}" = "allkey" ]; then
			# read all values from section in a clean KEY=VALUE form
			# nfo: after comma, cycle: checked beginning line with '[' exit cycle !!
			# generate regex for sed
			INI_CMD='' # reset
			INI_CMD='/^[ \t]*\['
			INI_CMD+="${2}"
			INI_CMD+='\]/,/\[/s/^[ \t]*\([^#; \t][^ \t=]*\).*=[ \t]*\"\(.*\)\"/\1=\2/p'

			# execute
			TEMP=$(sed -n "${INI_CMD}" "${G_INI_FILE_SEL}")

		elif [ "${#2}" -gt "2" ] && [ "${#3}" -gt "2" ]; then
			# read value from given section($2) and key($3)
			# nfo: after comma, cycle-stop: checked beginning line with '[' exit cycle !!
			# generate regex for sed
			INI_CMD='' # reset
			INI_CMD='/^[ \t]*\['
			INI_CMD+="${2}"
			INI_CMD+='\]/,/\[/s/^[ \t]*'
			INI_CMD+="${3}"
			INI_CMD+='[ \t]*=[ \t]*\"\(.*\)\"/\1/p'

			# execute
			TEMP=$(sed -n "${INI_CMD}" "${G_INI_FILE_SEL}")

		fi

		# check: output format array
		if [ "${5}" = "array" ]; then
			# convert returned string to array
			# reset global function return value
			G_FUNC_RET_VAL=()

			# convert result to global array, choose IFS
			local IFS_OLD="${IFS}"
			IFS=$'\n' G_FUNC_RET_VAL=( $TEMP )
			IFS="${IFS_OLD}"

		else
			# return result: string
			echo "${TEMP}"
		fi
	# read: section - end

	# write: section - start
	elif [ "${1}" = "w" ]; then
		# args: $1=file-option[(w)rite|(cmd_ren)], $2=write-option[cmd_ren,val], $3=section $4=key, $5=value

		if [ "${2}" = "cmd_ren" ] && [ -n "${3}" ] && [ -n "${4}" ]; then
			# rename command sections with new count, when delete section

			# generate regex for sed
			INI_CMD='' # reset
			INI_CMD='s/^\['
			INI_CMD+="${3}"
			INI_CMD+='\]/\['
			INI_CMD+="${4}"
			INI_CMD+='\]/'

			# execute
			TEMP=$(sed -i "${INI_CMD}" "${G_INI_FILE_SEL}")

		elif [ "${2}" = "val" ] && [ "${#3}" -gt "2" ] && [ "${#4}" -gt "2" ]; then
			# ini-file: write new value to given key
			# check value, if not empty: escape special char's (regex-group: [:punct:], sep:A) char's 
			
			# variables
			local VAL_ORI="0"
			local VAL_ESCAPE

			if [[ -n "${5}" ]]; then
				# check value: if special character 'A' seperator exist
				if [[ "${5}" =~ "A" ]]; then
					func_msgbox "ERROR" "\Z1Character 'A' (uppercase) doesn't allowd in value!\Zn"
					return 1
				fi

				# value: escape
				VAL_ORI="${5}"
				VAL_ESCAPE=$(func_str_regex_esc "${VAL_ORI}")

			else
				# reset
				VAL_ESCAPE=""
			fi

			# format: ini-command: change: sed ( cmd: /search-range[start,stop]/[s]ubstitute/search-pattern/replace-pattern(escaped) )
			INI_CMD='/^[ \t]*\['
			INI_CMD+="${3}"
			INI_CMD+='\]/,/\[/s/^[ \t]*'
			INI_CMD+="${4}"
			INI_CMD+='=\".*\"/'
			INI_CMD+="${4}"
			INI_CMD+='=\"'
			INI_CMD+="${VAL_ESCAPE}"
			INI_CMD+='\"/'

			# ini-file: write new value
			TEMP=$( sed -i "${INI_CMD}" "${G_INI_FILE_SEL}" )

		else
			# ERROR
			func_msgbox "ERROR" "\Z1FUNC_INI_FILE: False input or argument(s) EMPTY!\Zn"
		fi
	# write: section - end

	# delete: section -start
	elif [ "${1}" = "d" ]; then
		# args: $1=file-option[(r)ead|(w)rite|(d)elete], $2=section

		# check: for right input (regex: [sections_(nr{min,max}])
		if [[ "${2}" =~ ^command_[0-9]{1,3}$ ]]; then
			# delete: given section from ini file, true
			
			# set cmd: delete selected section
			INI_CMD='/^\['
			INI_CMD+="${2}"
			INI_CMD+='\]/,/confirm/d'

			# execute: delete found row (regex)
			TEMP=$(sed -i "${INI_CMD}" "${G_INI_FILE_SEL}")

			# set cmd: delete empty double row's
			INI_CMD='N;/^\n$/D;P;D;'

			# execute: clean up file for empty double row's
			local TEMP2=$(sed -i "${INI_CMD}" "${G_INI_FILE_SEL}")

			# check: result and return
			if [[ -z "${TEMP}" ]] && [[ -z "${TEMP2}" ]]; then
				# retrun: true
				echo "true"
			else
				# debug
				# func_msgbox "DEBUG - delete" "res: false\n\ntemp: ${TEMP}\n\ntemp1: ${TEMP1}"

				# retrun: false
				echo "false"
			fi
			# debug
			# func_msgbox "DEBUG" "delete\n\nres: ${TEMP}"

		else
			# error
			func_msgbox "ERROR" "\Z1False input or Argument(s) EMPTY!\Zn"
		fi
	fi
	# delete: section end
}


# ####################################################################################################
# menu: main
# ####################################################################################################

# ==================================================
# function's - general
# ==================================================

# ==================================================
# function's - menu
# ==================================================

# menu: dialog: init
func_menu_init() {
	
	# block scrolling
	clear

	# variables
	local DLG_MSG="Hello,\n\nthis tool makes it easier for you to execute system command's or install/uninstall package's automatically by using configuration-file's\Z4(*${G_ARR_CONF['file_act_ext']})\Zn in directory: \Z1${G_DIR_ACT_FILES}\Zn !\n\n\Z1Note: use it with any sudo-user!\Z4\n\nTipp's:\n - Use it in half/full screen mode!\n - Tabstop-Key's: <TAB> & <CURSORS>\Zn / \Z1Don't use Key's: <POS1> & <END> !\n\Z4 - Putty-Settings: enable Keyboard Num-Pad:\n - - Category => Terminal => Futures => CHECK (disable application keypad mode)"

	# dialog
	func_msgbox "INFO" "$DLG_MSG" 18 100
}

# menu: dialog: main
func_menu_main() {
	
	# dialog: init - welcome message
	func_menu_init

	# settings: init: load settings from setting-file
	# param: 1=init(display message loaded)
	func_settings_init "init"

	# call: debug function, only execute if G_DEBUG=true
	func_debugging

	# variables
	local RES
	local RET

	# variables
	local DLG_TITLE=$(func_menu_header_path "Main")
	local DLG_MSG_TITLE="\n\ZuMenü: Main\ZU\n\n"
	local DLG_MSG=""
	local DLG_MSG_CHOICE_TITLE="Choose entry ?"
	local DLG_HEIGHT=25
	local DLG_WIDTH=100
	local DLG_HEIGHT_CHOICE=11

	# loop: main
	while true; do
		# block scrolling
		clear

		# dialog: main
		RES=$(dialog \
			--backtitle "${G_ARR_CONF['script_info']}" --title "${DLG_TITLE}" \
			--cr-wrap --colors \
			--ok-label "Choose" --cancel-label "Exit Script"\
			--menu "${DLG_MSG_TITLE}${DLG_MSG}${DLG_MSG_CHOICE_TITLE}" \
			$DLG_HEIGHT $DLG_WIDTH $DLG_HEIGHT_CHOICE \
			"1" "Menü: ACT-File's" \
			"2" "Menü: Setting's" \
			"3" "System: display information's" \
			"4" "System: package's - update" \
			"5" "System: package's - upgrade" \
			"6" "System: package's - update & upgrade" \
			"7" "System: package's - auto-clean (download archiv)" \
			"8" "System: package's - auto-remove (not used package's)" \
			"9" "System: \Z4REBOOT\Zn" \
			"10" "System: \Z1SHUTDOWN\Zn" \
			3>&1 1>&2 2>&3)

		# return data
		RET=$?

		# return check
		if [ $RET -eq 1 ]; then
			func_menu_exit
		elif [ $RET -eq 0 ]; then
			# func_menu_cmd_exec: $1[true,false]=question confirm, $2-$9=command's
			case "$RES" in
				1) func_menu_act_files;;
				2) func_menu_settings;;
				3) func_menu_cmd_exec "${G_ARR_SETTINGS[3]}" "${G_ARR_SETTINGS[4]}";;
				4) func_menu_cmd_exec "${G_ARR_SETTINGS[3]}" "${G_ARR_SETTINGS[5]}";;
				5) func_menu_cmd_exec "${G_ARR_SETTINGS[3]}" "${G_ARR_SETTINGS[6]}";;
				6) func_menu_cmd_exec "${G_ARR_SETTINGS[3]}" "${G_ARR_SETTINGS[5]}" "${G_ARR_SETTINGS[6]}";;
				7) func_menu_cmd_exec "${G_ARR_SETTINGS[3]}" "${G_ARR_SETTINGS[7]}";;
				8) func_menu_cmd_exec "${G_ARR_SETTINGS[3]}" "${G_ARR_SETTINGS[8]}";;
				9) func_menu_reboot "${G_ARR_SETTINGS[9]}";;
				10) func_menu_poweroff "${G_ARR_SETTINGS[10]}";;
			esac
		fi
	done
}


# ####################################################################################################
# menu: act-file's
# ####################################################################################################

# ==================================================
# function's - general
# ==================================================

# act-file's: get act-file-list from defined act-directory
func_get_act_files_list() {
	
	# variables
	local ARR_I=0
	local ARR_C=1
	local ARR_I2=1

	# global variables
	G_ARR_ACT_FILES_MENU=()
	G_ARR_ACT_FILES=()

	# set: format: act-file's
	local TMP="${G_DIR_ACT_FILES}*${G_ARR_CONF['file_act_ext']}"

	# set filename arrays, format menu array
	for i in `ls $TMP | sort`; do
		G_ARR_ACT_FILES_MENU[$ARR_I]=$ARR_C
		((ARR_C++))
		((ARR_I++))
		G_ARR_ACT_FILES_MENU[$ARR_I]=${i#$G_DIR_ACT_FILES}
		((ARR_I++))
		G_ARR_ACT_FILES[$ARR_I2]=${i#$G_DIR_ACT_FILES}
		((ARR_I2++))
	done
}

# act-file's: get act-file-backup-list from defined act-backup-directory
func_get_act_files_bkp_list() {
	
	# variables
	local ARR_I=0
	local ARR_C=1
	local ARR_I2=1

	# global variables
	G_ARR_ACT_FILES_BKP_MENU=()
	G_ARR_ACT_FILES_BKP=()

	# set: act-bkp-file's format
	local TMP="${G_DIR_ACT_FILES_BKP}*${G_ARR_CONF['file_act_ext']}"

	# set filename arrays, format menu array
	for i in `ls $TMP | sort`; do
		G_ARR_ACT_FILES_BKP_MENU[$ARR_I]=$ARR_C
		((ARR_C++))
		((ARR_I++))
		G_ARR_ACT_FILES_BKP_MENU[$ARR_I]=${i#$G_DIR_ACT_FILES_BKP}
		((ARR_I++))
		G_ARR_ACT_FILES_BKP[$ARR_I2]=${i#$G_DIR_ACT_FILES_BKP}
		((ARR_I2++))
	done
}

# ==================================================
# function's - menu - main
# ==================================================

# dialog: menu: act-command-files
func_menu_act_files() {

	# block scrolling
	clear

	# check act-file's directory
	if [ ! -d "${G_DIR_ACT_FILES}" ]; then
		# error message
		func_msgbox "ERROR" "\Z1ACT-file's directory not exist!\n\ndirectory: ${G_DIR_ACT_FILES}\Zn"

		# exit function
		return
	fi

	# get act-file-list from defined directory
	func_get_act_files_list

	# dialog: variables
	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's")
	local DLG_MSG_TITLE="\n\ZuMenü: ACT-File's\ZU\n\n"
	local DLG_MSG="Follow ACT-file's found in directory: \Z4${G_DIR_ACT_FILES}*${G_ARR_CONF['file_act_ext']}\Zn"
	local DLG_MSG_CHOICE_TITLE="\n\nChoose ACT-File ?\n\n"
	local DLG_HEIGHT=0
	local DLG_WIDTH=100
	local DLG_HEIGHT_2=15
	local ARR_MENU_ENTRYS=("1" "Show Information's" "2" "Execute (step 1 of 2)" "3" "Edit" "4" "Edit File (Editor)" "5" "Rename" "6" "Delete")

	# loop: menu
	while true; do

		local RET
		local RES

		RES=$( dialog \
			--backtitle "${G_ARR_CONF['script_info']}" \
			--title "${DLG_TITLE}" \
			--cr-wrap --colors --scrollbar \
			--extra-button --extra-label "New" \
			--ok-button "Choose" \
			--cancel-button "Back" \
			--scrollbar \
			--menu "${DLG_MSG_TITLE}${DLG_MSG}${DLG_MSG_CHOICE_TITLE}" $DLG_HEIGHT $DLG_WIDTH $DLG_HEIGHT_2 "${G_ARR_ACT_FILES_MENU[@]}" \
			3>&1 1>&2 2>&3 )

		# dialog: check return
		RET=$?

		if [ $RET -eq 0 ]; then
			# button: OK
			# check: result
			if [ "$RES" != "" ]; then
				# set global selected command-file
				G_ACT_FILE_SEL="${G_ARR_ACT_FILES[RES]}"
				G_ACT_FILE_SEL_PATH="${G_DIR_ACT_FILES}${G_ACT_FILE_SEL}"
				G_ACT_FILE_SEL="${G_ARR_ACT_FILES[RES]}"
				G_ACT_FILE_SEL_PATH="${G_DIR_ACT_FILES}${G_ACT_FILE_SEL}"
				# menu: config-file options
				func_menu_act_file_opt

			else
				# error
				func_msgbox "ERROR" "\Z1You must choose one Config-File!"

			fi
		elif [ $RET -eq 3 ]; then
			# button: NEW (extra button)

			# dialog: new act-file
			func_menu_act_file_new

			# act-file's: refresh
			func_get_act_files_list

		elif [ $RET -eq 1 ] || [ $RET -ge 255 ]; then
			# button: EXIT or ERROR
			break
		fi
	done
}

# dialog: menu: inputbox: create new act-file
func_menu_act_file_new() {
	
	# block scrolling
	clear

	# variables
	local RES
	local RET
	local FN
	local TMP
	local CFG_NR="${#G_ARR_ACT_FILES[@]}"

	# variables: dialog
	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "New")
	local DLG_MSG_TITLE="\ZuMenü: Create new ACT-File:\ZU\n\n"
	local DLG_MSG="Create in directory: \Z4${G_DIR_ACT_FILES}\n\n(Tipp: use on first position numbers for sorting!)\Zn\n\nInput filename with extension \Z4'${G_ARR_CONF['file_act_ext']}' ?\Zn"
	local DLG_HEIGHT=0
	local DLG_WIDTH=100

	# check and format default act-command-file number
	((CFG_NR++))
	CFG_NR=$(printf "%02d" $CFG_NR)
	local DLG_DEFAULT="${CFG_NR}_act_new${G_ARR_CONF['file_act_ext']}"
	
	# func_inputbox: parameters: 1:title, 2:message, 3: default value 4:height, 5:width
	RES=$( func_inputbox "${DLG_TITLE}" "${DLG_MSG_TITLE}${DLG_MSG}" "${DLG_DEFAULT}" )

	# check return: button
	RET=$?

	if [ $RET -eq 0 ]; then
		# button: OK
		# create new act-command-file template
		# set: filename
		FN="${G_DIR_ACT_FILES}${RES}"
		# check: filename
		if [[ -n $RES && ! -e "${FN}" ]]; then
			# create new act-command-file
			TMP=$( cp "${G_ARR_CONF['file_act_tpl']}" "${FN}" )
			if [ -e "${FN}" ]; then
				# set default settings
				
				# set ini file for function: func_ini_file
				G_INI_FILE_SEL="${FN}"
				
				# setting: set: general command's default
				func_ini_file "w" "val" "general" "confirm" "${G_ARR_SETTINGS[1]}"
				
				# setting: set: command_X default
				func_ini_file "w" "val" "command_1" "confirm" "${G_ARR_SETTINGS[2]}"
				func_ini_file "w" "val" "command_2" "confirm" "${G_ARR_SETTINGS[2]}"

				# copy: success
				func_msgbox "INFO" "\Z4New ACT-file created successfully!\Zn"

			else
				# error: copy
				func_msgbox "ERROR" "\Z1Can't create new ACT-file!\n\nfilename: $FN\n\nERROR: $TMP\Zn"

			fi
		else
			# error: empty or exist
			func_msgbox "ERROR" "\Z1Filename empty or exist!\n\nfilename: $FN\Zn"

		fi
	elif [ $RET -eq 1 ] || [ $RET -ge 255 ]; then
		# button: EXIT or ERROR
		break
	fi
}


# ####################################################################################################
# menu: act-file's => option's
# ####################################################################################################

# ==================================================
# function's - general
# ==================================================

# check: backup directory
func_check_dir_bkp() {

	# variables

	# check: if directory not empty
	if [ -n $G_DIR_ACT_FILES_BKP ]; then
		# check: if directory exist
		if [ ! -d "${G_DIR_ACT_FILES_BKP}" ]; then
			# create: directory and set mode
			mkdir "${G_DIR_ACT_FILES_BKP}"
			chmod 0755 "${G_DIR_ACT_FILES_BKP}"

			# message: true
			func_msgbox "INFO" "\Z4Backup-Directory create successfully!\Zn\n\nBackup-Dir: \Z4${G_DIR_ACT_FILES_BKP}\Zn"

		fi
	else
		# error: empty
		func_msgbox "ERROR" "\Z1Can't create Backup-Directory!\n\nValue EMPTY!\Zn"
	fi
}

# ==================================================
# function's - menu
# ==================================================

# menu: act-file options
func_menu_act_file_opt() {
	
	# block scrolling
	clear

	# variables
	local RES
	local RES2
	local RET
	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's")
	local DLG_HEIGHT=0
	local DLG_WIDTH=100
	local DLG_HEIGHT_2=13
	local DLG_MENU_TITLE="\n\ZuMenü: ACT-File-Option's\ZU\n\n"
	local DLG_MENU_MSG="Selected ACT-File: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\nChoose ACT-file option ?"
	local ARR_MENU_ENTRYS=("1" "Show Information's" "2" "Execute (step 1 of 2)" "3" "Edit" "4" "Edit with Editor" "5" "Rename" "6" "Backup: create" "7" "Backup: restore" "8" "Delete")

	# loop: menu
	while true; do

		RES=$( dialog \
			--backtitle "${G_ARR_CONF['script_info']}" \
			--title "${DLG_TITLE}" \
			--cr-wrap --colors --scrollbar \
			--ok-button "Choose" \
			--cancel-button "Back" \
			--scrollbar \
			--menu "${DLG_MENU_TITLE}${DLG_MENU_MSG}" $DLG_HEIGHT $DLG_WIDTH $DLG_HEIGHT_2 "${ARR_MENU_ENTRYS[@]}" \
			3>&1 1>&2 2>&3 )

		# check: dialog return
		RET=$?

		if [ $RET -eq 0 ]; then
			# button: OK			
			if [ "$RES" != "" ]; then
				# check result
				# return: 1=show, 2=execute, 3=edit, 4=delete
				case "$RES" in
					1) func_menu_act_file_opt_show;;		# act-file: show inforamtion's
					2) func_menu_act_file_opt_exec;;		# act-file: execute
					3) func_menu_act_file_opt_edit;;		# act-file: edit
					4) func_menu_act_file_opt_edit_file;;	# act-file: edit file
					5)
						# act-file: call function act-file rename
						func_menu_act_file_opt_ren
						# check result
						[ $G_FUNC_RET_VAL = "ren_yes" ] && break
					;;
					6) func_menu_act_file_opt_bkp;;			# act-file: backup: create
					7) func_menu_act_file_opt_bkp_restore;;	# act-file: backup: restore
					8)
						# act-file: call function act-file delete
						func_menu_act_file_opt_del
						# check result
						[ $G_FUNC_RET_VAL = "del_yes" ] && break
					;;
				esac
				# switch: end
			else
				# error
				func_msgbox "ERROR" "\Z1You must choose one Config-File!"

			fi
		elif [ $RET -eq 1 ] || [ $RET -ge 255 ]; then
			# button: EXIT or ERROR
			break

		fi
	done
	# exit loop
}

# ==================================================
# function's - menu - entry's
# ==================================================

# menu: act-file: option: show information's
func_menu_act_file_opt_show() {

	# block scrolling
	clear

	# variables
	local RES
	local MSG=""
	local MSG_STRIP="------------------------------------------------------------\n"
	local TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Show Info's")

	# set ini file
	G_INI_FILE_SEL="${G_ACT_FILE_SEL_PATH}"

	# set haeder message
	local MSG="\ZuMenü: ACT-file - Information's\ZU\n\n\Z4(Info: scrolling with key's: UP,DOWN,PgUp,PgDown)\Zn\n\nSelected ACT-file: \Z4${G_INI_FILE_SEL}\Zn\n\n"

	# read: general: description
	RES=$(func_ini_file "r" "general" "desc")
	MSG+="\Z1${MSG_STRIP}[general]\n${MSG_STRIP}\Z4Description:\Zn\n ${RES}"

	# read: general: option
	RES=$(func_ini_file "r" "general" "confirm")
	MSG+="\n\Z4Confirm-Command's:\Zn\n "
	MSG+="${RES}: ${G_ARR_GENERAL_CONFIRM_DESC[$RES]}"

	# read: all keys: desc1
	func_ini_file "r" "all" "desc1" "" "array"
	local RES_ARR_DESC1=( "${G_FUNC_RET_VAL[@]}" )

	# read: all keys: desc2
	func_ini_file "r" "all" "desc2" "" "array"
	local RES_ARR_DESC2=( "${G_FUNC_RET_VAL[@]}" )

	# read: all keys: cmd
	func_ini_file "r" "all" "cmd" "" "array"
	local RES_ARR_CMD=( "${G_FUNC_RET_VAL[@]}" )

	# read: all keys: confirm, remove first(general) entry!
	func_ini_file "r" "all" "confirm" "" "array"
	local RES_ARR_CONFIRM=( "${G_FUNC_RET_VAL[@]:1}" )

	# loop: generate message
	local lc=1
	for (( i = 0; i < "${#RES_ARR_DESC1[@]}"; i++ )); do
		MSG+="\n\n\Z1${MSG_STRIP}[command_$lc]\n${MSG_STRIP}\Z4Description(short):\Zn\n ${RES_ARR_DESC1[$i]}"
		MSG+="\n\Z4Description(long):\Zn\n ${RES_ARR_DESC2[$i]}"
		MSG+="\n\Z4Command:\Zn\n ${RES_ARR_CMD[$i]}"
		MSG+="\n\Z4Confirm-Command:\Zn\n ${RES_ARR_CONFIRM[$i]}"
		((lc++))		
	done

	# display: messagebox: title, text, height, width, only_title[1]
	func_msgbox "${TITLE}" "${MSG}" 25 100 1
}

# menu: act-file: option: execute
func_menu_act_file_opt_exec() {

	# block scrolling
	clear

	# variables
	local RET
	local RES
	local TMP
	local msg

	# set: act-file for ini function
	G_INI_FILE_SEL="${G_ACT_FILE_SEL_PATH}"
	# ini: read: general: description
	local ACT_GENERAL_DESC=$(func_ini_file "r" "general" "desc")
	# ini: read: general: confirm
	local ACT_GENERAL_CONFIRM=$(func_ini_file "r" "general" "confirm")
	# set: general: confirm: description, colors inclueded
	local ACT_GENERAL_CONFIRM_DESC="${G_ARR_GENERAL_CONFIRM_DESC[$ACT_GENERAL_CONFIRM]}"

	# variables: dialog
	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Execute")
	local DLG_MSG="\n\ZuMenü: ACT-File - Command's - Execute\ZU\n\nSelected ACT-File: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\nDescription: \Z4${ACT_GENERAL_DESC}\Zn\n\nGeneral:Command-Confirm(\Z4${ACT_GENERAL_CONFIRM}\Zn): ${ACT_GENERAL_CONFIRM_DESC}\n\nCheck command's to will be execute: (Check/Uncheck with Key: \Z4SPACE\Zn) ?"
	local DLG_HEIGHT="25"
	local DLG_WIDTH="120"
	local DLG_HEIGHT2="10"

	# reset: entrys array
	local DLG_ARR_ENTRYS=()

	# ini: read: all option confirm from act-file
	func_ini_file "r" "all" "confirm" "" "array"
	# format: array-shift: first element(section: general)
	local DLG_ARR_CMD_CONFIRM=("${G_FUNC_RET_VAL[@]:1}")

	# ini: read: all command description(short) from act-file
	func_ini_file "r" "all" "desc1" "" "array"

	# format: arrays for dialog
	local C=0
	local ENTRY_ID=1
	for (( i = 0; i < "${#G_FUNC_RET_VAL[@]}"; i++ )); do
		DLG_ARR_ENTRYS[$C]="${ENTRY_ID}"
		((ENTRY_ID++))
		((C++))
		DLG_ARR_ENTRYS[$C]="${G_FUNC_RET_VAL[$i]} (confirm: \Z4${DLG_ARR_CMD_CONFIRM[$i]}\Zn)"
		((C++))
		DLG_ARR_ENTRYS[$C]="on"
		((C++))
	done

	# loop: dialog
	while true; do
		clear
		RES=$( dialog \
			--backtitle "${G_ARR_CONF['script_info']}" \
			--title "${DLG_TITLE}" \
			--cr-wrap --colors --scrollbar --defaultno \
			--ok-button "Execute" \
			--cancel-button "Back" \
			--scrollbar \
			--checklist "${DLG_MSG}" \
			"${DLG_HEIGHT}" "${DLG_WIDTH}" "${DLG_HEIGHT2}" \
			"${DLG_ARR_ENTRYS[@]}" \
			3>&1 1>&2 2>&3 )

		# check dialog return
		RET=$?

		if [[ $RET -eq 0 ]]; then
			# button: ok|execute
			# check: result
			if [[ "${RES}" != "" ]]; then
				# execute checked command's

				# convert: result(str) to array, delimiter: 1-space, 2-\n
				func_str_to_array "1" "${RES}"
				local ARR_CMD_ID=("${G_FUNC_RET_VAL[@]}")
				
				# ini: read: all cli-command's from act-file into array
				func_ini_file "r" "all" "cmd" "" "array"
				local ARR_CMD=("${G_FUNC_RET_VAL[@]}")

				# ini: read: all command's-confirm from act-file into array
				func_ini_file "r" "all" "confirm" "" "array"
				local ARR_CMD_CONFIRM=("${G_FUNC_RET_VAL[@]}")

				# ini: read: all command's-description(short) from act-file into array
				func_ini_file "r" "all" "desc1" "" "array"
				local ARR_CMD_DESC1=("${G_FUNC_RET_VAL[@]}")

				# ini: read: all command's-description(long) from act-file into array
				func_ini_file "r" "all" "desc2" "" "array"
				local ARR_CMD_DESC2=("${G_FUNC_RET_VAL[@]}")

				# debug
				# func_debug_array "${ARR_CMD_ID[@]}"
				# func_debug_array "${ARR_CMD_CONFIRM[@]}"

				# display: command-execute: header
				# block scrolling
				clear
				# message: command header
				echo -e "${G_COLORS['blue']}##############################\n${G_COLORS['yellow']}Auto-Command-Tool\nVersion: ${G_ARR_CONF['script_version']}\n${G_ARR_CONF['script_copyrights']}\n${G_COLORS['blue']}##############################\n"

				# debug
				# func_debug_array "${G_FUNC_RET_VAL[@]}"
				
				# variables
				local TMP_CMD_ID ARG_1 ARG_2 ARG_3 ARG_4 ARG_5

				# execute checked command's
				for (( i = 0; i < "${#ARR_CMD_ID[@]}"; i++ )); do
					# set: index
					TMP_CMD_ID="${ARR_CMD_ID[$i]}"
					
					# command: set arguments for execution
					# args: $1=command_count, $2=command_id, $3=command, $4=command_description, $5=confirm_execution 
					ARG_1="${#ARR_CMD_ID[@]}"
					ARG_2=$(($i+1))
					ARG_3="${ARR_CMD[$TMP_CMD_ID-1]}"
					# ARG_4="${ARR_CMD_DESC1[$TMP_CMD_ID-1]}"
					ARG_4="${ARR_CMD_DESC2[$TMP_CMD_ID-1]}"
					
					# check: argument 5
					if [ "${ACT_GENERAL_CONFIRM}" = "" ] || [ "${ACT_GENERAL_CONFIRM}" = "true" ]; then
						# confirm: global: true
						ARG_5="true"
					elif [ "${ACT_GENERAL_CONFIRM}" = "false" ]; then
						# confirm: global: false
						ARG_5="false"
					elif [ "${ACT_GENERAL_CONFIRM}" = "cmd" ]; then
						# confirm: comand_X: cmd
						ARG_5="${ARR_CMD_CONFIRM[$TMP_CMD_ID]}"
					fi

					# variables
					local RES
					local RES_Q

					# message: command
					local MSG="\n${G_COLORS['green']}--- command[ ${ARG_2} of ${ARG_1} ]${G_COLORS['yellow']}(${ARG_3})${G_COLORS['green']} - execute(${G_COLORS['clear']}confirm: ${ARG_5}${G_COLORS['green']}) ...${G_COLORS['clear']}"
					local MSG+="\n${G_COLORS['yellow']}Description:${G_COLORS['clear']} ${ARG_4}"
					
					# message: confirm
					local MSG_Q_CHARS="${G_COLORS['yellow']}( ${G_COLORS['green']}y${G_COLORS['clear']}es, ${G_COLORS['yellow']}s${G_COLORS['clear']}kip, ${G_COLORS['red']}c${G_COLORS['clear']}ancel${G_COLORS['yellow']} ) ? ${G_COLORS['clear']}"
					local MSG_Q="${G_COLORS['cyan']}Would you like execute command ${MSG_Q_CHARS}"

					# message: display
					echo -e "${MSG}"

					# command: check confirm
					if [ "${ARG_5}" = "true" ]; then
						# command: confirm: display
						echo -e -n "${MSG_Q}"

						# loop: check correct question input ([y]es, [s]kip, [c]ancel)
						while true; do
							read RES
							if [ "${RES}" = "y" ] || [ "${RES}" = "s" ] || [ "${RES}" = "c" ]; then
								RES_Q="${RES}"
								break
							else
								echo -e -n "${G_COLORS['red']}FALSE input! allowed char's ${MSG_Q_CHARS}"
							fi
						done

						# check: question input
						if [ "${RES_Q}" = "s" ]; then
							# skip
							echo -e "${G_COLORS['red']}SKIP command[${ARG_2}] execution... to continue...${G_COLORS['clear']}"
							continue
						elif [ "${RES_Q}" = "c" ]; then
							# cancel
							echo -e "${G_COLORS['red']}CANCEL command execution...${G_COLORS['clear']}"
							break
						fi
					fi

					# check: execution: no confirm or confirm-question result: yes
					if [ "${ARG_5}" = "false" ] || [ "${RES_Q}" = "y" ]; then
						# command: execute, next step
						func_cmd_exec "${ARG_3}"
					fi					
				done

				# loop: end: sleep
				echo -e -n "\n${G_COLORS['yellow']}Forward with key [Enter] ..."
				read

				# loop: exit
				break
			else
				# error message: no checked command's
				func_msgbox "ERROR" "\Z1You must checked minimum one command!\Zn"
			fi
		else
			# cancel or button: cancel
			# loop: dialog: exit
			break
		fi
	done
}

# menu: act-file: option: edit
func_menu_act_file_opt_edit() {
	
	# variables
	local RET
	local RES

	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Edit")
	local DLG_HEIGHT=26
	local DLG_WIDTH=100
	local DLG_HEIGHT2=10
	local TEMP

	# refresh dialog after closing
	G_FORM_UPDATE_VAR="true"

	# loop: menu
	while true; do

		# block scrolling
		clear
		
		# update: form variables (refresh by change)
		if [ "${G_FORM_UPDATE_VAR}" = "true" ]; then
			# update form variable's
			
			# set: ini file
			G_INI_FILE_SEL="${G_ACT_FILE_SEL_PATH}"

			# ini-file: read: all
			func_ini_file "r" "all" "" "" "array"
			local TMP_ARR_SEC=("${G_FUNC_RET_VAL[@]}")

			# ini-file: read: desc1 (short)
			func_ini_file "r" "all" "desc1" "" "array"
			local TMP_ARR_DESC1=("${G_FUNC_RET_VAL[@]}")

			# ini_file: read: general description
			local TMP_CFG_DESC=$( func_ini_file "r" "general" "desc" )

			# format: menu entry's
			local ARR_MENU_ENTRYS=()
			ARR_MENU_ENTRYS[0]="1"
			ARR_MENU_ENTRYS[1]="\Z4[general]\Zn"

			# loop: generate menu entry's
			local mi=2
			local mc=2
			local di=0
			for (( i = 1; i < "${#TMP_ARR_SEC[@]}"; i++ )); do

				ARR_MENU_ENTRYS[$mi]="$mc"
				((mc++))
				((mi++))
				ARR_MENU_ENTRYS[$mi]="\Z1[${TMP_ARR_SEC[$i]}]\Zn \Z4(${TMP_ARR_DESC1[$di]})\Zn"
				((di++))
				((mi++))
			done

			# reset form update variables, one loop
			G_FORM_UPDATE_VAR="false"

			# DEBUG
			# func_msgbox "DEBUG" "Form variables refresh!"
		fi

		# get: count of menu entry's
		m_count=$(( $mi/2 ))

		# dialog
		RES=$( dialog \
			--backtitle "${G_ARR_CONF['script_info']}" \
			--title "${DLG_TITLE}" \
			--cr-wrap --colors --scrollbar \
			--extra-button --extra-label "Add Command" \
			--ok-button "Choose" \
			--cancel-button "Back" \
			--scrollbar \
			--menu "\n\ZuMenü: ACT-File - Edit\ZU\n\nSelected ACT-File: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\n\ZuDescription:\ZU\n\n\Z4${TMP_CFG_DESC}\Zn\n\nChoose ACT-file-[Section](1 of ${m_count}) for edit/delete ?" \
			$DLG_HEIGHT $DLG_WIDTH $DLG_HEIGHT2 \
			"${ARR_MENU_ENTRYS[@]}" \
			3>&1 1>&2 2>&3 )

		# check result
		RET=$?

		if [ $RET -eq 0 ]; then
			# button: OK
			# check: result
			if [ "$RES" != "" ]; then
				# set global selected config-file

				# call: edit option, index-- (section: general)
				TMP=$(( $RES - 1 ))
				func_menu_act_file_opt_edit_cmd "${TMP_ARR_SEC[$TMP]}"

				# func_menu_act_file_opt_edit_cmd_confirm "${TMP_ARR_SEC[$TMP]}"

				# refresh form variable's
				G_FORM_UPDATE_VAR="true"

			else
				# error
				func_msgbox "ERROR" "\Z1You must choose one ACT-File!"

			fi
		elif [ $RET -eq 3 ]; then
			# button: extra button: add new command

			# call: function: add command
			func_menu_act_file_opt_edit_cmd_add "${#TMP_ARR_SEC[@]}"

		elif [ $RET -eq 1 ] || [ $RET -ge 255 ]; then
			# button: EXIT or ERROR
			break
		fi
	done
}

# menu: act-file: option: edit file (editor)
func_menu_act_file_opt_edit_file() {
	
	# block scrolling
	clear

	# variables
	local RES
	local RET
	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Edit-File (Editor)")

	# dialog: editbox
	RES=$( dialog \
		--backtitle "${G_ARR_CONF['script_info']}" \
		--title "${DLG_TITLE}" \
		--cr-wrap --colors --scrollbar --ok-button "Save" --cancel-button "Cancel" \
		--editbox "${G_ACT_FILE_SEL_PATH}" 0 0 \
		3>&1 1>&2 2>&3 )

	# check dialog return
	RET=$?
	if [ $RET -eq 0 ]; then
		# button: OK
		# confirm overide file
		# param: 1:title, 2:message, 3:height, 4:width
		func_msgbox_yn "Save - ACT-File" "\Z1ACT-File will be overwritten!\n\nAre you sure?\Zn" 0 0
		# confirm save file
		if [[ $G_FUNC_RET_VAL -eq 0 ]]; then
			echo "${RES}" > "${G_ACT_FILE_SEL_PATH}"
			func_msgbox "INFO" "\Z4ACT-File saved successfully!\Zn"
		fi
	fi
}

# menu: act-file: option: rename
func_menu_act_file_opt_ren() {
	
	# block scrolling
	clear

	# variables
	local RES
	local RET
	local FN_FROM="${G_ACT_FILE_SEL_PATH}"
	local FN_TO

	# func_inputbox: param: 1:title, 2:message, 3: default value 4:height, 5:width
	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Rename")
	local MSG="\ZuMenü: ACT-File RENAME:\ZU\n\nSelected ACT-file: \Z4${FN_FROM}\n\n(Tipp: use on first position numbers for sorting!)\Zn\n\nInput new filename with extension: \Z4'${G_ARR_CONF['file_act_ext']}' ?\Zn"
	# confirm: input result
	RES=$( func_inputbox "${DLG_TITLE}" "${MSG}" "${G_ACT_FILE_SEL}" )

	# check return: button
	RET=$?

	if [ $RET -eq 0 ]; then
		# button: OK
		# set: new filename
		FN_TO="${G_DIR_ACT_FILES}${RES}"

		# check if exist new filename
		if [[ -n $RES && ! -e $FN_TO ]]; then
			# rename config-file
			local TMP=$(mv "${FN_FROM}" "${FN_TO}")

			# check result
			if [[ "${TMP}" == "" ]]; then
				# set global selecetd config-file
				G_ACT_FILE_SEL="${RES}"
				G_ACT_FILE_SEL_PATH="${G_DIR_ACT_FILES}${G_ACT_FILE_SEL}"
				# refresh config-file list
				func_get_act_files_list
				# message: success
				func_msgbox "INFO" "\Z4ACT-file rename successfully!\Zn"
				# set result
				G_FUNC_RET_VAL="ren_yes"
			else
				# message: error
				func_msgbox "ERROR" "\Z1Can't rename ACT-file!\n\nERROR: ${TMP}\Zn"
			fi
		else
			# message: error
			func_msgbox "ERROR" "\Z1ACT-filename empty or exist!\Zn"
		fi
	fi
}

# menu: act-file: option: backup: create
func_menu_act_file_opt_bkp() {

	# block scrolling
	clear

	# variables
	local RET
	local RES
	local DS
	local FN

	# generate: backup: filename
	DS=$( date +"%Y-%m-%d-%H-%M-%S" )
	FN="${G_DIR_ACT_FILES_BKP}${DS}__${G_ACT_FILE_SEL}"

	# check: if exist backup directory, else create it
	func_check_dir_bkp

	# set: act-file for ini function
	G_INI_FILE_SEL="${G_ACT_FILE_SEL_PATH}"

	# read: general: description
	local TMP_DESC_GENERAL=$(func_ini_file "r" "general" "desc")

	# variables: dialog
	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Backup")
	local DLG_MSG="\ZuMenü: ACT-File: Backup-Create\ZU\n\nSelected ACT-File: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\nBackup-ACT-File: \Z4${FN}\Zn\n\n\Z1Would you like create Backup for selected ACT-File ?\Zn"
	local DLG_HEIGHT="13"
	local DLG_WIDTH="100"

	# param: 1:title, 2:message, 3:height, 4:width
	func_msgbox_yn "${DLG_TITLE}" "${DLG_MSG}" $DLG_HEIGHT $DLG_WIDTH

	# check: value
	if [[ $G_FUNC_RET_VAL -eq 0 ]]; then
		# button: yes
		# copy: act-file to backup directory
		RES=$( cp "${G_ACT_FILE_SEL_PATH}" "${FN}" )
		# message: result
		func_msgbox "INFO" "\Z4Backup: ACT-File created successfully!\Zn"
	fi
}

# menu: act-file: option: show backup's
# param: $1=bkp_file
func_menu_act_file_opt_bkp_show() {

	# block scrolling
	clear

	# variables
	local RES
	local MSG=""
	local MSG_STRIP="------------------------------------------------------------\n"
	local MSG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Backup" "Show Info's / Restore")

	# set: ini file for read: function func_ini_file
	G_INI_FILE_SEL="${1}"

	# set haeder text
	local MSG="\ZuACT-BKP-file - Information's\ZU\n\Z4(Info: scrolling with key's: UP,DOWN,PgUp,PgDown)\Zn\n\nSelected ACT-BKP-file: \Z4${1}\Zn\n\nSelected ACT-file: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\n"

	# read: general: description
	RES=$(func_ini_file "r" "general" "desc")
	MSG+="\Z1${MSG_STRIP}[general]\n${MSG_STRIP}\Z4Description:\Zn\n ${RES}"

	# read: general: option
	RES=$(func_ini_file "r" "general" "confirm")
	MSG+="\n\Z4Confirm-Command's:\Zn\n "
	MSG+="${RES}: ${G_ARR_GENERAL_CONFIRM_DESC[$RES]}"

	# read: all keys: desc1
	func_ini_file "r" "all" "desc1" "" "array"
	local RES_ARR_DESC1=( "${G_FUNC_RET_VAL[@]}" )

	# read: all keys: desc2
	func_ini_file "r" "all" "desc2" "" "array"
	local RES_ARR_DESC2=( "${G_FUNC_RET_VAL[@]}" )

	# read: all keys: cmd
	func_ini_file "r" "all" "cmd" "" "array"
	local RES_ARR_CMD=( "${G_FUNC_RET_VAL[@]}" )

	# read: all keys: confirm, remove first(general) entry!
	func_ini_file "r" "all" "confirm" "" "array"
	local RES_ARR_CONFIRM=( "${G_FUNC_RET_VAL[@]:1}" )

	# loop: generate message
	local lc=1
	for (( i = 0; i < "${#RES_ARR_DESC1[@]}"; i++ )); do
		MSG+="\n\n\Z1${MSG_STRIP}[command_$lc]\n${MSG_STRIP}\Z4Description(short):\Zn\n ${RES_ARR_DESC1[$i]}"
		MSG+="\n\Z4Description(long):\Zn\n ${RES_ARR_DESC2[$i]}"
		MSG+="\n\Z4Command:\Zn\n ${RES_ARR_CMD[$i]}"
		MSG+="\n\Z4Confirm-Command:\Zn\n ${RES_ARR_CONFIRM[$i]}"
		((lc++))		
	done

	# display: messagebox: title, text, height, width, only_title[1]
	func_msgbox_yn "${MSG_TITLE}" "${MSG}" 25 100 1 "restore"
}

# menu: act-file: option: backup: restore
func_menu_act_file_opt_bkp_restore() {

	# block scrolling
	clear

	# variables
	local RET
	local RES
	local TMP

	# check: if exist backup directory
	if [[ -d "${G_DIR_ACT_FILES_BKP}" ]]; then
		
		# variables: dialog
		local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Backup" "Restore")
		local DLG_MSG="\n\ZuMenü: ACT-File - Backup-Restore:\ZU\n\nSelected ACT-File: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\n\Z1ATTENTION: Selected ACT-file will be overwritten!\Zn\n\nChoose Backup to restore in selected ACT-File ?"
		local DLG_HEIGHT="0"
		local DLG_WIDTH="100"
		local DLG_HEIGHT2="15"
		local MSG_TITLE="${DLG_TITLE}"
		local MSG_TXT
		local MSG_RES

		# loop
		while true; do
			
			# block scrolling
			clear
		
			# list backup files from backup directory
			func_get_act_files_bkp_list

			# check: array:length, start index 1
			if [[ "${G_ARR_ACT_FILES_BKP[1]}" = "" ]]; then
				# cancel: no backup file found, exit loop
				MSG_MSG="\Z4No Backup-ACT-File's found!\Zn"
				func_msgbox "${MSG_TITLE}" "${MSG_MSG}" "" "" "1"
				break
			fi

			# dialog: show
			RES=$( dialog \
				--backtitle "${G_ARR_CONF['script_info']}" \
				--title "${DLG_TITLE}" \
				--cr-wrap --colors --scrollbar --defaultno \
				--ok-button "Info / Restore" \
				--extra-button --extra-label "BKP Delete" \
				--cancel-button "Back" \
				--menu "${DLG_MSG}" "${DLG_HEIGHT}" "${DLG_WIDTH}" "${DLG_HEIGHT2}" \
				"${G_ARR_ACT_FILES_BKP_MENU[@]}" \
				3>&1 1>&2 2>&3 )

			# check: dialog: return
			RET=$?

			if [[ $RET -eq 0 ]]; then
				# button: ok / true

				local DLG_HEIGHT="13"
				local DLG_WIDTH="100"				
				local FN_FROM="${G_DIR_ACT_FILES_BKP}${G_ARR_ACT_FILES_BKP[$RES]}"
				local FN_TO="${G_ACT_FILE_SEL_PATH}"

				# show: act-bkp-file info and choice
				func_menu_act_file_opt_bkp_show "${FN_FROM}"

				# check: backup file restore
				if [[ "${G_FUNC_RET_VAL}" = "0" ]]; then
					# restore: success
					func_msgbox "${MSG_TITLE}" "Backup: restore Backup-ACT-File successfully!"
				fi
				# loop: exit
				break
			elif [[ $RET -eq 3 ]]; then
				# button: delete
				local FN="${G_DIR_ACT_FILES_BKP}${G_ARR_ACT_FILES_BKP[$RES]}"
				MSG_TXT="\ZuMenü: ACT-File: Backup-Delete\ZU\n\nSelected Backup-File:\n\n\Z4${FN}\Zn\n\n\Z1Would you like delete selected Backup-File ?\Zn"
				func_msgbox_yn "${MSG_TITLE}" "${MSG_TXT}" 13

				# check: result question
				if [[ "${G_FUNC_RET_VAL}" = "0" ]]; then
					# true, delete backup file
					local MSG_RES=$( rm "${FN}" )
					# message: true
					func_msgbox "${MSG_TITLE}" "\Z4Backup: delete Backup-ACT-File successfully!\Zn"
				fi
			else
				# cancel or button: cancel
				# debug
				# func_msgbox "DEBUG - CANCEL" "return: ${RET}\n\nresult: ${RES}"
				# loop: exit
				break
			fi
		done
	else
		# false
		func_msgbox "ERROR" "\Z1Backup-Directory doesn't exist!\n\nBackup-Dir: ${G_DIR_ACT_FILES_BKP}\Zn"
	fi
}

# menu: act-file: option: delete
func_menu_act_file_opt_del() {
	
	# block scrolling
	clear

	# variables
	local RES
	local RET
	local TMP

	# func_msgbox_yn: param: 1:title, 2:message, 3:height, 4:width
	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Delete")
	local MSG="\ZuMenü: ACT-File DELETE:\ZU\n\nSelected ACT-file: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\n\Z1The selected ACT-file will be deleted...\Zn\n\n\Z1Would you like to continue?\Zn\n "
	func_msgbox_yn "${DLG_TITLE}" "${MSG}" 0 0 1

	# check: return: button
	if [[ $G_FUNC_RET_VAL -eq 0 ]]; then
		# button: OK
		# delete: config-file
		TMP=$( rm "${G_ACT_FILE_SEL_PATH}" )
		# check result
		if [[ $TMP == "" ]]; then
			# refresh config-file list
			func_get_act_files_list

			# reset global variables
			G_ACT_FILE_SEL=""
			G_ACT_FILE_SEL_PATH=""

			# message: success
			func_msgbox "INFO" "\Z4ACT-file deleted successfully!\Zn"

			# return: global function return value
			G_FUNC_RET_VAL="del_yes"
		else
			# message: error
			func_msgbox "ERROR" "\Z1Can't delete ACT-file !\n\nError: ${TMP}\Zn"
		fi
	fi
}


# ####################################################################################################
# menu: act-file's => option's => edit => selected act-file
# ####################################################################################################

# ==================================================
# function's - general
# ==================================================

# ==================================================
# function's - menu
# ==================================================

# menu: act-file: options: edit: file: section
# param: $1=[global,commands], $2=section name
func_menu_act_file_opt_edit_cmd() {
	# --form text height width formheight [ label y x item y x flen ilen ] ...

	# block scrolling
	clear

	# variables
	local RET
	local RES

	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Edit" "Section's")
	local TMP_MSG_RES=""
	local CFG_SEL_SECTION="${1}"
	local DLG_WIDTH=100
	local DLG_TEXT="\n\ZuMenü: ACT-File - Edit - Section's (step 1 of 2)\ZU\n\nSelected-ACT-file: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\nSelected-Section: \Z4[${CFG_SEL_SECTION}]\Zn\n\n\Z4\ZuLegende-Description(\Z1\\\Z4+\Z1?\Z4):\Zn\ZU\Zn NEW ROW=\Z1n\Zn, \ZuUNDERLINE:\ZU=\Z1Zu\Zn...\Z1ZU\Zn, Colors=\Z1Z\Zn+[ \Z00\Z11\Z22\Z33\Z44\Z55\Z66\Z77\Zn ]...\Z1Zn\Zn\n "

	# dialog: max lenth
	local DLG_LEN_1=500
	local DLG_LEN_2=50
	local DLG_LEN_3=200

	# set ini-file for ini-function
	G_INI_FILE_SEL="${G_ACT_FILE_SEL_PATH}"

	# choose form: global, commands
	if [ "${CFG_SEL_SECTION}" = "general" ]; then
		# read values
		func_ini_file "r" "${CFG_SEL_SECTION}" "all" "" "array"
		local TMP_ARR_SEC_VAL=("${G_FUNC_RET_VAL[@]}")

		# dialog variables
		local DLG_HEIGHT=21
		local DLG_HEIGHT2=6

		# dialog: global
		RES=$(dialog --clear --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --scrollbar \
			--title "$DLG_TITLE" \
			--ok-label "Save" --extra-button --extra-label "Delete" --cancel-label "Cancel" \
			--defaultno \
			--inputbox "$DLG_TEXT" $DLG_HEIGHT $DLG_WIDTH "${TMP_ARR_SEC_VAL[0]}" \
			3>&1 1>&2 2>&3)
	else		
		# read values
		func_ini_file "r" "${CFG_SEL_SECTION}" "all" "" "array"
		local TMP_ARR_SEC_VAL=("${G_FUNC_RET_VAL[@]}")

		# dialog variables
		local DLG_HEIGHT=24
		local DLG_HEIGHT2=9

		# dialog: command's
		RES=$(dialog --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --scrollbar \
			--title "$DLG_TITLE" \
			--ok-label "Save" --extra-button --extra-label "Delete" --cancel-label "Cancel" \
			--defaultno \
			--form "$DLG_TEXT" \
			$DLG_HEIGHT $DLG_WIDTH $DLG_HEIGHT2 \
			"Description (short, for menu's) (max length: $DLG_LEN_2 char's):"	1 1 "${TMP_ARR_SEC_VAL[0]}" 2 1 93 $DLG_LEN_2 \
			"Description (long, for info's) (max length: $DLG_LEN_1 char's):"	4 1	"${TMP_ARR_SEC_VAL[1]}"	5 1 93 $DLG_LEN_1 \
			"Command (max length: $DLG_LEN_3 char's):" 7 1 "${TMP_ARR_SEC_VAL[2]}" 8 1 93 $DLG_LEN_3 \
			3>&1 1>&2 2>&3)
	fi

	# check result
	RET=$?

	if [ $RET -eq 0 ]; then
		# button: OK
		# save: config-section values

		# check: save: value's for selected section
		if [ "${CFG_SEL_SECTION}" = "general" ]; then
			# section: general
			# check: input
			if [ -n "${RES}" ]; then
				# write value's
				func_ini_file "w" "val" "${CFG_SEL_SECTION}" "desc" "${RES}"

				# message: result true
				TMP_MSG_RES="\Z4ACT-File: Change Value's successfully!\Zn"

			else
				# message: result false
				func_msgbox "ERROR" "\Z1Description EMPTY!\Zn"
			fi
		else
			# section: command X
			
			# format result
			local TMP_ARR_RES=()
			# format: result to array
			local IFS_OLD="${IFS}"
			IFS=$'\n' TMP_ARR_RES=( $RES )
			IFS="${IFS_OLD}"
			
			# check input
			if [ -n "${TMP_ARR_RES[0]}" ] && [ -n "${TMP_ARR_RES[1]}" ] && [ -n "${TMP_ARR_RES[2]}" ]; then
				# write value's
				func_ini_file "w" "val" "${CFG_SEL_SECTION}" "desc1" "${TMP_ARR_RES[0]}"
				func_ini_file "w" "val" "${CFG_SEL_SECTION}" "desc2" "${TMP_ARR_RES[1]}"
				func_ini_file "w" "val" "${CFG_SEL_SECTION}" "cmd" "${TMP_ARR_RES[2]}"

				# message: result true
				TMP_MSG_RES="\Z4ACT-File: Change Value's successfully!\Zn"

			else
				# error: message: result false
				func_msgbox "ERROR" "\Z1Description(short,long) or Command EMPTY!\Zn"
			fi
		fi
	elif [ $RET -eq 3 ]; then
		# button: extra-button: delete config-section, only command's
		if [ "${CFG_SEL_SECTION}" = "general" ]; then
			# message
			func_msgbox "ERROR" "\Z1Can't delete ACT-File-Section [general]!\Zn" 7 45

		else
			# message yes/no
			func_msgbox_yn "QUESTION" "\Z1Would you like delete follow Command-Section?\n\nSelected Command-Section: \Z4[${CFG_SEL_SECTION}]\Zn"

			# check: message result
			if [ $G_FUNC_RET_VAL -eq 0 ]; then
				# delete: section: command_X
				func_menu_act_file_opt_edit_cmd_del "${CFG_SEL_SECTION}"
			fi
		fi
	fi

	# check: confirm dialog
	if [ $RET -eq 0 ] || [ $RET -eq 1 ]; then
		# dialog: confirm: command confirm option
		func_menu_act_file_opt_edit_cmd_confirm "${CFG_SEL_SECTION}" "${TMP_MSG_RES}"
	fi
}


# menu: act-file: options: edit: file: section: confirm
# param: $1=[global,commands]
func_menu_act_file_opt_edit_cmd_confirm() {
	
	# block scrolling
	clear

	# variables
	local RET
	local RES
	local TMP_DEFAULT_VAL
	local CFG_SEL_SECTION="${1}"
	local DLG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Edit" "Section's" "Confirm")
	local DLG_WIDTH=100
	local DLG_MSG="\n\ZuMenü: ACT-File - Edit - Section's - Confirm Execution (step 2 of 2)\ZU\n\nSelected-ACT-file: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\nSelected-Section: \Z4[${CFG_SEL_SECTION}]\Zn\n\n"

	# check: section: global, command_X
	if [ "${CFG_SEL_SECTION}" = "general" ]; then
		# section: general
		# read current value
		TMP_DEFAULT_VAL=$( func_ini_file "r" "${CFG_SEL_SECTION}" "confirm" )

		# update: dialog message
		DLG_MSG+="Choose value (current: \Z4${TMP_DEFAULT_VAL}\Zn ) ? "

		# dialog: variables
		local DLG_HEIGHT=20
		local DLG_HEIGHT2=4
		local DLG_MENU_ENTRYS=( "1" "TRUE: ${G_ARR_GENERAL_CONFIRM_DESC['true']}" "2" "FALSE: ${G_ARR_GENERAL_CONFIRM_DESC['false']}" "3" "CMD: ${G_ARR_GENERAL_CONFIRM_DESC['cmd']}" )

	else
		# section: command_X
		# read current value
		TMP_DEFAULT_VAL=$( func_ini_file "r" "${CFG_SEL_SECTION}" "confirm" )
		# update: dialog message
		DLG_MSG+="Choose value (current: \Z4${TMP_DEFAULT_VAL}\Zn ) ? "

		# dialog variables
		local DLG_HEIGHT=20
		local DLG_HEIGHT2=3
		local DLG_MENU_ENTRYS=( "1" "TRUE: Confirm execution command" "2" "FALSE: Don't confirm execution command")
	fi

	# dialog: global
	RES=$(dialog --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --scrollbar \
		--title "$DLG_TITLE" \
		--ok-label "Save" --cancel-label "Cancel" \
		--defaultno \
		--menu "$DLG_MSG" $DLG_HEIGHT $DLG_WIDTH $DLG_HEIGHT2 "${DLG_MENU_ENTRYS[@]}" \
		3>&1 1>&2 2>&3)

	# check result
	RET=$?

	if [ $RET -eq 0 ]; then
		# button: OK, save config-section values
		
		# format input
		local TMP_RES
		[ "${RES}" = "1" ] && TMP_RES="true"
		[ "${RES}" = "2" ] && TMP_RES="false"
		[ "${RES}" = "3" ] && TMP_RES="cmd"

		# check: and write result
		if [ -n "${TMP_RES}" ]; then
			# write value's
			func_ini_file "w" "val" "${CFG_SEL_SECTION}" "confirm" "${TMP_RES}"
			
			# format: message: result true
			[ -n "${TMP_MSG_RES}" ] && TMP_MSG_RES+="\n\n"
			TMP_MSG_RES+="\Z4ACT-File: Change confirm-option successfully!\Zn"
		fi
	fi

	# check result message box
	if [ -n "${TMP_MSG_RES}" ]; then
		local MSG_TITLE=$(func_menu_header_path "Main" "ACT-File's" "Option's" "Edit" "Section's")
		# display: message box without default title $5=1
		func_msgbox "${MSG_TITLE}" "${TMP_MSG_RES}" "" "" "1"
	fi
}

# menu: act-file: options: edit: add new command-section
# param: $1=[global,commands], $2=section name
func_menu_act_file_opt_edit_cmd_add() {
	# --form text height width formheight [ label y x item y x flen ilen ] ...

	# Store data to $VALUES variable
	# RES=$(dialog \
	# 	--backtitle "Linux User Managment" \
	# 	--title "Edit Command" \
	# 	--form "\ZUSelected-Config-File:\Zu config-file\n\n\ZUSelected command:\Zu [command_1] " 35 120 0 \
	# 	"Description (short):"	1 1	"$user"		1 10 10 0 \
	# 	"Description (long):"	2 1	"$shell"	2 10 15 0 \
	# 	"CLI-Command:"			3 1	"$groups"	3 10 8 0 \
	# 	"HOME:"					4 1	"$home"		4 10 40 0 \
	# 	3>&1 1>&2 2>&3)

	# block scrolling
	clear

	# variables
	local RET
	local RES
	local DLG_TITLE=$(func_menu_header_path "Main" "Config-File" "Option's" "Edit" "Add command")
	local TEMP
	local CFG_ADD_SECTION="[command_${1}]"
	local DLG_HEIGHT=20
	local DLG_WIDTH=100
	local DLG_HEIGHT2=6
	local DLG_TEXT="\n\ZuMenü: ACT-File - add command\ZU\n\nSelected-Config-File: \Z4${G_ACT_FILE_SEL_PATH}\Zn\n\nAdd new [command-section]: \Z4${CFG_ADD_SECTION}\Zn\n "

	# dialog: for command-section
	RES=$(dialog --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --scrollbar \
		--title "$DLG_TITLE" \
		--ok-label "Save" \
		--cancel-label "Cancel" \
		--defaultno \
		--form "$DLG_TEXT" \
		$DLG_HEIGHT $DLG_WIDTH $DLG_HEIGHT2 \
		"Description (short, for menu's):"	1 1		""		1 35 58 100 \
		"Description (long, for info's):"	3 1		""		3 35 58 400 \
		"Command:" 5 1 "sudo " 5 11 78 400 \
		3>&1 1>&2 2>&3)

	# check result
	RET=$?

	if [ $RET -eq 0 ]; then
		# button: OK, save config-section values

		# variables, IFS
		local TMP_ARR_RES=()
		# format: result to array
		local IFS_OLD="${IFS}"
		IFS=$'\n' TMP_ARR_RES=( $RES )
		IFS="${IFS_OLD}"
		
		# result: message header
		local MSG_HEADER="\ZuAdd New Command-Section\ZU\n\n"

		# check: input
		if [ -n "${TMP_ARR_RES[0]}" ] && [ -n "${TMP_ARR_RES[1]}" ] && [ -n "${TMP_ARR_RES[2]}" ]; then
			# add: new command-section
			local TMP_CMD_NEW="\n${CFG_ADD_SECTION}\ndesc1=\"${TMP_ARR_RES[0]}\"\ndesc2=\"${TMP_ARR_RES[1]}\"\ncmd=\"${TMP_ARR_RES[2]}\"\nconfirm=\"${G_ARR_SETTINGS[2]}\""

			# write: new command-section into config-file
			echo -e "${TMP_CMD_NEW}" >> "${G_ACT_FILE_SEL_PATH}"

			# message: result true
			func_msgbox "INFO" "\Z4ACT-File: New Section added successfully!\Zn"

			# refresh: menu edit command
			G_FORM_UPDATE_VAR="true"
		else
			# message: result false
			func_msgbox "ERROR" "\Z1Description(short,long) or Command EMPTY!\Zn"
		fi
	else
		# message: result cancel or error
		func_msgbox "ERROR" "${MSG_HEADER}CANCEL or ERROR!"
	fi
}

# menu: act-file: options: edit: delete command-section
# param: $1=[global,commands], $2=section name
func_menu_act_file_opt_edit_cmd_del() {

	# block scrolling
	clear

	# variables
	local RES

	# delete: selected command-section
	RES=$( func_ini_file "d" "${CFG_SEL_SECTION}" )

	# debug
	func_msgbox "DEBUG - result" "res: ${RES}"

	# check result
	if [ "${RES}" = "true" ]; then
		# delete: true

		# re-numbering command-section's
		# list command-section-names from config file, return array
		func_ini_file "r" "cmd" "" "" "array"
		
		# loop: command-section's
		local TMP_C=1
		for (( i = 0; i < "${#G_FUNC_RET_VAL[@]}"; i++ )); do
			func_ini_file "w" "cmd_ren" "${G_FUNC_RET_VAL[$i]}" "command_${TMP_C}"
			((TMP_C++))
		done

		# message: true
		func_msgbox "INFO" "\Z4ACT-file-section deleted successfully!\Zn"
	else
		# message: false
		func_msgbox "ERROR" "\Z1Can't delete ACT-file-section!\n\nSection: \Z4[${CFG_SEL_SECTION}]\Z1 not found!\n\ndebug-res: ${RES}\Zn"
	fi
}


# ####################################################################################################
# menu: setting's
# ####################################################################################################

# ==================================================
# function's - general
# ==================================================

# settings init: load settings from setting-file
# param: $1=1(display message loaded)
func_settings_init() {

	# variables
	local FN="${G_ARR_CONF['file_settings']}"

	# settings: check: file exists
	if [ -e "${FN}" ]; then
		# set: ini file for ini-function
		G_INI_FILE_SEL="${FN}"

		# read: all values to array
		func_ini_file "r" "all" "val" "" "array"
		G_ARR_SETTINGS=("${G_FUNC_RET_VAL[@]}")

		# check: setting 1: act-directory: not empty
		[ -n "${G_ARR_SETTINGS[0]}" ] && G_DIR_ACT_FILES="${G_ARR_SETTINGS[0]}"

		# check: setting 11: act-backup-directory: not empty
		[ -n "${G_ARR_SETTINGS[11]}" ] && G_DIR_ACT_FILES_BKP="${G_ARR_SETTINGS[11]}"

		# display: message when parameter 1 equal init
		[ "$1" = "init" ] && func_msgbox "INFO" "\Z4SETTING'S loaded successfully!"
	else
		func_msgbox "ERROR" "\Z1SETTING-file not found!\n\nfile: ${FN}\Zn"
		# exit script
		func_menu_exit
	fi
}

# ==================================================
# function's - menu
# ==================================================

# menu: setting's
func_menu_settings() {

	# variables
	local RET
	local RES
	local RES2
	local FN="${G_ARR_CONF['file_settings']}"

	# dialog: variables
	local DLG_TITLE=$(func_menu_header_path "Main" "Setting's")
	local DLG_HEIGHT=27
	local DLG_HEIGHT2=15
	local DLG_WIDTH=100
	local DLG_TEXT="\n\ZuMenü: Setting's\ZU\n\nSetting-file: \Z4${FN}\Zn\n\nChoose setting to change:"
	# dialog: max lenth
	local DLG_LEN=100

	# set: ini file for function: func_ini_file
	G_INI_FILE_SEL="${FN}"

	# menu: loop
	while true; do
		# block scrolling
		clear

		# -------------
		# read settings
		# settings: descriptions
		func_ini_file "r" "all" "desc" "" "array"
		local TMP_ARR_SEC_DESC=("${G_FUNC_RET_VAL[@]}")
		# settings: values
		func_ini_file "r" "all" "val" "" "array"
		local TMP_ARR_SEC_VAL=("${G_FUNC_RET_VAL[@]}")
		# -------------

		# format: result to array for menu entry's
		local DLG_ARR_VALS=()
		local ai=0
		local ac=1
		for (( i = 0; i < "${#TMP_ARR_SEC_DESC[@]}"; i++ )); do
			DLG_ARR_VALS[$ai]="$ac"
			((ai++))
			((ac++))
			DLG_ARR_VALS[$ai]="${TMP_ARR_SEC_DESC[$i]} (\Z4${TMP_ARR_SEC_VAL[$i]}\Zn)"
			((ai++))
		done
		
		# -------------
		# dialog: command's
		# --defaultno \
		RES=$(dialog --backtitle "${G_ARR_CONF['script_info']}" --cr-wrap --colors --scrollbar \
			--title "$DLG_TITLE" \
			--ok-label "Choose" --extra-button --extra-label "Edit (Editor)" --cancel-label "Cancel" \
			--menu "$DLG_TEXT" \
			$DLG_HEIGHT $DLG_WIDTH $DLG_HEIGHT2 \
			"${DLG_ARR_VALS[@]}" \
			3>&1 1>&2 2>&3)

		# -------------
		# dialog: check result
		RET=$?

		if [ $RET -eq 0 ]; then
			# button: OK
			# format: array index (shift index of section global)
			RES2=$(( RES - 1 ))

			# set: parameters for input box
			local INP_TITLE=$(func_menu_header_path "Main" "Setting's" "Edit")
			local INP_MSG="Change Setting-Section: \Z4[setting_$RES]\Zn\n\nDescription: \Z4${TMP_ARR_SEC_DESC[$RES2]}\Zn\n\n"
			local INP_VAL="${TMP_ARR_SEC_VAL[$RES2]}"

			# check: setting edit dialog, [string | true/false], default string
			if [[ "${INP_VAL}" = "true" ]] || [[ "${INP_VAL}" = "false" ]] || [[ "${INP_VAL}" = "cmd" ]]; then
				# set: input question
				INP_MSG+="Choose new value (current: \Z4${INP_VAL}\Zn) ?"
				# param: 1:title, 2:message, 3:default value, 4:section_id
				func_menu_settings_edit_tf "${INP_TITLE}" "${INP_MSG}" "${INP_VAL}" "${RES}"
			else
				# set: input question
				INP_MSG+="Input new value (current: \Z4${INP_VAL}\Zn) ?"
				# param: 1:title, 2:message, 3:default value, 4:section_id
				func_menu_settings_edit "${INP_TITLE}" "${INP_MSG}" "${INP_VAL}" "${RES}"
			fi

			# settings: reload
			func_settings_init

		elif [ $RET -eq 3 ]; then
			# button: extra-button: edit setting's with editor
			func_menu_settings_edit_file
		else
			# exit menu loop
			break
		fi
	done
}

# menu: setting's: edit entry
# param: 1:title, 2:message, 3:default value, 4:section_id
func_menu_settings_edit() {
	
	# block scrolling
	clear

	# variables
	local RES
	local RET
	local FN="${G_ARR_CONF['file_settings']}"
	local TMP

	# variables: dialog
	local DLG_TITLE="$1"
	local DLG_MSG="$2"
	local DLG_DEFAULT="$3"
	local DLG_HEIGHT=0
	local DLG_WIDTH=100
	local SETTING_SEC_ID="$4"

	# func_inputbox: param: 1:title, 2:message, 3:default_value 4:height, 5:width
	RES=$( func_inputbox "${DLG_TITLE}" "${DLG_MSG}" "${DLG_DEFAULT}" )

	# check: return button
	RET=$?

	if [ $RET -eq 0 ]; then
		# button: OK
		# save new setting value
		# check: input:
		if [ "${RES}" != "" ]; then
			# set: ini file for function: func_ini_file
			G_INI_FILE_SEL="${FN}"

			# setting: write new value to section
			func_ini_file "w" "val" "setting_${SETTING_SEC_ID}" "val" "${RES}"

			# display: message: successfully
			func_msgbox "INFO" "\Z4Setting: New Value written successfully!\Zn"

			# reload settings
			func_settings_init

		else
			# error
			func_msgbox "ERROR" "\Z1Setting: New Value empty!\Zn"
		fi
	fi
}

# menu: setting's: edit entry, true/false
# param: 1:title, 2:message, 3:default value, 4:section_id
func_menu_settings_edit_tf() {
	
	# block scrolling
	clear

	# variables
	local RES
	local RET
	local FN="${G_ARR_CONF['file_settings']}"
	local TMP

	# variables: dialog
	local DLG_TITLE="$1"
	local DLG_MSG="$2"
	local DLG_HEIGHT=0
	local DLG_WIDTH=100
	local SETTING_SEC_ID="$4"

	# check: setting_id for special option
	if [[ "$4" = "2" ]]; then
		# param: 1:title, 2:text, 3:height, 4:width
		RES=$( func_menubox_tfc "${DLG_TITLE}" "${DLG_MSG}" )
	else
		# param: 1:title, 2:text, 3:height, 4:width
		RES=$( func_menubox_tf "${DLG_TITLE}" "${DLG_MSG}" )
	fi

	# check return: button
	RET=$?

	if [ $RET -eq 0 ]; then
		# button: OK
		# save: new setting value
		local VAL_NEW

		# check: input value's
		if [ "${RES}" = "2" ]; then
			VAL_NEW="true"
		elif [ "${RES}" = "3" ]; then
			VAL_NEW="cmd"
		else
			VAL_NEW="false"
		fi
		
		# set: ini file for function: func_ini_file
		G_INI_FILE_SEL="${FN}"

		# setting: write new value to section
		func_ini_file "w" "val" "setting_${SETTING_SEC_ID}" "val" "${VAL_NEW}"

		# display: message: successfully
		func_msgbox "INFO" "\Z4Setting: New Value written successfully!\Zn"

		# reload settings
		func_settings_init
	fi
}

# # menu: setting's: edit file (editor)
func_menu_settings_edit_file() {
	
	# block scrolling
	clear

	# variables
	local RES
	local RET
	local DLG_TITLE=$(func_menu_header_path "Main" "Setting's" "Edit-File (Editor)")
	local FN="${G_ARR_CONF['file_settings']}"

	# dialog: editbox
	RES=$( dialog --backtitle "${G_ARR_CONF['script_info']}" \
		--title "${DLG_TITLE}" \
		--cr-wrap --colors --scrollbar --ok-button "Save" --cancel-button "Cancel" \
		--editbox "$FN" 0 0 \
		3>&1 1>&2 2>&3 )

	# check: dialog return
	RET=$?

	if [ $RET -eq 0 ]; then
		# button: OK
		# confirm overide file
		# param: 1:title, 2:message, 3:height, 4:width
		func_msgbox_yn "Save - SETTING'S" "\Z1Setting's will be overwritten!\n\nAre you sure?\Zn" 0 0

		# confirm: save file
		if [[ $G_FUNC_RET_VAL -eq 0 ]]; then
			# write result to file
			echo "${RES}" > "$FN"

			# settings: reload
			func_settings_init

			# message: true
			func_msgbox "INFO" "\Z4Setting's saved/reload successfully!\Zn"
		fi
	fi
}


# ####################################################################################################
# menu: main: execute system command's
# ####################################################################################################

# ==================================================
# function's - general
# ==================================================

# execute command argument $1
func_cmd_exec() {
	
	# variables
	local TMP

	# check: command empty, else execute
	if [[ -n $1 ]]; then
		eval "$1"
	else
		echo -e "\n${G_COLORS['red']}ERROR: command empty !${G_COLORS['clear']}"
	fi
}

# main: generate command's for execution
# param: $1-$9=command's 
func_menu_cmd_exec() {
	
	# block scrolling
	clear

	# variables
	local RES
	local RES_Q

	# message: command header
	local MSG_C0="${G_COLORS['blue']}##############################\n${G_COLORS['yellow']}Auto-Command-Tool\nVersion: ${G_ARR_CONF['script_version']}\n${G_ARR_CONF['script_copyrights']}\n${G_COLORS['blue']}##############################\n"
	
	# message: command
	local MSG_C1="${G_COLORS['green']}--- command["
	local MSG_C2="]${G_COLORS['yellow']}("
	local MSG_C3=")${G_COLORS['green']} - execute ...${G_COLORS['clear']}"
	
	# message: question
	local MSG_Q_CHARS="${G_COLORS['yellow']}( ${G_COLORS['green']}y${G_COLORS['clear']}es, ${G_COLORS['yellow']}s${G_COLORS['clear']}kip, ${G_COLORS['red']}c${G_COLORS['clear']}ancel${G_COLORS['yellow']} ) ? ${G_COLORS['clear']}"
	local MSG_Q="${G_COLORS['cyan']}Would you like execute command ${MSG_Q_CHARS}"

	# input: cancel
	local INP_CANCEL="false"

	# set: ini-file for function
	G_INI_FILE_SEL="${G_ARR_CONF['file_settings']}"

	# get: setting: main command confirm
	local CMD_Q=$( func_ini_file "r" "setting_4" "val" )

	# check: result: emtpy default true
	[ "${CMD_Q}" = "" ] && CMD_Q="true"
	# argument($1=[true,false]): set for question
	# echo -e "---\nquestion result: ${CMD_Q}\n---\n"

	# variables
	local TMP
	local ARR_C=0

	# display: header information
	echo -e "${MSG_C0}"

	# function: get argument's, format: array
	local ARR_ARGS=("$@")

	# loop: command's
	for (( i = 1; i < "${#ARR_ARGS[@]}"; i++ )); do
		# display: array counter, step 1
		((ARR_C++))

		# command: header
		echo -e "${MSG_C1}${ARR_C}${MSG_C2}${ARR_ARGS[$i]}${MSG_C3}"

		# command: check confirm
		if [ "${CMD_Q}" = "true" ]; then
			# display: question
			echo -e -n "${MSG_Q}"
			
			# loop: check correct input ([y]es, [s]kip, [c]ancel)
			while true; do
				# read: input
				read RES

				# check: result
				if [ "${RES}" = "y" ] || [ "${RES}" = "s" ] || [ "${RES}" = "c" ]; then
					RES_Q="${RES}"
					break
				else
					echo -e -n "${G_COLORS['red']}FALSE input! allowed char's ${MSG_Q_CHARS}"
				fi
			done

			# check: correct input
			if [ "${RES_Q}" = "s" ]; then
				echo -e "${G_COLORS['red']}SKIP command[${ARR_C}]...${G_COLORS['clear']}"
				
				# skip
				TMP=$(( $i + 1 ))
				# check next id, if lower array length: exit loop
				if [ $TMP -lt "${#ARR_ARGS[@]}" ]; then
					# loop continue
					continue
				else
					# skip: lower array length
					break
				fi
			elif [ "${RES}" = "c" ]; then
				# cancel
				echo -e "${G_COLORS['red']}CANCEL execution...${G_COLORS['clear']}"
				break
			fi
		fi

		# check: execution: no confirm or confirm result: yes
		if [ "${CMD_Q}" = "false" ] || [ "${RES_Q}" = "y" ]; then
			# command: execute, next step
			func_cmd_exec "${ARR_ARGS[$i]}"
		fi
	done

	# loop: end: sleep
	echo -e -n "\n${G_COLORS['yellow']}Forward with key [Enter] ..."
	read
}

# display: command execution - header
func_act_cmd_exec_header() {
	
	# block scrolling
	clear

	# message: command header
	echo -e "${G_COLORS['blue']}##############################\n${G_COLORS['yellow']}Auto-Command-Tool\nVersion: ${G_ARR_CONF['script_version']}\n${G_ARR_CONF['script_copyrights']}\n${G_COLORS['blue']}##############################\n"
}

# act-file: generate command's for execution
# param: $1=command_count, $2=command_id, $3=command, $4=command_description, $5=confirm_execution 
func_act_cmd_exec() {
	
	# variables
	local RES
	local RES_Q

	# message: command_x
	local MSG="${G_COLORS['green']}--- command[$2 of $1]${G_COLORS['yellow']}($3)${G_COLORS['green']} - execute(confirm:$5) ...${G_COLORS['clear']}"
	local MSG+="${G_COLORS['yellow']}Description:${G_COLORS['clear']} $4"

	# message: question: command_x
	local MSG_Q_CHARS="${G_COLORS['yellow']}( ${G_COLORS['green']}y${G_COLORS['clear']}es, ${G_COLORS['yellow']}s${G_COLORS['clear']}kip, ${G_COLORS['red']}c${G_COLORS['clear']}ancel${G_COLORS['yellow']} ) ? ${G_COLORS['clear']}"
	local MSG_Q="${G_COLORS['yellow']}Would you like execute command ${MSG_Q_CHARS}"

	# display: command
	echo -e "${MSG}"

	# command: check confirm
	if [ "${5}" = "true" ]; then
		echo -e -n "${MSG_Q}"

		# loop: check correct input ([y]es, [s]kip, [c]ancel)
		while true; do
			read RES
			if [ "${RES}" = "y" ] || [ "${RES}" = "s" ] || [ "${RES}" = "c" ]; then
				RES_Q="${RES}"
				break
			else
				echo -e -n "${G_COLORS['red']}FALSE input! allowed char's ${MSG_Q_CHARS}"
			fi
		done

		# check: correct input
		if [ "${RES_Q}" = "s" ]; then
			# skip
			echo -e "${G_COLORS['red']}SKIP command[${2}]...${G_COLORS['clear']}"
			continue
		elif [ "${RES}" = "c" ]; then
			# cancel
			echo -e "${G_COLORS['red']}CANCEL execution...${G_COLORS['clear']}"
			break
		fi
	fi

	# check: execution: no confirm or question result: yes
	if [ "${5}" = "false" ] || [ "${RES_Q}" = "y" ]; then
		# command: execute, next step
		func_cmd_exec "${3}"
	fi
	
	# loop: end: sleep
	echo -e -n "\n${G_COLORS['yellow']}Forward with key [Enter] ..."
	read
}


# ####################################################################################################
# menu: main: reboot
# ####################################################################################################

# menu: dialog: reboot
# param: $1=command
func_menu_reboot() {
	
	# block scrolling
	clear

	# variables
	local DLG_TITLE="Confirm"
	local DLG_MSG="\Z4Would you like \Z1SYSTEM - REBOOT\Z4 ?\Zn"

	# message: confirm
	# param: 1:title, 2:message, 3:height, 4:width
	func_msgbox_yn "${DLG_TITLE}" "${DLG_MSG}" 7 40

	# check: result
	if [ $G_FUNC_RET_VAL = 0 ]; then
		# yes
		func_infobox "INFO" "\Z1System is restarted...\Zn"
		# sudo reboot
		$1
		exit
	fi
}


# ####################################################################################################
# menu: main: poweroff
# ####################################################################################################

# menu: dialog: poweroff
# param: $1=command
func_menu_poweroff() {
	
	# block scrolling
	clear

	# variables
	local DLG_TITLE="Confirm"
	local DLG_MSG="\Z4Would you like \Z1SYSTEM - SHUTDOWN\Z4 ?\Zn"
	local RES

	# message: confirm
	# param: 1:title, 2:message, 3:height, 4:width
	func_msgbox_yn "${DLG_TITLE}" "${DLG_MSG}" 7 43

	# check: result
	if [ $G_FUNC_RET_VAL = 0 ]; then
		# yes
		func_infobox "INFO" "\Z1System is shutting down...\Zn"
		# sudo poweroff
		$1
		exit
	fi
}


# ####################################################################################################
# menu: main: exit
# ####################################################################################################

func_menu_exit() {
	
	# variables
	local MSG="\Z4Exit Script - good bye!"
	
	# messagebox: exit
	func_msgbox "INFO" "${MSG}"

	# clear and exit script
	clear
	exit
}


# ####################################################################################################
# script init
# ####################################################################################################

func_menu_main


# ####################################################################################################
# script exit
# ####################################################################################################

exit
