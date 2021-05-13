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
  # Generate a random encryption key
  printStatusMsg "Creating a set of random keys ..."
  writeParameter "DATA_PROTECTION_ENCRYPTION_KEY" $(generateKey 32 | fold -w 32 | head -n 1) "false"

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
  readParameter "REQUEST_GET_USER_LOGIN_DEFAULT_AGENCY_ID - Please provide the Request Get User Login Default Agency Id for use with the File Services API.  The default is a randomly gererated value." REQUEST_GET_USER_LOGIN_DEFAULT_AGENCY_ID $(generatePassword) "false"
  readParameter "ALLOW_SITE_MINDER_USER_TYPE - Please provide the Allowed SiteMinder User Type for the application.  The default is a blank string." ALLOW_SITE_MINDER_USER_TYPE "" "false"

  # Get KeyCloak settings
  readParameter "KEYCLOAK_AUTHORITY - Please provide the endpoint (URL) for the OIDC relaying party." KEYCLOAK_AUTHORITY "" "false" 
  readParameter "KEYCLOAK_SECRET - Please provide the API secret toi use with the OIDC relaying party." KEYCLOAK_SECRET "" "false" 
  readParameter "KEYCLOAK_PRES_REQ_CONF_ID - Please provide the KeyCloak Presentation request Configuration Id." KEYCLOAK_PRES_REQ_CONF_ID "" "false"
  readParameter "KEYCLOAK_IDP_HINT - Please provide the KeyCloak hint for login." KEYCLOAK_IDP_HINT "" "false"
  readParameter "SITEMINDER_LOGOUT_URL - Please provide the SiteMinder Logout URL." SITEMINDER_LOGOUT_URL "" "false" 
else
  printStatusMsg "Update operation detected ...\nSkipping the generation of keys ...\n"
  writeParameter "DATA_PROTECTION_ENCRYPTION_KEY" "generation_skipped" "false"

  # Secrets are removed from the configurations during update operations ...
  writeParameter "REQUEST_PART_ID" "prompt_skipped" "false"
  printStatusMsg "Update operation detected ...\nSkipping the generation of random user credentials.\nSkipping the prompts for FILE_SERVICES_CLIENT_URL, FILE_SERVICES_CLIENT_USERNAME, FILE_SERVICES_CLIENT_PASSWORD, REQUEST_APPLICATION_CODE, REQUEST_AGENCY_IDENTIFIER_ID, ALLOW_SITE_MINDER_USER_TYPE, KEYCLOAK_AUTHORITY, KEYCLOAK_SECRET, KEYCLOAK_PRES_REQ_CONF_ID, KEYCLOAK_IDP_HINT, and SITEMINDER_LOGOUT_URL secrets ...\n"
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
  writeParameter "REQUEST_GET_USER_LOGIN_DEFAULT_AGENCY_ID" "prompt_skipped" "false"
  writeParameter "ALLOW_SITE_MINDER_USER_TYPE" "prompt_skipped" "false"

  writeParameter "KEYCLOAK_AUTHORITY" "prompt_skipped" "false"
  writeParameter "KEYCLOAK_SECRET" "prompt_skipped" "false"
  writeParameter "KEYCLOAK_PRES_REQ_CONF_ID" "prompt_skipped" "false"
  writeParameter "KEYCLOAK_IDP_HINT" "prompt_skipped" "false"
  writeParameter "SITEMINDER_LOGOUT_URL" "prompt_skipped" "false"
fi

SPECIALDEPLOYPARMS="--param-file=${_overrideParamFile}"
echo ${SPECIALDEPLOYPARMS}