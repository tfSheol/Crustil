#!/usr/bin/env bash

set -e

typeset -A config
typeset -A param

setParam() {
	if [[ "$3" == "" ]]; then
		echo "= set ${1} to ${2}"
	fi
	[[ ${1} = [\#!]* ]] || [[ ${1} = "" ]] || param[$1]=${2}
}

# Default config
setParam "config.file.path" "./" 0
setParam "config.file.name" "build.properties" 0

if [[ " $@ " =~ --config-path=([^' ']+) ]]; then
  setParam "config.file.path" ${BASH_REMATCH[1]}
fi

if [[ " $@ " =~ --config-name=([^' ']+) ]]; then
  setParam "config.file.name" ${BASH_REMATCH[1]}
fi

if [[ ! -f "${param['config.file.path']}/${param['config.file.name']}" ]]; then
	echo "error: config file not found !"
	exit -1
fi

while IFS=$':= \t' read key value; do
	if [[ "$key" != "" ]]; then
  	[[ ${key} = [\#!]* ]] || [[ ${key} = "" ]] || config[$key]=${value}
	fi
done < "${param['config.file.path']}/${param['config.file.name']}"

echo -e "======== Build properties ========"
echo -e "project.name \t ${config['project.name']}"
echo -e "registry \t ${config['registry']}"
echo -e "version \t ${config['version']}"
echo -e "dashboard.name \t ${config['dashboard.name']}"
echo -e "==================================="

docker build --build-arg DASHBOARD=${config['dashboard.name']} -t "${config['project.name']}" -f ./Dockerfile .

if [[ " $@ " == *" --tag "* ]]; then
	echo "tag: ${config['version']}"
	docker tag "${config['project.name']}" "${config['registry']}/${config['project.name']}:${config['version']}"
	echo "tag: latest"
	docker tag "${config['project.name']}" "${config['registry']}/${config['project.name']}:latest"
fi

if [[ " $@ " == *" --push "* ]]; then
	echo "push: ${config['version']} version to ${config['registry']}"
	docker push "${config['registry']}/${config['project.name']}:${config['version']}"
	echo "push: latest version to ${config['registry']}"
	docker push "${config['registry']}/${config['project.name']}:latest"
fi
