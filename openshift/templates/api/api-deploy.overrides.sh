_includeFile=$(type -p overrides.inc)
if [ ! -z ${_includeFile} ]; then
  . ${_includeFile}
else
  _red='\033[0;31m'; _yellow='\033[1;33m'; _nc='\033[0m'; echo -e \\n"${_red}overrides.inc could not be found on the path.${_nc}\n${_yellow}Please ensure the openshift-developer-tools are installed on and registered on your path.${_nc}\n${_yellow}https://github.com/BCDevOps/openshift-developer-tools${_nc}"; exit 1;
fi

# ================================================================================================================
# Special deployment parameters needed for injecting a user supplied settings into the deployment configuration
# ----------------------------------------------------------------------------------------------------------------
# The results need to be encoded as OpenShift template parameters for use with oc process.
# ================================================================================================================

if createOperation; then
  # Randomly generate a set of credentials without asking ...
  printStatusMsg "Creating a set of random user credentials ..."
  writeParameter "USER_ID" $(generateUsername) "false"
  writeParameter "USER_PASSWORD" $(generatePassword) "false"
  writeParameter "ADMIN_USER_ID" $(generateUsername) "false"
  writeParameter "ADMIN_PASSWORD" $(generatePassword) "false"

  # Get the settings for file services client ...
  readParameter "FILE_SERVICES_CLIENT_URL - Please provide the URL to the File Services API.  The default is a blank string." FILE_SERVICES_CLIENT_URL "" "false"
  readParameter "FILE_SERVICES_CLIENT_USERNAME - Please provide the username for use with the File Services API.  The default is a randomly gererated username." FILE_SERVICES_CLIENT_USERNAME $(generateUsername) "false"
  readParameter "FILE_SERVICES_CLIENT_PASSWORD - Please provide the password for use with the File Services API.  The default is a randomly gererated password." FILE_SERVICES_CLIENT_PASSWORD $(generatePassword) "false"
  readParameter "REQUEST_APPLICATION_CODE - Please provide the Request Application Code for use with the File Services API.  The default is 'not-set'." REQUEST_APPLICATION_CODE "not-set" "false"
  readParameter "REQUEST_AGENCY_IDENTIFIER_ID - Please provide the Request Agency Identifier Id for use with the File Services API.  The default is a randomly gererated value." REQUEST_AGENCY_IDENTIFIER_ID $(generatePassword) "false"
  readParameter "REQUEST_PART_ID - Please provide the Request Part Id for use with the File Services API.  The default is a randomly gererated value." REQUEST_PART_ID $(generatePassword) "false"
else
  # Secrets are removed from the configurations during update operations ...
  writeParameter "REQUEST_PART_ID" "prompt_skipped" "false"
  printStatusMsg "Update operation detected ...\nSkipping the generation of random user credentials.\nSkipping the prompts for FILE_SERVICES_CLIENT_URL, FILE_SERVICES_CLIENT_USERNAME, FILE_SERVICES_CLIENT_PASSWORD, REQUEST_APPLICATION_CODE, REQUEST_AGENCY_IDENTIFIER_ID, and secrets ...\n"
  writeParameter "USER_ID" "generation_skipped" "false"
  writeParameter "USER_PASSWORD" "generation_skipped" "false"
  writeParameter "ADMIN_USER_ID" "generation_skipped" "false"
  writeParameter "ADMIN_PASSWORD" "generation_skipped" "false"

  writeParameter "FILE_SERVICES_CLIENT_URL" "prompt_skipped" "false"
  writeParameter "FILE_SERVICES_CLIENT_USERNAME" "prompt_skipped" "false"
  writeParameter "FILE_SERVICES_CLIENT_PASSWORD" "prompt_skipped" "false"
  writeParameter "REQUEST_APPLICATION_CODE" "prompt_skipped" "false"
  writeParameter "REQUEST_AGENCY_IDENTIFIER_ID" "prompt_skipped" "false"
  writeParameter "REQUEST_PART_ID" "prompt_skipped" "false"
fi

SPECIALDEPLOYPARMS="--param-file=${_overrideParamFile}"
echo ${SPECIALDEPLOYPARMS}