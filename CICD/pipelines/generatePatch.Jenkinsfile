pipeline {
    options {
        buildDiscarder(logRotator(
            artifactDaysToKeepStr: '14',
            artifactNumToKeepStr: '14',
            daysToKeepStr: '14',
            numToKeepStr: '40'))
        timestamps()
        disableConcurrentBuilds()
        skipDefaultCheckout()
    }
    parameters {
        string(name: 'GENERATE_PATCH_NAME', defaultValue: '', description: 'Generate patch name')
        booleanParam(name: 'SKIP_GET_ISSUE_JIRA', defaultValue: false, description: 'Should we skip "Get issue jira" stage?')
        booleanParam(name: 'SKIP_CREATE_SIEBEL_PATCH', defaultValue: false, description: 'Should we skip "Create siebel patch" stage?')
        booleanParam(name: 'SKIP_GET_CONFLICT_PATCH', defaultValue: false, description: 'Should we skip "Get conflict patch" stage?')
                        booleanParam(name: 'SKIP_SYNCHRONIZATION_OF_DIRECTORIES_ON_APP_AND_WEB_SERVERS_WITH_GIT', defaultValue: false, description: 'Should we skip "Synchronization of directories on APP and WEB servers with GIT?')
        booleanParam(name: 'SKIP_UPDATE_NRTNODEJS_ON_WEB_SERVERS_FROM_GIT', defaultValue: false, description: 'Update nrtnodejs on WEB servers from GIT?')
        booleanParam(name: 'SKIP_CREATE_RELEASE_BRANCH', defaultValue: false, description: 'Should we skip "Create release branch" stage?')
        booleanParam(name: 'SKIP_IMPORT_DOP_OBJECT', defaultValue: false, description: 'Should we skip "Import dop object"?')
        booleanParam(name: 'SKIP_SLEEP_TO_START_ROCKETSIEBEL.DEPLOY', defaultValue: false, description: 'Should we skip "Sleep to start rocketsiebel.deploy" stage?')
        string(name: 'SLEEP_TO_START_ROCKETSIEBEL_DEPLOY', defaultValue: '3600', description: 'Sleep to start ROCKETSIEBEL.DEPLOY')
        booleanParam(name: 'SKIP_RESOLVE_CONFLICT_PATCH', defaultValue: false, description: 'Should we skip "Resolve conflict patch" stage?')
        booleanParam(name: 'SKIP_MERGE_PATCH', defaultValue: false, description: 'Should we skip "Merge patch" stage?')
        booleanParam(name: 'SKIP_RESTART_SIEBEL_COMPONENT', defaultValue: false, description: 'Should we skip "Restart Siebel Component" stage?')
        booleanParam(name: 'SKIP_START_ROCKETSEIBEL_DEPLOY', defaultValue: false, description: 'Should we skip start "RocketSeibel.Deploy" pipeline?')
                        booleanParam(name: 'SKIP_MERGE_RELEASE_BRANCH', defaultValue: false, description: 'Should we skip "Merge release branch" stage?')                                                                                                                                                                                                                                                                                                                                                                                     
        booleanParam(name: 'SKIP_ADD_DEVELOPMENT_OBJECT_LABELS', defaultValue: false, description: "Should we skip \"Add 'Development object labels'\" stage?")
        booleanParam(name: 'SKIP_SEND_RESULT_COMMENTS_IN_JIRA', defaultValue: false, description: 'Should we skip "Send result comments in Jira"?')
        booleanParam(name: 'SKIP_SET_STATUS_TASKS_IN_JIRA', defaultValue: false, description: 'Should we skip "Set status tasks in Jira"?')
//      booleanParam(name: 'SKIP_BUILD_ADM_ROCKETSIEBEL_FOR_MAJOR_RELEASE', defaultValue: true, description: 'Should we skip "Build adm rocketsiebel for Major Release" stage?')
        choice(name: 'LIST_STATUS_TASKS_JIRA', choices: ['Передать на FAT; В FCT; FCT; Installation Test Done; In Testing; Исправлено;', 'UAT; В UAT; Installation Cert Done; Передать на UAT; In Testing; Testing; В тестирование; Исправлено;', 'Released; Closed; Ready To Release;'], description: 'List status task in Jira.')
        choice(name: 'ENVIRONMENT_IN', choices: ['devupg', 'test', 'cert' , 'cert_minor' , 'cert_nlt_minor', 'cert_sas_ma', 'prod_sas_ma', 'prod'], description: 'What environment to deploy?')
        choice(name: 'THE_PATCH_IN_ROCKET_SIEBEL_ALREADY_BEEN_BUILT', choices: ['No', 'Yes'], description: 'It is necessary to install the patch already assembled earlier in Rocket_Siebel. At the same time, it is not required to collect the patch.')
        string(name: 'SIEBEL_COMPONENTS_FOR_RESTART', defaultValue: 'ATCDBOPROMqSeriesSrvRcvr FLEXMqSeriesSrvRcvr MqSeriesSrvRcvr USCMqSeriesSrvRcvr USCMqSeriesSrvRcvrAsync FLEXMqDecodeSeriesSrvRcvr EAIObjMgr_ivr EAIObjMgr_rus eai_ccx eai_outletx RBDSEAIObjMgr RBDBOPROWfProcMgr RBDSWfProcMgr eai_nfo eai_bip eai_lex', description: 'Список компонент для рестарта')
        string(name: 'SIEBEL_CICD_BRANCH', defaultValue: 'master', description: 'What code branch to checkout in project SIEBEL-CICD?')
        string(name: 'SIEBEL_NRT_BRANCH', defaultValue: '', description: 'What code branch to checkout in project SIEBEL-NRT?')
        string(name: 'TASKS_LIMIT', defaultValue: '100' )       
//                     string(name: 'ROCKETSIEBEL_PATCH_NAME_FOR_BUILD_ADM_RS_BY_MAJOR_RELEASE', defaultValue: '', description: 'What name patch in Rocketsiebel should use for the assembly adm?')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
    }
    environment {
        BITBUCKET_BASE_URL="https://gitlab.rosbank.rus.socgen"
        NEXUS_BASE_URL="nexus.gts.rus.socgen"
        SIEBEL_NEXUS=credentials('bitbucket-cicd-siebel-ad')
        SKIP_AFTER_DEPLOY=false
                        ENVIRONMENT_MINOR="${env.ENVIRONMENT_IN}"
        ENVIRONMENT = get_env()
        TENV="${ENVIRONMENT}".toUpperCase()
//                     ENVIRONMENT="${env.ENVIRONMENT_IN}".replaceAll(/.*minor/,'cert')
        DIR_PATCH="/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}"
    }
    agent {
        node {
//             label "siebel&&linux&&" + "${env.ENVIRONMENT_IN}".replaceAll(/.*minor/,'cert')
             label "siebel&&linux&&" + get_env()
        }
    }
    stages {
       
       
        stage('Checkout') {
            steps {
                script {
                  SKIP_AFTER_DEPLOY = false
                  if(!fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}")) {sh """mkdir -p /home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}"""}
                }
                sh "git config --global http.sslVerify false"
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${env.SIEBEL_CICD_BRANCH}"]],
                    doGenerateSubmoduleConfigurations: false,
                        extensions: [
                            [$class: 'WipeWorkspace']
                        ],
                        submoduleCfg: [],
                        userRemoteConfigs: [[
                            credentialsId: "gitlab-cicd-siebel-ad",
                            url: "${env.BITBUCKET_BASE_URL}/siebelplatformteam/siebel-cicd.git"]]
                ])
            }
        }
 
        stage('Check tasks quantity'){
                steps{
                    withCredentials([
                        usernamePassword(
                            credentialsId: "trbs-cicd-siebel-ad",
                            usernameVariable: 'SIEBEL_AD_USER',
                            passwordVariable: 'SIEBEL_AD_PASS'
                        ),
                        usernamePassword(
                            credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                            usernameVariable: 'JIRA_USER',
                            passwordVariable: 'JIRA_PASS'
                        ),
                        string(
                            credentialsId: "jenkins_gitlab",
                            variable: 'jenkins_gitlab'
                        ),
 
                        ])
                        {ansiColor('xterm') { sh """
                        export jenkins_gitlab_token="${jenkins_gitlab}"                   
                        export JIRA_USER="${JIRA_USER}"
                        export JIRA_PASS="${JIRA_PASS}"
                        /bin/bash ./scripts/docker-run-python.sh
                        """}}
                }
        }
 
 
        stage('Checkout SIEBEL-NRT') {
            when {
                                    anyOf {
                environment name: 'SKIP_SYNCHRONIZATION_OF_DIRECTORIES_ON_APP_AND_WEB_SERVERS_WITH_GIT', value: 'false'
                environment name: 'SKIP_CREATE_RELEASE_BRANCH', value: 'false'
                environment name: 'SKIP_MERGE_RELEASE_BRANCH', value: 'false'
                                               environment name: 'SKIP_BUILD_ADM_ROCKETSIEBEL_FOR_MAJOR_RELEASE', value: 'false'
            }}
            steps {
              dir('siebel-nrt') {
                    git(
                        url: "${env.BITBUCKET_BASE_URL}/siebelplatformteam/siebel-nrt.git",
                        credentialsId: "gitlab-cicd-siebel-ad",
                                                                       branch: "${env.ENVIRONMENT}"
                    )
                }
            }
        }
        stage('Get issue jira'){
            when {
                environment name: 'SKIP_GET_ISSUE_JIRA', value: 'false'
            }
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "trbs-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                    ]) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"get-issue-jira\" && ls -la /home/jenkins-agent/releasebranchlog/"}}
            }
        }
        stage('Create Siebel patch'){
            when {
                environment name: 'SKIP_CREATE_SIEBEL_PATCH', value: 'false'
            }
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "trbs-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    string(
                        credentialsId: "TG_DEBUG_BOT_TOKEN",
                        variable: 'TG_DEBUG_BOT_TOKEN'
                    ),
                    string(
                        credentialsId: "TG_DEBUG_GROUP_ID",
                        variable: 'TG_DEBUG_GROUP_ID'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-apim-consumer",
                        usernameVariable: 'APIM_CONSUMER_KEY',
                        passwordVariable: 'APIM_CONSUMER_SECRET'
                    )
                    ]) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"get-issue-jira,create-siebel-patch\""}}
            }
        }
        stage('Get conflict patch'){
            when {
            allOf {
                expression { return !fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_no_tasks_rocket.txt")}
                environment name: 'SKIP_GET_CONFLICT_PATCH', value: 'false'
            }}
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "trbs-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    string(
                        credentialsId: "TG_DEBUG_BOT_TOKEN",
                        variable: 'TG_DEBUG_BOT_TOKEN'
                    ),
                    string(
                        credentialsId: "TG_DEBUG_GROUP_ID",
                        variable: 'TG_DEBUG_GROUP_ID'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-apim-consumer",
                        usernameVariable: 'APIM_CONSUMER_KEY',
                        passwordVariable: 'APIM_CONSUMER_SECRET'
                    )
                    ]) {
                      withEnv(["TIME_FOR_RESOLVE=${params.SLEEP_TO_START_ROCKETSIEBEL_DEPLOY.trim()}"]) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"get-issue-jira,get-conflict-patch\""}}
                      }
            }
        }
                        stage('Synchronize dir APP and WEB servers with GIT'){
            when {
                environment name: 'SKIP_SYNCHRONIZATION_OF_DIRECTORIES_ON_APP_AND_WEB_SERVERS_WITH_GIT', value: 'false'
            }
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    sshUserPrivateKey(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-ssh",
                        usernameVariable: 'SIEBEL_SSH_USER',
                        keyFileVariable: 'SIEBEL_SSH_KEY_FILE',
                        passphraseVariable: ''
                    ),
                    usernamePassword(
                        credentialsId: "gitlab-cicd-siebel-ad",
                        usernameVariable: 'GITLAB_USER',
                        passwordVariable: 'GITLAB_PASS'
                    )
                    ]) {ansiColor('xterm') {
                           echo "${env.SIEBEL_CICD_BRANCH}"
                           sh "cd siebel-nrt && pwd && ls -la && git branch && \
                           cd .. && /bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"synchronize-app-git,synchronize-web-git,synchronize-web-react-git,synchronize-localhost-git\" --extra-vars \"env_branch=${env.ENVIRONMENT}\""
                           }}
                    script{
                        withCredentials([
                            string(
                                credentialsId: "TG_DEBUG_BOT_TOKEN",
                                variable: 'TG_DEBUG_BOT_TOKEN'
                            ),
                            string(
                                credentialsId: "TG_DEBUG_GROUP_ID",
                                variable: 'TG_DEBUG_GROUP_ID'
                            ),
                            usernamePassword(
                                credentialsId: "${env.ENVIRONMENT}-apim-consumer",
                                usernameVariable: 'APIM_CONSUMER_KEY',
                                passwordVariable: 'APIM_CONSUMER_SECRET'
                            )
                            ]){
                                withEnv(["MY_RESULT=SYNC"]){ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"send-status-telegram\""}}
                            }
                    }                                      
            }
        }
        stage('Update nrtnodejs on web servers from GIT'){
            when {
               environment name: 'SKIP_UPDATE_NRTNODEJS_ON_WEB_SERVERS_FROM_GIT', value: 'false'
            }
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "gitlab-cicd-siebel-ad",
                        usernameVariable: 'GITLAB_USER',
                        passwordVariable: 'GITLAB_PASS'
                    ),                                                 
                    sshUserPrivateKey(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-ssh",
                        usernameVariable: 'SIEBEL_SSH_USER',
                        keyFileVariable: 'SIEBEL_SSH_KEY_FILE',
                        passphraseVariable: ''
                    )
                    ]) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"deploy-siebel-files-transceiver\" --extra-vars \"env_branch=${env.ENVIRONMENT}\""}}
            }
        }
        stage('Create release branch'){
            when {
                environment name: 'SKIP_CREATE_RELEASE_BRANCH', value: 'false'
            }
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "trbs-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                                                           usernamePassword(
                        credentialsId: "gitlab-cicd-siebel-ad",
                        usernameVariable: 'GITLAB_USER',
                        passwordVariable: 'GITLAB_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    string(
                        credentialsId: "TG_DEBUG_BOT_TOKEN",
                        variable: 'TG_DEBUG_BOT_TOKEN'
                    ),
                    string(
                        credentialsId: "TG_DEBUG_GROUP_ID",
                        variable: 'TG_DEBUG_GROUP_ID'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-apim-consumer",
                        usernameVariable: 'APIM_CONSUMER_KEY',
                        passwordVariable: 'APIM_CONSUMER_SECRET'
                    )
                    ]){
                        withEnv(['PUSH=true']) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"get-issue-jira,create-release-branch,create-backup-sql-object-db\""}}
                                                               load "/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy"
                    }
                script {
                    if (fileExists('/home/jenkins-agent/releasebranchlog/temp.html')) {
                        if (fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy")) {load "/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy"} else {env.RELEASE_BRANCH = "${env.ENVIRONMENT}"}
                        echo "${env.RELEASE_BRANCH}"
                        echo '---file tasks_date.txt exists---'
                        URLS = sh(returnStdout: true, script: 'cat /home/jenkins-agent/releasebranchlog/temp.html').trim()
                        emailext  to: "Oleg.Astakhov@rosbank.ru",
                            mimeType: 'text/html',
                            recipientProviders: [[$class: 'RequesterRecipientProvider']],
                            subject: "Список доп объектов. Патч ${env.GENERATE_PATCH_NAME}. Релизная ветка ${env.RELEASE_BRANCH}",
                            body: "${URLS}"
                    }           
                }
            }
        }
        stage('Sleep to start RocketSeibel.IP20.Deploy.universal'){
            when {
                environment name: 'SKIP_SLEEP_TO_START_ROCKETSIEBEL.DEPLOY', value: 'false'
            }
            steps{
                echo "Waiting ${params.SLEEP_TO_START_ROCKETSIEBEL_DEPLOY}"
                sh "sleep ${params.SLEEP_TO_START_ROCKETSIEBEL_DEPLOY}"
            }
        }
 
        stage('Resolve conflict patch'){
            when {
                                    allOf {
                expression { return !fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_no_tasks_rocket.txt")}
                environment name: 'SKIP_RESOLVE_CONFLICT_PATCH', value: 'false'
            }}
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "trbs-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    string(
                        credentialsId: "TG_DEBUG_BOT_TOKEN",
                        variable: 'TG_DEBUG_BOT_TOKEN'
                    ),
                    string(
                        credentialsId: "TG_DEBUG_GROUP_ID",
                        variable: 'TG_DEBUG_GROUP_ID'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-apim-consumer",
                        usernameVariable: 'APIM_CONSUMER_KEY',
                        passwordVariable: 'APIM_CONSUMER_SECRET'
                    )
                    ]) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"get-issue-jira,resolve-conflict-patch\""}}
            }
        }
        stage('Merge patch'){
            when {
                                    allOf {
                expression { return !fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_no_tasks_rocket.txt")}
                environment name: 'SKIP_MERGE_PATCH', value: 'false'
            }}
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "trbs-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    ]) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"get-task-patch\""}}
            }
        }
        stage ('Start RocketSeibel.IP20.Deploy.universal') {
            when {
                environment name: 'SKIP_START_ROCKETSEIBEL_DEPLOY', value: 'false'
            }
            steps {
 
              script {
                  //if (fileExists ("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_no_tasks_rocket.txt")) {env.SKIP_CREATE_SIEBEL_PATCH = true}                                                    
                  //if (env.THE_PATCH_IN_ROCKET_SIEBEL_ALREADY_BEEN_BUILT == "Yes") {env.SKIP_CREATE_SIEBEL_PATCH = false} 
                    if (env.SKIP_CREATE_SIEBEL_PATCH == "true" && env.THE_PATCH_IN_ROCKET_SIEBEL_ALREADY_BEEN_BUILT == "No") {
                        writeFile(file: "/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_no_tasks_rocket.txt", text: "${env.GENERATE_PATCH_NAME}_no_tasks_rocket.txt", encoding: "UTF-8")
                        get_task_patch()
                    }
                                                           else if (fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_end_get_task_patch.txt")) {echo "Found File ${env.GENERATE_PATCH_NAME}_end_get_task_patch.txt"}
                    else {
                        get_task_patch()
                    }
                    if (fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy")) {load "/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy"
                    } else if (!"${env.SIEBEL_NRT_BRANCH}".isEmpty()) {env.RELEASE_BRANCH = "${env.SIEBEL_NRT_BRANCH}"
                    } else if ("${env.SIEBEL_NRT_BRANCH}".isEmpty()) {env.RELEASE_BRANCH = "${env.ENVIRONMENT}"}
                    echo "${env.RELEASE_BRANCH}"
                                                           if (!fileExists ("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_deploy_dop_objects.txt")) {env.SKIP_IMPORT_DOP_OBJECT = true}
                    writeFile(file: "/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/start_job_rocketseibel_ip20_deploy_universal.txt", text: "Start Job RocketSeibel.IP20.Deploy.universal", encoding: "UTF-8")
                 //   if (env.SKIP_CREATE_SIEBEL_PATCH == "true") { writeFile(file: "/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/create_siebel_patch.txt", text: "Start Job RocketSeibel.IP20.Deploy.universal with parametr SKIP_CREATE_SIEBEL_PATCH = true", encoding: "UTF-8") }
                    if ("${env.ENVIRONMENT}" == "test") {DIR_CICD_JOB = "Experimental"}
                    if ("${env.ENVIRONMENT}" == "cert") {DIR_CICD_JOB = "Siebel_Patch_CERT"}
                    if ("${env.ENVIRONMENT}" == "prod") {DIR_CICD_JOB = "Siebel_Patch_PROD"}
                    if ("${env.ENVIRONMENT}" == "devupg") {DIR_CICD_JOB = "Experimental"}                   
                    echo "${DIR_CICD_JOB}"
                  DEPLOY_RESULT = build job: "/Siebel/${DIR_CICD_JOB}/RocketSeibel.IP20.Deploy.universal_test", propagate: false,
                 // DEPLOY_RESULT = build job: 'Siebel/RocketSeibel.IP20.Deploy.universal', propagate: false,
                                    parameters: [
                                      string(name: 'PATCH_NAME', value: "${env.GENERATE_PATCH_NAME}"),
                                      string(name: 'ENVIRONMENT', value: "${env.ENVIRONMENT}"),
                                      booleanParam(name: 'SKIP_RESTART_SIEBEL_COMPONENT', value: "${env.SKIP_RESTART_SIEBEL_COMPONENT}"),
                                      string(name: 'SIEBEL_COMPONENTS_FOR_RESTART', value: "${env.SIEBEL_COMPONENTS_FOR_RESTART}"),
                                      string(name: 'SIEBEL_CICD_BRANCH', value: "${env.SIEBEL_CICD_BRANCH}"),
                                      string(name: 'SIEBEL_NRT_BRANCH', value: "${env.RELEASE_BRANCH}"),
                                                                                                            booleanParam(name: 'SKIP_EXECUTE_SCRIPTS_BEFORE_APPLY_DDL', value: "${env.SKIP_IMPORT_DOP_OBJECT}"),
                                      booleanParam(name: 'SKIP_IMPORT_MANUAL_ADM', value: "${env.SKIP_IMPORT_DOP_OBJECT}"),
                                      booleanParam(name: 'SKIP_EXECUTE_SCRIPTS_AFTER_APPLY_DDL', value: "${env.SKIP_IMPORT_DOP_OBJECT}"),
                                      booleanParam(name: 'SKIP_DEPLOY_DOP_WEB_FRONTEND', value: "${env.SKIP_IMPORT_DOP_OBJECT}"),
                                      booleanParam(name: 'SKIP_DEPLOY_DOP_APP_FRONTEND', value: "${env.SKIP_IMPORT_DOP_OBJECT}"),
                                                                                                            booleanParam(name: 'SKIP_CREATE_BACKUP_MANUAL_ADM', value: "${env.SKIP_IMPORT_DOP_OBJECT}")
                                      // string(name: 'SKIP_CREATE_SIEBEL_PATCH', value: "${env.SKIP_CREATE_SIEBEL_PATCH}")
                                    ]
                  if (fileExists ("${DIR_PATCH}/${env.GENERATE_PATCH_NAME}_result_deploy.txt")) {
                      STR_3=readFile("${DIR_PATCH}/${env.GENERATE_PATCH_NAME}_result_deploy.txt").toString().trim()
                      echo "STR=${STR_3}"
                  }
                  echo "DEPLOY_RESULT = ${DEPLOY_RESULT.result}"
                  if(DEPLOY_RESULT.result != "UNSTABLE" && DEPLOY_RESULT.result != "SUCCESS"){
                    SKIP_AFTER_DEPLOY=true
                    echo "SKIP_AFTER_DEPLOY = ${SKIP_AFTER_DEPLOY}"
                  }
              }
            }
        }
        stage('Merge release branch'){
            when {
              allOf{
                environment name: 'SKIP_MERGE_RELEASE_BRANCH', value: 'false';
                equals expected: false, actual: SKIP_AFTER_DEPLOY;
              }
            }
            steps{
                                               script {
                                                                       if (fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy")) {
                                load "/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy"
                                echo "---env.groovy exists---"
                                echo "${env.RELEASE_BRANCH}"
                            }
                            else
                            {
                                env.RELEASE_BRANCH = "${env.ENVIRONMENT}"
                                echo "---env.groovy doesnt exist---"
                                echo "${env.RELEASE_BRANCH}"}
                        }
                withCredentials([
                    usernamePassword(
                        credentialsId: "trbs-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                                                           usernamePassword(
                        credentialsId: "gitlab-cicd-siebel-ad",
                        usernameVariable: 'GITLAB_USER',
                        passwordVariable: 'GITLAB_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    )
                    ]) {
                        echo "${env.RELEASE_BRANCH}"
                                                                       withEnv(['PUSH=true']){ansiColor('xterm') {
                            sh "cd siebel-nrt && if git show-ref --quiet ${env.RELEASE_BRANCH}; then git checkout ${env.RELEASE_BRANCH};fi && if [[ \$(git show-ref refs/heads/${env.RELEASE_BRANCH} | wc -c) > 0 ]] ;  \
                            then cd .. && pwd && ls -la && /bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"merge-release-branch\"; \
                            else echo BRANCH ${env.RELEASE_BRANCH} no have some change ;fi" }}
                                                           }
                script {
                    if (fileExists('/home/jenkins-agent/releasebranchlog/temp.html')) {
                        echo '---file tasks_date.txt exists---'
                        URLS = sh(returnStdout: true, script: 'cat /home/jenkins-agent/releasebranchlog/temp.html').trim()
                        emailext  to: "Oleg.Astakhov@rosbank.ru",
                            mimeType: 'text/html',
                            recipientProviders: [[$class: 'RequesterRecipientProvider']],
                            subject: "Доп объекты, добавленные в целевую ветку ${TENV}. Патч ${env.GENERATE_PATCH_NAME}. Релизная ветка ${env.RELEASE_BRANCH}",
                            body: "${URLS}"
                    }           
                }
                                    }
        }
        stage("Add 'Development object' labels") {
            when {
              allOf{
                environment name: 'SKIP_ADD_DEVELOPMENT_OBJECT_LABELS', value: 'false';
                equals expected: false, actual: SKIP_AFTER_DEPLOY;
              }
            }
            steps{
                                               script {if (fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy")) {load "/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy"} else {env.RELEASE_BRANCH = "${env.ENVIRONMENT}"}}
                withCredentials([
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    ]) {
                        ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"add-label-development-object\""}}
            }
        }
        stage("Send result comments in Jira") {
            when {
                allOf{
                  environment name: 'SKIP_SEND_RESULT_COMMENTS_IN_JIRA', value: 'false';
                  equals expected: false, actual: SKIP_AFTER_DEPLOY;
                }
            }
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    ]) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"send-comment-jira-final\""}}
            }
        }
        stage("Set status tasks in Jira") {
            when {
              allOf{
                  environment name: 'SKIP_SET_STATUS_TASKS_IN_JIRA', value: 'false'
                  equals expected: false, actual: SKIP_AFTER_DEPLOY;
                }
            }
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-jira-user-siebel",
                        usernameVariable: 'JIRA_USER',
                        passwordVariable: 'JIRA_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    ]) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"set-status-tasks\""}}
            }
        }
        stage("Build adm rocketsiebel for major release") {
            when {
                  environment name: 'SKIP_BUILD_ADM_ROCKETSIEBEL_FOR_MAJOR_RELEASE', value: 'false'
            }
            steps{
                script {
                    if (fileExists("/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy")) {load "/home/jenkins-agent/releasebranchlog/${ENVIRONMENT}/${GENERATE_PATCH_NAME}/${env.GENERATE_PATCH_NAME}_env.groovy"} else {env.RELEASE_BRANCH = "${env.ENVIRONMENT}"}
                    echo "${env.RELEASE_BRANCH}"
                }
                withCredentials([
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-ad",
                        usernameVariable: 'SIEBEL_AD_USER',
                        passwordVariable: 'SIEBEL_AD_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "gitlab-cicd-siebel-ad",
                        usernameVariable: 'GITLAB_USER',
                        passwordVariable: 'GITLAB_PASS'
                    )
                    ]) {ansiColor('xterm') {
                    echo "${env.SIEBEL_CICD_BRANCH}"
                    sh "cd siebel-nrt && pwd && ls -la && git checkout \"${env.RELEASE_BRANCH}\" && git branch && \
                    cd .. pwd && ls -la && /bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"build-adm-rs-for-major-release,build-adm-rs-for-major-release-1,build-adm-rs-for-major-release-2,build-adm-rs-for-major-release-3\" --extra-vars \"env_rs_patch_name=${env.ROCKETSIEBEL_PATCH_NAME_FOR_BUILD_ADM_RS_BY_MAJOR_RELEASE}\" --extra-vars \"env_branch=${env.RELEASE_BRANCH}\" --extra-vars \"env=${env.ENVIRONMENT}\""
                    }}
            }
        }      
    }
    post {
        always {
                  script {
                      try {
                        echo "DEPLOY_RESULT = ${DEPLOY_RESULT.result}"
                        currentBuild.result = DEPLOY_RESULT.result
                      }
                      catch (e) {
                        echo "DEPLOY_RESULT is undefine!"
                        if (fileExists ("${DIR_PATCH}/${env.GENERATE_PATCH_NAME}_result_deploy.txt")) {
                           currentBuild.result = readFile("${DIR_PATCH}/${env.GENERATE_PATCH_NAME}_result_deploy.txt").toString().trim()
                           echo "Read Deploy Result from file ${env.GENERATE_PATCH_NAME}_result_deploy.txt"
                           echo "DEPLOY_RESULT = ${currentBuild.result}"
                        }
                     
                      
                      }
                  withCredentials([
                    string(
                        credentialsId: "TG_DEBUG_BOT_TOKEN",
                        variable: 'TG_DEBUG_BOT_TOKEN'
                    ),
                    string(
                        credentialsId: "TG_DEBUG_GROUP_ID",
                        variable: 'TG_DEBUG_GROUP_ID'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                        usernameVariable: 'ROCKETSIEBEL_USER',
                        passwordVariable: 'ROCKETSIEBEL_PASS'
                    ),
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-apim-consumer",
                        usernameVariable: 'APIM_CONSUMER_KEY',
                        passwordVariable: 'APIM_CONSUMER_SECRET'
                    )
                    ]){
                                                withEnv(["MY_RESULT=${currentBuild.result}"]){ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"send-status-telegram\""}}
                                                           }
                                               }
            }
        cleanup {
            echo "Cleaning up"
            sh "find '/home/jenkins-agent/releasebranchlog' -type d -mtime +7 -delete"
            sh "docker system prune --force --volumes"
            deleteDir()
        }
    }
}
 
def get_env() {
       switch ("${env.ENVIRONMENT_IN}") {
          case "devupg":
            case_env = "devupg"
            break
           
          case "test":
            case_env = "test"
            break
           
          case "cert":
            case_env = "cert"
            break
         
          case "cert_minor":
            case_env = "cert"
            break
         
          case "cert_nlt_minor":
            case_env = "cert"
            break
           
          case "cert_sas_ma":
            case_env = "cert"
            break
           
          case "prod_sas_ma":
            case_env = "prod"
            break
           
          case "prod":
            case_env = "prod"
            break
       }
       return "$case_env"
}
 
 
def get_task_patch() {
withCredentials([
                usernamePassword(
                    credentialsId: "${env.ENVIRONMENT}-cicd-siebel-rocketsiebel",
                    usernameVariable: 'ROCKETSIEBEL_USER',
                    passwordVariable: 'ROCKETSIEBEL_PASS'
                ),
                ]) {ansiColor('xterm') { sh "/bin/bash ./scripts/docker-run-ansible.sh generate-patch.yml --tags \"get-task-patch\""}}                  
}
