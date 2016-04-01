#!/bin/bash - 
#===============================================================================
#
#          FILE:  check_chef_fatal.sh
# 
#         USAGE:  ./check_chef_fatal.sh 
# 
#   DESCRIPTION:  check for fatal errors in the Chef logs and event if
#                 certain conditions are met.
#
# 
#  REQUIREMENTS:  ---
#          BUGS:  None Known.
#         NOTES:  ---
#        AUTHOR: Christopher Hubbard (CSH), chubbard@marchex.com
#       COMPANY: Marchex
#       CREATED: 10-15-13 03:20:43 PM PDT
#      REVISION: Debbie
#       VERSION: 1.0.4
#===============================================================================

# set -o nounset      # Treat unset variables as an error
# set -x              # DEBUG MODE

PATH=${PATH}:/usr/sbin:/usr/bin

canonicalpath=`readlink -f $0`
canonicaldirname=`dirname ${canonicalpath}`/..
samedirname=`dirname ${canonicalpath}`

#==============================================================================
# Define a base useage case for a -h option
#==============================================================================
usage(){
cat << EOF
Usage: $0 Options

This script will look in the chef log files watching for the word FATAL.  If
it finds a match depending on the reason for the fatal as defined in a whitelist 
it will alarm as a critical or a warning class event.

The initial check before log validation is if the client is even running on the
host.  If not all additional checks are not relevant.

The secondary alarming for -w and -c are basic counters.  If there are more
than these number of errors in the logs an event will fire, even if there is no
match in the whitelist.

Options:
-h  Show this help screen
-x  enable debug mode
-a  Add fatal messages to error counts for alarm thresholding
-W  path to the whitelist file (Not implemented at this time)
-l  path to the chef log file (if not /var/log/chef/client.log)
-w  set secondary warning level
-c  set secondary critical level

Example:
$0 -W /site/general-nrpe/templates/chef_white_list.lst -w 1 -c 2
Status OK - No fatal checks have occured since last check
Status CRITICAL - 2 FATAL errors found in log: /var/log/chef.log


EOF
}

#===  FUNCTION  ================================================================
#          NAME:  verify_deps
#   DESCRIPTION:  Check that all binary files are available to be used
#    PARAMETERS:  None.  This is standalone.  Changes occur on case by case
#       RETURNS:  none
#===============================================================================
verify_deps() {
# needed="xmllint curl w3m snmptrap cut egrep expr"
needed="logtail grep awk sed"
for i in `echo $needed`
do
  type $i >/dev/null 2>&1
  if [ $? -eq 1 ]; then
    echo "Status WARNING - I am missing manditory component: $i"; exit 1
  fi
done
}

#===  FUNCTION  ================================================================
#          NAME:  stack
#   DESCRIPTION:  Look for a stacktrace file when we are in a critical or warn state.
#    PARAMETERS:  None, use globals.
#       RETURNS:  None, update existing VAR SUMMARY
#===============================================================================
stack() {
FILE='/var/chef/cache/chef-stacktrace.out'
if [ -e "${FILE}" ];then
  RETURNS=$(cat ${FILE} | grep -v '^/\|^Gene')
  if [ `echo "${RETURNS}" | wc -c` -gt 5 ];then
    SUMMARY="${RETURNS}"
  fi
fi

}

WHITELIST=''
LOG=''
WARN=1
CRIT=1
ADD='FALSE'

# This script is going to live in the general-nrpe dir, so we know where 
# common seek files are going to be at.  Use the normal pathing
SEEK="${canonicaldirname}/var/chef_fatal.seek"

while getopts "ahxw:W:l:c:" OPTION
do
  case ${OPTION} in
    h) usage; exit 0        ;;
    x) set -x               ;;
    a) ADD='TRUE'           ;;
    W) WHITELIST="${OPTARG}";;
    w) WARN="${OPTARG}"     ;;
    c) CRIT="${OPTARG}"     ;;
    l) LOG="${OPTARG}"      ;;
    *) echo "Status UNKNOWN - Unexpected argument given."; exit 3;;
  esac
done

if [[ -z ${LOG} ]];then
  LOG='/var/log/chef/client.log'
fi

if [ ! -e "${LOG}" ];then
  echo "Status UNKNOWN - cannot find logfile ${LOG}"; exit 3
fi

# Confirm that all binaries are available.
verify_deps

RUNNING=$(ps aux | grep -c [c]hef-client)
if [ ${RUNNING} -lt 1 ];then
  echo "Status CRITICAL - chef-client not running on `hostname`"; exit 2
fi

# Check if the file is stale
DATE_RAW=$(stat "${LOG}" | grep Modify | sed -e 's/\..*//' -e 's/.*.y: //')
DATE_THEN=$(date -d "-6 hours" +%s)
DATE_CHECK=$(date -d "${DATE_RAW}" +%s)
if [ `echo "${DATE_CHECK} <= ${DATE_THEN}" | bc` -gt 0 ];then
  echo "Status WARNING - ${LOG} has not been updated recently.  Chef is likely hung"; exit 1
fi

# Grab the last 20 lines of logs.  We do not care
# about the run details, just looking for failures of some kind
# both errors and fatals.
RAW=$(tail -20 "${LOG}")

FATAL=$(echo -e "${RAW}" | grep -c "[F]ATAL")
WARNS=$(echo -e "${RAW}" | grep -c "[W]ARN")
ERRORS=$(echo -e "${RAW}" | grep -c "[E]RROR")
DEPRECATION=$(echo -e "${RAW}" | grep -c "[D]EPRECATION")
if [ "${ADD}" == "TRUE" ];then
  COUNT=$(( ${FATAL} + ${ERRORS} ))
else
  COUNT=${FATAL}
fi

if [[ ${COUNT} -ge ${CRIT} ]];then
  SUMMARY="Chef run had ${COUNT} fatal/errors in the last 20 lines of logs"
  stack
  EXIT='2'
  STATUS='CRITICAL'
  PERF="deprecation=${DEPRECATION} warn=${WARNS} errors=${ERRORS} fatal=${FATAL}"
elif [[ ${COUNT} -ge ${WARN} ]];then
  SUMMARY="Chef run had ${COUNT} fatal/errors in the last 20 lines of logs"
  stack
  EXIT='1'
  STATUS='WARNING'
  PERF="deprecation=${DEPRECATION} warn=${WARNS} errors=${ERRORS} fatal=${FATAL}"
else
  SUMMARY="Chef run had ${COUNT} fatal/errors in the last 20 lines of logs" 
  exit='0'
  STATUS='OK'
  PERF="deprecation=${DEPRECATION} warn=${WARNS} errors=${ERRORS} fatal=${FATAL}"
fi

# Use a generic return as we are going to get chatty with the summary
echo "Status ${STATUS} - ${SUMMARY} | ${PERF}"; exit ${EXIT}

# If we ever get to this point there is a serious problem
echo "Status UNKNOWN - Unexpected script error using $@"; exit 3



