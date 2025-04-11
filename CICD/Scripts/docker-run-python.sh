@#!/bin/bash@
echo "$(pwd)"
set -xe
ANSIBLE_IMAGE="${NEXUS_BASE_URL}/siebel-cicd/ansible:ansible-2.7-python-jira-python-jenkins-git"
echo ANSIBLE_IMAGE
# chown -R jenkins-agent:jenkins-agent .
docker run --rm  \
    --mount "type=bind,src=$(pwd),target=/opt" \
    -e LANG=$LANG \
    -e LOCAL_USER=$USER \
    -e LOCAL_USER_ID=`id -u $USER` \
    -e LOCAL_GROUP_ID=`id -g $USER` \
    -e ENVIRONMENT \
    -e TASKS_LIMIT \
    -e jenkins_gitlab \
    -e JIRA_USER \
    -e JIRA_PASS \
    ${ANSIBLE_IMAGE} \
    -c "python3 /opt/scripts/check_tasks.py ${ENVIRONMENT} ${TASKS_LIMIT} ${jenkins_gitlab} ${JIRA_USER} ${JIRA_PASS}"