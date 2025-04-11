import java.time.*
import java.time.format.DateTimeFormatter
 
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
        booleanParam(name: 'SKIP_CHECK_FREE_DISK_SPACE', defaultValue: false, description: 'Should we skip "Check free disk space" stage?')
        choice(name: 'ENVIRONMENT_IN', choices: ['vanila', 'devupg', 'dev', 'test', 'cert', 'prod'], description: 'What environment to Backup?')
        string(name: 'INITIATOR_EMAIL', defaultValue: 'administrator_siebel@rosbank.ru', description: 'Initiator pipeline e-mail')
        string(name: 'SIEBEL_CICD_BRANCH', defaultValue: 'master', description: 'What code branch to checkout in project SIEBEL-CICD?')       
    }
    environment {
        BITBUCKET_BASE_URL="https://gitlab.rosbank.rus.socgen"
        NEXUS_BASE_URL="nexus.gts.rus.socgen"
        SIEBEL_NEXUS=credentials('bitbucket-cicd-siebel-ad')
        ENVIRONMENT = get_env_1()
        DATE_TIME=LocalDateTime.now().format(DateTimeFormatter.ofPattern("MM_dd_yyyy_HH_mm_ss"))
                      DATE_TIME_D=LocalDateTime.now().format(DateTimeFormatter.ofPattern("MM_dd_yyyy"))
//                     ENVIRONMENT="${env.ENVIRONMENT_IN}".replaceAll(/.*minor/,'cert')
        TENV="${ENVIRONMENT}".toUpperCase()
    }
    agent {
        node {
//             label "siebel&&linux&&" + "${env.ENVIRONMENT_IN}".replaceAll(/.*minor/,'cert')
             label "siebel&&linux&&" + get_env_1()
        }
    }
    stages {
        stage('Checkout SIEBEL-CICD') {
            steps {
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
        stage('Check_Free_Disk_Space') {
            when {      
                environment name: 'SKIP_CHECK_FREE_DISK_SPACE', value: 'false'
            }
            steps{
                withCredentials([
                    usernamePassword(
                        credentialsId: "${env.ENVIRONMENT}-cicd-siebel-acc",
                        usernameVariable: 'SIEBEL_ACC_USER',
                        passwordVariable: 'SIEBEL_ACC_PASS'
                    ),
                    sshUserPrivateKey(
                           credentialsId: "${env.ENVIRONMENT}-cicd-siebel-ssh",
                            usernameVariable: 'SIEBEL_SSH_USER',
                            keyFileVariable: 'SIEBEL_SSH_KEY_FILE',
                            passphraseVariable: ''
                    )
                    ]) {ansiColor('xterm') {
                    echo "${ENVIRONMENT}"
                                                           sh "/bin/bash ./scripts/docker-run-ansible.sh check-free-disk-space.yml --tags \"check-free-disk-space\"" }}
            }
        }
   }
    post {
        always {
            script {
                 echo "currentBuild.result original = ${currentBuild.result}"
                 if(currentBuild.result=='FAILURE'){
                      emailext  to: "${INITIATOR_EMAIL}",
                      recipientProviders: [[$class: 'RequesterRecipientProvider']],
                      subject: "[Jenkins] - ${currentBuild.result} - Check Free Disk Space build ${BUILD_NUMBER} for ${TENV}",
                      body: "[Jenkins] - Проверка свободного места на APP серверах для среды ${TENV} завершился. Статус: ${currentBuild.result}! Просьба проверить логи конвейера."
                 }
                 if(currentBuild.result=='ABORTED'){
                      emailext  to: "${INITIATOR_EMAIL}",
                      recipientProviders: [[$class: 'RequesterRecipientProvider']],
                      subject: "[Jenkins] - ${currentBuild.result} - Check Free Disk Space build ${BUILD_NUMBER} for ${TENV}",
                      body: "[Jenkins] - Проверка свободного места на APP серверах для среды ${TENV} завершился. Статус: ${currentBuild.result}! Просьба проверить логи конвейера."
                 }
                 if(fileExists ("./tmp/logs/check_free_disk_space.log")){
                      def marker_send_telegram = readFile("./tmp/logs/check_free_disk_space.log")
                      echo "${marker_send_telegram}"
                      if("${marker_send_telegram}") {
                           for (entry in "${marker_send_telegram}") {
                               println("${entry.key}: ${entry.value}")
                           }
//                               if(currentBuild.result=='FAILURE'){
//                                   text="Проверка сободного места на серверах \\nСреда: ${TENV} \\nСтатус: ❌ ${currentBuild.result} \\nПросьба проверить логи конвейера."
////                               echo text
//                               }
//                               if(currentBuild.result=='ABORTED'){
//                                   text="Проверка сободного места на серверах \\nСреда: ${TENV} \\nСтатус: ◼ Работа конвейера остановлена. \\nПросьба проверить логи конвейера."
//                               }           
//                               if("${entry.value}" >= 85 && "${entry.value}" < 90){
//                                   text="🔶 Внимание! Среда: ${TENV} \\nСервер: ${entry.key} \\nНа дисках сервера осталось менеее 15% свободного места."
//                               }
//                               if("${entry.value}" >= 90 && "${entry.value}" < 95){
//                                   text="🟨 Внимание! Среда: ${TENV} \\nСервер: ${entry.key} \\nНа дисках сервера осталось менеее 10% свободного места."
//                               }
//                               if("${entry.value}" >= 95 && "${entry.value}" < 100){
//                                   text="🟧 Внимание! Среда: ${TENV} \\nСервер: ${entry.key} \\nНа дисках сервера осталось менеее 5% свободного места."
//                               }
//                               if("${entry.value}" == 100){
//                                   text="🟥 Внимание! Среда: ${TENV} \\nСервер: ${entry.key} \\nНа дисках сервера не осталось свободного места."
//                               }
//                               withCredentials([
//                                     string(
//                                                  credentialsId: "TG_DEBUG_BOT_TOKEN",
//                                                  variable: 'TG_DEBUG_BOT_TOKEN'
//                                     ),
//                                     string(
//                                                  credentialsId: "TG_DEBUG_GROUP_ID",
//                                                  variable: 'TG_DEBUG_GROUP_ID'
//                                     ),
//                                     usernamePassword(
//                                         credentialsId: "${env.ENVIRONMENT}-apim-consumer",
//                                         usernameVariable: 'APIM_CONSUMER_KEY',
//                                         passwordVariable: 'APIM_CONSUMER_SECRET'
//                                     )
//                                     ]){
//                                     withEnv(["MY_RESULT=${text}","TG_URL_PATH=./ansible/environments/${ENVIRONMENT}/host_vars/localhost.yml"])
//                                         {ansiColor('xterm') {
//                                         sh "chmod +x ./scripts/SendTelegramDebug.sh"
//                                         sh "/bin/bash ./scripts/SendTelegramDebug.sh"
//                                         //sh "pwd && ls -la"
//                                     }}}
//                          }
                      }
                  }
          }
        }
        cleanup {
            echo "Cleaning up"
            sh "docker system prune --force --volumes"
            //deleteDir()
        }
    }
}
def get_env() {
       switch ("${env.ENVIRONMENT_IN}") {
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
//def get_env() {return "${env.ENVIRONMENT_IN}"=="minor"?"cert":
//                           "${env.ENVIRONMENT_IN}"=="cert_sas_ma"?"cert":
//                           "${env.ENVIRONMENT_IN}"=="prod_sas_ma"?"prod":
//                                   "${env.ENVIRONMENT_IN}"
//}
 
def get_env_1() {if ("${JOB_NAME}".find("TEST")) {env.ENVIRONMENT_IN = "test"}
                 if ("${JOB_NAME}".find("CERT")) {env.ENVIRONMENT_IN = "cert"}
                 if ("${JOB_NAME}".find("PROD")) {env.ENVIRONMENT_IN = "prod"}
                 if ("${JOB_NAME}".find("DEV")) {env.ENVIRONMENT_IN = "dev"}
                 if ("${JOB_NAME}".find("DEVUPG")) {env.ENVIRONMENT_IN = "devupg"}
                 if ("${JOB_NAME}".find("VANILA")) {env.ENVIRONMENT_IN = "vanila"}
                 return "${env.ENVIRONMENT_IN}"
}