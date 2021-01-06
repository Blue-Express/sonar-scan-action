#!/bin/bash

set -euo pipefail

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
	EVENT_ACTION=$(jq -r ".action" "${GITHUB_EVENT_PATH}")
	if [[ "${EVENT_ACTION}" != "opened" ]]; then
		echo "No need to run analysis. It is already triggered by the push event."
		exit
	fi
fi

projectKey=${INPUT_PROJECTKEY}
echo "Executing sonar-scanner $projectKey"

sonar-scanner \
-Dsonar.host.url=${INPUT_SONARQUBE_URL} \
-Dsonar.projectKey=${INPUT_PROJECTKEY} \
-Dsonar.login=${INPUT_SONARQUBE_TOKEN}

path=${INPUT_PATH}
taskIdProperty="ceTaskId"

echo "Retrieving $taskIdProperty from $path"

result=$(sed -n "/^[[:space:]]*$taskIdProperty[[:space:]]*=[[:space:]]*/s/^[[:space:]]*$taskIdProperty[[:space:]]*=[[:space:]]*//p" "$path")

echo "$taskIdProperty value: $result"

echo "Executing break_build.sh...."
sh ./break_build.sh ${INPUT_SONARQUBE_URL} ${INPUT_SONARQUBE_TOKEN} $result
