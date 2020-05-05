_includeFile=$(type -p overrides.inc)
if [ ! -z ${_includeFile} ]; then
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

unset SPECIALDEPLOYPARMS
echo ${SPECIALDEPLOYPARMS}