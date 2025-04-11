@#!/bin/bash@
 
echo "$(pwd)"
set -xe
 
#docker login -u $SIEBEL_NEXUS_USR -p $SIEBEL_NEXUS_PSW $NEXUS_BASE_URL
#docker login -u $SIEBEL_AD_USER -p $SIEBEL_AD_PASS nexus.trosbank.trus.tsocgen
 
ANSIBLE_ARGS=${@}
ANSIBLE_IMAGE="${NEXUS_BASE_URL}/siebel-cicd/ansible:ansible-2.7-python-jira-python-jenkins-git"
export CURL_CA_BUNDLE=""
 
export DEPLOY_BASE_DIR="/tmp/siebel-deploy"
 
# Running job without rsa creds
if [ -z "${SIEBEL_SSH_KEY_FILE}" ]; then
    touch /tmp/empty_rsa
    SIEBEL_SSH_KEY_FILE="/tmp/empty_rsa"
fi
 
releasebranchfolder="/home/jenkins-agent/releasebranchlog"
if ! [ -d $releasebranchfolder ];
then
mkdir $releasebranchfolder
chown -R jenkins-agent:jenkins-agent $releasebranchfolder
echo "$releasebranchfolder"
fi
 
temp_for_git="/home/jenkins-agent/temp_for_git"
if ! [ -d $temp_for_git ];
then
mkdir $temp_for_git
chown -R jenkins-agent:jenkins-agent $temp_for_git
echo "$temp_for_git"
fi
 
docker run --rm \
    --mount "type=bind,src=$(pwd),target=${DEPLOY_BASE_DIR}" \
            --mount "type=bind,src=$releasebranchfolder,target=${DEPLOY_BASE_DIR}/releasebranchlog" \
    --mount "type=bind,src=$temp_for_git,target=${DEPLOY_BASE_DIR}/temp_for_git" \
    --mount "type=bind,src=${SIEBEL_SSH_KEY_FILE},target=/tmp/siebel_ssh_private_key,readonly" \
    -w ${DEPLOY_BASE_DIR} \
    -e LANG=$LANG \
    -e LOCAL_USER=$USER \
    -e LOCAL_USER_ID=`id -u $USER` \
    -e LOCAL_GROUP_ID=`id -g $USER` \
    -e "SIEBEL_AD_USER" -e "SIEBEL_AD_PASS" \
    -e "SIEBEL_ACC_USER" -e "SIEBEL_ACC_PASS" \
    -e "SIEBEL_DB_USER" -e "SIEBEL_DB_PASS" \
            -e "SIEBEL_STG_USER" -e "SIEBEL_STG_PASS" \
    -e "ROCKETSIEBEL_USER" -e "ROCKETSIEBEL_PASS" \
    -e "JIRA_USER" -e "JIRA_PASS" \
    -e "PATCH_NAME" \
    -e "JENKINS_USER" -e "JENKINS_PASS" \
    -e "DATE_TIME" \
            -e "ENVIRONMENT" \
    -e "GENERATE_PATCH_NAME" \
    -e "CURL_CA_BUNDLE" \
    -e "LIST_STATUS_TASKS_JIRA" \
    -e "NEXUS_BASE_URL" \
    -e "SIEBEL_NEXUS_USR" -e "SIEBEL_NEXUS_PSW" \
            -e "GITLAB_USER" -e "GITLAB_PASS" \
    -e "APIM_CONSUMER_KEY" \
    -e "APIM_CONSUMER_SECRET" \
    -e "TG_DEBUG_BOT_TOKEN" \
    -e "TG_DEBUG_GROUP_ID" \
    -e "TIME_FOR_RESOLVE" \
    -e "MY_RESULT" \
    -e "BUILD_NUMBER" \
            -e "INITIATOR_EMAIL" \
    -e "PUSH" \
    -e "RELEASE_BRANCH" \
    -e "ENVIRONMENT_MINOR" \
    -e "GIT_TASKS" \
            -e "SKIP_CREATE_SIEBEL_PATCH" \
    -e "SKIP_RESTART_SIEBEL_COMPONENT" \
            -e "THE_PATCH_IN_ROCKET_SIEBEL_ALREADY_BEEN_BUILT" \
            -e "SKIP_SET_STATUS_TASKS_IN_JIRA" \
            -e "SIEBEL_SERVERS_FOR_RESTART_COMP" \
            -e "SIEBEL_COMPONENTS_FOR_RESTART" \
            -e "FIND_CONTEXT" \
            -e "NEWERMT_BEGIN" \
            -e "NEWERMT_END" \
    ${ANSIBLE_IMAGE} \
    -c "echo TG_DEBUG_BOT_TOKEN=$TG_DEBUG_BOT_TOKEN && echo TG_DEBUG_GROUP_ID=$TG_DEBUG_GROUP_ID && ANSIBLE_SHOW_CUSTOM_STATS="true" \
    ansible-playbook -vv --diff -i ./ansible/environments/${ENVIRONMENT}/inventory.yml \
    --ssh-common-args '-o StrictHostKeyChecking=no' \
    ./ansible/playbooks/${ANSIBLE_ARGS}"