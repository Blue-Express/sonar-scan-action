#!/usr/bin/env bash
# this script checks the status of a quality gate for a particular analysisID
# approach taken from https://docs.sonarqube.org/display/SONARQUBE53/Breaking+the+CI+Build
# When SonarScanner executes, the compute engine task is given an id
# The status of this task, and analysisId for the task can be checked at
# /api/ce/task?id=taskid
# When the status is SUCCESS, the quality gate status can be checked at
# /api/qualitygates/project_status?analysisId=analysisId

SONAR_INSTANCE="${1}"
SONAR_ACCESS_TOKEN="${2}"
ce_task_id="${3}"
SLEEP_TIME=5

echo "SC Script --> Using SonarQube instance ${SONAR_INSTANCE}"
echo "SC Script --> Using SonarQube access token ${SONAR_ACCESS_TOKEN}"

# grab the status of the task
# if CANCELLED or FAILED, fail the Build
# if SUCCESS, stop waiting and grab the analysisId
wait_for_success=true

while [ "${wait_for_success}" = "true" ]
do
  ce_status=$(curl -s -u "${SONAR_ACCESS_TOKEN}": "${SONAR_INSTANCE}"/api/ce/task?id=${ce_task_id} | jq -r .task.status)

  echo "SC Script --> Status of SonarQube task is ${ce_status}"

  if [ "${ce_status}" = "CANCELLED" ]; then
    echo "SC Script --> SonarQube Compute job has been cancelled - exiting with error"
    exit 1
  fi

  if [ "${ce_status}" = "FAILED" ]; then
    echo "SC Script --> SonarQube Compute job has failed - exiting with error"
    exit 1
  fi

  if [ "${ce_status}" = "SUCCESS" ]; then
    wait_for_success=false
  fi

  sleep "${SLEEP_TIME}"

done

ce_analysis_id=$(curl -s -u $SONAR_ACCESS_TOKEN: $SONAR_INSTANCE/api/ce/task?id=$ce_task_id | jq -r .task.analysisId)
echo "SC Script --> Using analysis id of ${ce_analysis_id}"

# get the status of the quality gate for this analysisId
qg_status=$(curl -s -u $SONAR_ACCESS_TOKEN: $SONAR_INSTANCE/api/qualitygates/project_status?analysisId="${ce_analysis_id}" | jq -r .projectStatus.status)
echo "SC Script --> Quality Gate status is ${qg_status}"

if [ "${qg_status}" != "OK" ]; then
  echo "SC Script --> Quality gate is not OK - exiting with error"
  exit 1
fi