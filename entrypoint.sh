#!/bin/bash
# This script executes sonar-scanner for the conifgured GitHub project,
# then recovers the task id from the scan report and check the result
# according to the Quality Gate in Sonar.
set -euo pipefail

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
	EVENT_ACTION=$(jq -r ".action" "${GITHUB_EVENT_PATH}")
	if [[ "${EVENT_ACTION}" != "opened" ]]; then
		echo "SC Script --> No need to run analysis. It is already triggered by the push event."
		exit
	fi
fi

projectKey=${INPUT_PROJECTKEY}
echo "SC Script --> Executing sonar-scanner $projectKey"

REPOSITORY_NAME=$(basename "${GITHUB_REPOSITORY}")

if [[ ! -f "${GITHUB_WORKSPACE}/sonar-project.properties" ]]; then
  [[ -z ${INPUT_PROJECTKEY} ]] && SONAR_PROJECTKEY="${REPOSITORY_NAME}" || SONAR_PROJECTKEY="${INPUT_PROJECTKEY}"
  [[ -z ${INPUT_PROJECTNAME} ]] && SONAR_PROJECTNAME="${REPOSITORY_NAME}" || SONAR_PROJECTNAME="${INPUT_PROJECTNAME}"
  [[ -z ${INPUT_PROJECTVERSION} ]] && SONAR_PROJECTVERSION="" || SONAR_PROJECTVERSION="${INPUT_PROJECTVERSION}"
  sonar-scanner \
    -Dsonar.host.url=${INPUT_SONARQUBE_URL} \
    -Dsonar.projectKey=${SONAR_PROJECTKEY} \
    -Dsonar.projectName=${SONAR_PROJECTNAME} \
    -Dsonar.projectVersion=${SONAR_PROJECTVERSION} \
    -Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} \
    -Dsonar.login=${INPUT_SONARQUBE_TOKEN} \
    -Dsonar.password="" \
    -Dsonar.sources=. \
    -Dsonar.sourceEncoding=UTF-8
else
  sonar-scanner \
    -Dsonar.host.url=${INPUT_SONARQUBE_URL} \
    -Dsonar.projectBaseDir=${INPUT_PROJECTBASEDIR} \
    -Dsonar.login=${INPUT_SONARQUBE_TOKEN} \
    -Dsonar.password="" \
    -Dsonar.exclusions=${INPUT_BINARIES}
fi

path=".scannerwork/report-task.txt"
taskIdProperty="ceTaskId"

echo "SC Script --> Retrieving $taskIdProperty from $path"

result=$(sed -n "/^[[:space:]]*$taskIdProperty[[:space:]]*=[[:space:]]*/s/^[[:space:]]*$taskIdProperty[[:space:]]*=[[:space:]]*//p" "$path")

echo "SC Script --> $taskIdProperty value: $result"

echo "SC Script --> Executing break_build.sh...."

sh /break_build.sh ${INPUT_SONARQUBE_URL} ${INPUT_SONARQUBE_TOKEN} $result
