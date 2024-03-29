_includeFile=$(type -p overrides.inc)
# Import ocFunctions.inc for getSecret
_ocFunctions=$(type -p ocFunctions.inc)
if [ ! -z ${_includeFile} ]; then
  . ${_ocFunctions}
  . ${_includeFile}
else
  _red='\033[0;31m'; _yellow='\033[1;33m'; _nc='\033[0m'; echo -e \\n"${_red}overrides.inc could not be found on the path.${_nc}\n${_yellow}Please ensure the openshift-developer-tools are installed on and registered on your path.${_nc}\n${_yellow}https://github.com/BCDevOps/openshift-developer-tools${_nc}"; exit 1;
fi

OUTPUT_FORMAT=json

# Generate Blacklist Config Map
# Injected by genDepls.sh
# - BLACK_LIST_CONFIG_MAP_NAME
# - SUFFIX
CONFIG_MAP_NAME=${BLACK_LIST_CONFIG_MAP_NAME}${SUFFIX}
SOURCE_FILE=$( dirname "$0" )/config/blacklist.conf
OUTPUT_FILE=${CONFIG_MAP_NAME}-configmap_DeploymentConfig.json
printStatusMsg "Generating ConfigMap; ${CONFIG_MAP_NAME} ..."
generateConfigMap "${CONFIG_MAP_NAME}" "${SOURCE_FILE}" "${OUTPUT_FORMAT}" "${OUTPUT_FILE}"

# Generate nginx.conf.template Config Map
# Injected by genDepls.sh
# - NGINX_CONF_TEMPLATE_CONFIG_MAP_NAME
# - SUFFIX
CONFIG_MAP_NAME=${NGINX_CONF_TEMPLATE_CONFIG_MAP_NAME}${SUFFIX}
SOURCE_FILE=$( dirname "$0" )/config/nginx.conf.template
OUTPUT_FILE=${CONFIG_MAP_NAME}-configmap_DeploymentConfig.json
printStatusMsg "Generating ConfigMap; ${CONFIG_MAP_NAME} ..."
generateConfigMap "${CONFIG_MAP_NAME}" "${SOURCE_FILE}" "${OUTPUT_FORMAT}" "${OUTPUT_FILE}"

if createOperation; then
  readParameter "ALLOW_LIST - Please enter the list of trusted IP addresses that should be allowed to access the application's route (as a space delimited list of IP addresses):" "ALLOW_LIST" "" "false"
  # Get Splunk settings
  readParameter "SPLUNK_COLLECTOR_URL - Please provide the Splunk collector URL." SPLUNK_COLLECTOR_URL "" "false"
  readParameter "SPLUNK_TOKEN - Please provide the Splunk token." SPLUNK_TOKEN "" "false"
else
  # Get ALLOW_LIST from secret
  printStatusMsg "Getting allow list from secret ...\n"
  writeParameter "ALLOW_LIST" "$(getSecret "${NAME}${SUFFIX}" "allow-list")" "false"
  writeParameter "SPLUNK_COLLECTOR_URL" "prompt_skipped" "false"
  writeParameter "SPLUNK_TOKEN" "prompt_skipped" "false"
fi

SPECIALDEPLOYPARMS="--param-file=${_overrideParamFile}"
echo ${SPECIALDEPLOYPARMS}