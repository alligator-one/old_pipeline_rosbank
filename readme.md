Readme.md
 
# Siebel CI/CD
 
**Содержание**
 
1. [Структура репозитория](#Struct)
 
* [Ansible](#StructAnsible)
  * [Ansible/playbooks](#StructAnsiblePlaybooks)
    * Ansible/playbooks/templates
      * [generate-patch.py.j2](#StructAnsibleGenerate-patch)
      * [siebrunner.ps1.j2](#StructAnsibleSiebrunner)
      * [siebwrapper.sh.j2](#StructAnsibleSiebwrapper)
* [Assets](#StructAssets)
* [Pipelines](#StructPipelines)
  * [dockerBuild.Jenkinsfile](#StructPipelinesDockerBuild)
  * [generatePatch.Jenkinsfile](#StructPipelinesGeneratePatch)
  * [Jenkinsfile](#StructPipelinesJenkinsfile)
* [Scripts](#StructScripts)
  * [docker-run-ansible.sh](#StructScriptsDockerRunAnsible)
  * [Dockerfile](#DockerBuildImage)
 
2. [Docker](#Docker)
 
* [Docker образ используемый в пайплайнах](#DockerImage)
* [Сборка собственного docker image](#DockerBuildImage)
 
3. [Параметризация для нескольких окружений](#ParameterizationPipeline)
 
* [Добавление кред для нового окружения](#ParameterizationPipelineAddCred)
* [Добавление окружения в Jenkinsfile](#ParameterizationPipelineAddEnvironment)
* [Добавление нескольких хостов Siebel App/Web/Gate в рамках одного окружения](#ParameterizationPipelineAddEnvironmentManyHosts)
  * [Добавление Siebel Gate](#ParameterizationPipelineAddEnvironmentGate)
 
4. [Пайплайны](#Pipelines)
 
* [RocketSiebel.GeneratePatch](#PipelinesRocketSiebelGeneratePatch)
  * [Параметры запуска](#PipelinesRocketSiebelGeneratePatchParameters)
  * Стадии пайплайна
    * [Checkout](#PipelinesRocketSiebelGeneratePatchStageCheckout)
    * [Get issue jira](#PipelinesRocketSiebelGeneratePatchStageGetIssueJira)
    * [Create Siebel patch](#PipelinesRocketSiebelGeneratePatchStageCreateSiebelPatch)
            * [Get conflict patch](#PipelinesRocketSiebelGeneratePatchStageGetConflictPatch)
            * [Create release branch](#PipelinesRocketSiebelGeneratePatchStageCreateReleaseBranch)
            * [Import_dop_object](#PipelinesRocketSiebelGeneratePatchStageImportDopObject)
    * [Resolve conflict patch](#PipelinesRocketSiebelGeneratePatchStageResolveConflictPatch)
    * [Merge patch](#PipelinesRocketSiebelGeneratePatchStageMergePatch)
    * [Sleep to start RocketSeibel.Deploy](#PipelinesRocketSiebelGeneratePatchStageSleepToStartRocketSeibelDeploy)
    * [Push release branch](#PipelinesRocketSiebelGeneratePatchStagePushReleaseBranch)
    * [Start RocketSeibel.Deploy](#PipelinesRocketSiebelGeneratePatchStageStartRocketSeibelDeploy)
    * [Merge release branch](#PipelinesRocketSiebelGeneratePatchStageMergeReleaseBranch)
    * [Add 'Development object' labels](#PipelinesRocketSiebelGeneratePatchStageAddDevelopmentObjectLabels)
    * [Send result comments in Jira](#PipelinesRocketSiebelGeneratePatchStageSendResultCommentsInJira)
    * [Set status tasks in Jira](#PipelinesRocketSiebelGeneratePatchStageSetStatusTasksInJira)
           
* [RocketSeibel.Deploy](#PipelinesRocketSeibelDeploy)
  * [Параметры запуска](#PipelinesRocketSeibelDeployParameters)
  * Стадии пайплайна
    * [Checkout](#PipelinesRocketSeibelDeployStageCheckout)
    * [Download patch](#PipelinesRocketSeibelDeployStageDownloadPatch)
    * [Prepare patch](#PipelinesRocketSeibelDeployStagePreparePatch)
    * [Lock Objects](#PipelinesRocketSeibelDeployStageLockObjects)
    * [Expire Workflow](#PipelinesRocketSeibelDeployStageExpireWorkflow)
    * [Import SIF](#PipelinesRocketSeibelDeployStageImportSIF)
    * [Apply DDL](#PipelinesRocketSeibelDeployStageApplyDDL)
    * [Compile SRF](#PipelinesRocketSeibelDeployStageCompileSRF)
    * [Deploy SRF](#PipelinesRocketSeibelDeployStageDeploySRF)
    * [Import ADM](#PipelinesRocketSeibelDeployStageImportADM)
    * [Import dop object](#PipelinesRocketSeibelDeployStageImportdopobject)
    * [Import manual ADM](#PipelinesRocketSeibelDeployStageImportManualADM)
    * [Deploy dop Web Frontend](#PipelinesRocketSeibelDeployStageDeploydopWebFrontend)
    * [Import dop DB](#PipelinesRocketSeibelDeployStageImportdopDB)
    * [Activate WorkFlow](#PipelinesRocketSeibelDeployStageActivateWorkFlow)
    * [Backup results](#PipelinesRocketSeibelDeployStageBackupResults)
* [Docker.Build.Dev](#PipelinesDockerBuildDev)
  * [Параметры запуска](#PipelinesDockerBuildDevParameters)
  * Стадии пайплайна
    * [Checkout](#PipelinesDockerBuildDevStageCheckout)
    * [Build image](#PipelinesDockerBuildDevStageBuildImage)
    * [Publish](#PipelinesDockerBuildDevStagePublish)
 
 
# <a name="Struct"></a> Структура репозитория
 
Репозиторий имеет следующую структуру:
 
* ansible - ansible плейбуки, которые используются для в работе пайплайнов
* pipelines - директория с Jenkinsfile пайплайнов
* scripts - различные скрипты, которые используются в пайплайнах
 
## <a name="StructAnsible"></a>         ansible
 
Содержит:
 
* environments - описание переменных окружения для ansible
* playbooks - непосредственно плейбуки, используемые в пайплайнах
 
## <a name="StructAnsiblePlaybooks"></a>  ansible/playbooks
 
Содержит:
 
* deploy - директория, в которой расположены ansible плейбуки, выполняющие действия шагов деплоя
* templates - директория, в которой находятся различные скрипты и файлы конфигурации для работы конвейера. Описание работы скриптов находится чуть ниже. В данный момент это:
  * generate-patch.py - скрипт для генерации патча RocketSiebel
  * rs-client.cfg.j2 - конфигурация RocketSiebel клиента
  * settings.json.j2 - настройки утилиты SiebDev.exe
  * siebrunner.ps1.j2 - скрипт для взаимодействия с RocketSiebel и БД Siebel
  * siebwrapper.sh.j2 - скрипт для взаимодействия с siebel
  * tnsnames.ora.j2 - настройки подключения к Oracle, которые используются утилитой SiebDev.exe
  * tomcat - директория, в которой лежат шаблоны скриптов управления и проверки состояния tomcat
    * check_service.sh.j2 - скрипт проверки состояния процесса
    * shutdown.sh.j2 - скрипт остановки tomcat
    * startup.sh.j2 - скрипт запуска tomcat
* deploy.yml - ansible playbook файл, который используется в пайплайне, описываемым Jenkinsfile. Подключает необходимые плейбуки из директории ansible/playbooks/deploy
* generate-patch.yml - ansible playbook файл, который используется в пайплайне описываемым generatePatch.Jenkinsfile
* ping.yml - ansible playbook файл, который вызывается в Jenkinsfile в стадии Ping. Используется для проверки доступности серверов
 
###  <a name="StructAnsibleGenerate-patch"></a> generate-patch.py.j2
 
Скрипт для генерации патча RocketSeibel. Взаимодействует с jira и RocketSeibel API. Выполняет только одну задачу. При запуске необходимо передавать аргументы скрипту, для выполнения соответствующей задачи. Так же для работы требует следующие переменные окружения:
 
* JIRA_USER - логин для авторизации в JIRA
* JIRA_PASS - пароль для авторизации в JIRA
 
* ROCKETSIEBEL_USER - логин для авторизации в RocketSiebel
* ROCKETSIEBEL_PASS - пароль для авторизации в RocketSiebel
 
* JENKINS_USER - логин для авторизации в Jenkins
* JENKINS_PASS - пароль для авторизации в Jenkins
 
Принимает следующие аргументы:
 
* **get_issue_jira** - получает список тасков JIRA. Требуются переменные JIRA_USER, JIRA_PASS. Задачи сохраняет в файл patchList. Пример: `python3 generate-patch.py get_issue_jira`
* **create_patch** - создает патч из задач JIRA. Требуются переменные ROCKETSIEBEL_USER, ROCKETSIEBEL_PASS. Список задач передаётся в качестве аргумента скрипту. Пример: `python3 generate-patch.py create_patch testPatch "['PCCRM-707', 'DS-2714', 'CRM-6835']"`
* **check_conflict** - проверяет и выводит наличие конфликтов в патче. Требуются переменные ROCKETSIEBEL_USER, ROCKETSIEBEL_PASS. Пример: `python3 generate-patch.py check_conflict testPatch`
* **resolve_conflict** - проверяет на наличие конфликтов патч. При наличие конфликтов, удаляет конфликтные таски из патча и отправляет соответствующее уведомление в JIRA. Требуется передача имени патча и списка задач, включенных в патч. Для работы требуются переменные ROCKETSIEBEL_USER, ROCKETSIBEL_PASS, JIRA_USER, JIRA_PASS. Пример: `python3 generate-patch.py resolve_conflict testPatch "['PCCRM-707', 'DS-2714', 'CRM-6835']"`
* **merge_patch** - мерджит патч RocketSiebel. Необходимо передавать имя патча. Для работы требуются ROCKETSIEBEL_USER, ROCKETSIEBEL_PASS. Пример: `python3 generate-patch.py merge_patch testPatch`
* **create_release_branch** - Создает релизную ветку. Если указана переменная окружения PUSH=true, отправляет ветку в удаленный репозиторий. Необходимо передавать имя патча. Для работы требуются SIEBEL_AD_USER, SIEBEL_AD_PASS. Пример: `python3 generate-patch.py create_release_branch testPatch`
* **start_rocketsiebel_deploy** - запускает в работу пайплайн RocketSiebel.Deploy. Необходимо передавать имя патча. Для работы требуются JENKINS_USER, JENKINS_PASS. Пример: `python3 generate-patch.py start_rocketsiebel_deploy testPatch`
* **merge_release_branch** - Сливает релизную ветку с веткой окружения. Необходимо передавать имя патча. Для работы требуются SIEBEL_AD_USER, SIEBEL_AD_PASS. Пример: `python3 generate-patch.py merge_release_branch testPatch`
* **add_label_development_object** - добавляет метку *Development object* таскам в jira, которые содержатся в патче. Необходимо передавать имя патча. Для работы требуются ROCKETSIEBEL_USER, ROCKETSIEBEL_PASS, JIRA_USER, JIRA_PASS. Пример: `python3 generate-patch.py add_label_development_object testPatch`
* **send_comment_jira_final** - отправляет комментарий об установке таска в jira. Отправляет комментарии таскам, которые содержатся в патче. Необходимо передавать имя патча. Для работы требуется ROCKETSIEBEL_USER, ROCKETSIEBEL_PASS, JIRA_USER, JIRA_PASS. Пример: `python3 generate-patch.py send_comment_jira_final testPatch`
* **set_status_tasks** - устанавливает таскам в jira, которые содержатся в патче, один из переданных статусов.  Если у таски нет возможности подставить один из переданных статусов, то статус не изменяется. Необходимо передавать имя патча и список возможных статусов задач. Статусы задач необходимо передавать в следующем формате: `'Done; In progress; Backlog`. Пример: `python3 generate-patch.py set_status_tasks testPatch 'Done; In progress; Backlog'`
 
### <a name="StructAnsibleSiebrunner"></a> siebrunner.ps1.j2
 
Скрипт для взаимодействия с Siebel. Выполняет определенную команду. На вход необходимо передать требуемый параметр. Принимает следующие параметры:
 
* debug - включает вывод отладочной информации в выполняемых функциях.
* lock-obj - лочит объекты в БД Siebel путем отправки SQL запроса. Для работы требуется передать **db-user** и **db-pass**. Пример: `powershell -File siebrunner.ps1 -db-user admin -db-pass admin -lock-obj`
* expire-wf - устанавливает статус **NOT_IN_USE** для workflow в патче RS путем отправки SQL запроса. Для работы требуется передать **db-user**, **db-pass** и **patch**. Пример: `powershell -File siebrunner.ps1 -db-user admin -db-pass admin -expire-wf -patch testPatch`
* import-sif - импортирует sif объекты. Для работы требуется передать **user**, **pass** и **patch**. Где **user** и **pass** логин и пароль от Siebel соответственно, а **patch** название патча RS. Пример: `powershell -File siebrunner.ps1 -user admin -pass admin -import-sif -patch testPatch`
* apply-ddl - переносит схему БД из dev БД в Siebel БД путем генерации ddl файлов. Для работы требуется передать **user**, **pass**, **db-user**, **db-pass** и **patch**. Где **user** и **pass** логин и пароль от Siebel соответственно, а **patch** название патча RS. Пример: `powershell -File siebrunner.ps1 -user admin -pass admin -db-user admin -db-pass admin -patch testPatch -apply-ddl`
* compile-srf - запускает компиляцию SRF. Для работы требуется передать **user**, **pass** и **patch**. Где **user** и **pass** логин и пароль от Siebel соответственно, а **patch** название патча RS. Пример: `powershell -File siebrunner.ps1 -user admin -pass admin -compile-srf -patch testPatch`
* import-adm - импортирует ADM файл. Для работы требуется передать **patch**, который является названием патча RS. Пример: `powershell -File siebrunner.ps1 -import-adm -patch testPatch`
* activate-wf - активирует workflow в объектах патча RS. Для работы требуется передать **db-user**, **db-pass**, **patch**, где **patch** имя патча RS. Пример: `powershell -File {{ cicd_home_path }}\\scripts\\siebrunner.ps1 -db-user admin -db-pass admin -activate-wf -patch testPatch`
 
###  <a name="StructAnsibleSiebwrapper"></a> siebwrapper.sh.j2
 
Скрипт для взаимодействия с Siebel. Выполняет определенную команду. На вход необходимо передать требуемый параметр. Принимает следующие параметры:
 
* start - запускает siebel. Если siebel уже запущен, выдает ошибку. Пример: `bash siebwrapper.sh.j2 start`
* stop - останавливает siebel. Если siebel уже остановлен, выдает ошибку. Пример: `bash siebwrapper.sh.j2 stop`
* status - выводит текущий статус siebel. Запущен или остановлен. Так же может вывести состояние **UNKNOWN**, если не может определить состояние siebel.
* clear - очищает siebel после неудачного старта.
 
Дополнительно стоит пояснить как скрипт определяет статус siebel (Start, Stop, Unknown). Скрипт определяет состояние siebel не по запросу к API или как то напрямую общаясь с Siebel, а лишь по косвенным признакам. В связи с этим, если, например, изменяется количество инстансов siebel, необходимо изменять соответствующие переменные в скрипте, которые помогают определять работу Siebel. Эти переменные вынесены в начало функций isSiebelStop() и isSiebelStart(). Так же в процессе работы скрипт выводит ожидаемое значение переменных и их реальный показатель, с целью наглядности и отладки.
 
## <a name="StructAssets"></a> Assets
 
В данной папке хранятся скриншоты для визуализации документации
 
## <a name="StructPipelines"></a> Pipelines
 
Существует три пайплайна **dockerBuild.Jenkinsfile**, **generatePatch.Jenkinsfile**, **Jenkinsfile**
 
### <a name="StructPipelinesDockerBuild"></a> dockerBuild.Jenkinsifle
 
Данный пайплайн описывает сборку и публикацию в nexus хранилище образа, используемых в остальных пайплайнах
 
### <a name="StructPipelinesGeneratePatch"></a> generatePatch.Jenkinsfile
 
Данный пайплайн генерирует патч RocketSeibel на основе задач Jira. Проверяет патч на конфликты. В случае конфликтных задач, эти задачи удаляются из патча, а в jira отправляется соответствующее уведомление. Опционально по окончанию выполнения и генерации патча, запускает в работу конвейер RocketSeibel.Deploy
 
### <a name="StructPipelinesJenkinsfile"></a> Jenkinsfile
 
Основной пайплайн. Деплоит патч RocketSeibel
 
## <a name="StructScripts"></a> Scripts
 
Содержит различные скрипты, которые используются в пайплайнах.
 
В данный момент есть:
 
* docker-run-ansible.sh
* Dockerfile
 
### <a name="StructScriptsDockerRunAnsible"></a> docker-run-ansible.sh
 
Используется в generatePatch.Jenkinsfile и Jenkinsfile. Запускает docker образ с передачей соответствующих аргументов, для работы в нем ansible плейбуков.
 
### <a name="StructScriptsDockerRunAnsible"></a> Dockerfile
 
Описание docker образа, используемого в пайплайнах
 
# <a name="Docker"></a> Docker
 
## <a name="DockerImage"></a> Docker образ используемый в пайплайнах
 
Все пайплайны, за исключение Docker.Build.Dev, выполняются в docker контейнерах. Используется кастомный docker контейнер, который задаётся в скрипте docker-run-ansible.sh. Для проекта siebel-cicd в nexus, в репозитории `docker-registry` создана специальная папка `siebel-cicd`, в которой хранятся все собранные docker image.
 
## <a name="DockerBuildImage"></a> Сборка собственного docker image
 
Для сборки собственного docker image необходимо отредактировать Dockerfile и запустить пайплайн Docker.Build.Dev. Docker образ будет сохранён в репозитории docker-registry/siebel-cicd под именем ansible. В качестве тега образа будет использоваться LABEL, который был проставлен в Dockerfile.
 
# <a name="ParameterizationPipeline"></a> Параметризация для нескольких окружений
 
Для того, чтобы масштабировать пайплайн под другие среды необходимо:
 
1. В Jenkins добавить креды для нового окружения. Подробнее, как добавить креды ниже
2. В файлах pipelines/Jenkinsfile, pipelines/dockerBuild.Jenkinsfile, pipelines/generatePatch.Jenkinsfile в параметрах добавить выбор нового окружения. Подробнее ниже.
3. В папке ansible/environments создать новую папку с названием требуемого окружения. Должно получиться ansible/environments/ENVIRONMENT, где ENVIRONMENT название требуемого окружения.
4. Скопировать в ранее созданную папку ansible/environments/ENVIRONMENT содержимое любой другой папки, описывающей окружение. Например ansible/environments/all.
5. Актуализировать данные во всех yml файлах в папке ansible/environments/ENVIRONMENT, где ENVIRONMENT название нового создаваемого окружения. IP адреса инстансов указываются в файле inventory.yml
6. Если в окружении используется несколько Siebel Web/App/Gate, то подробнее как их добавить описано [ниже](#ParameterizationPipelineAddEnvironmentManyHosts)
 
Необходимо в Jenkins добавить следующие креды с определенным ID:
 
1. AD аккаунт. ID: ENVIRONMENT-cicd-siebel-ad
1. RocketSiebel аккаунт. ID: ENVIRONMENT-cicd-siebel-rocketsiebel
1. DB аккаунт. ID: ENVIRONMENT-cicd-siebel-db
1. Siebel аккаунт. ID: ENVIRONMENT-cicd-siebel-acc
1. SSH ключ. ID: ENVIRONMENT-cicd-siebel-ssh
1. JIRA аккаунт. ID: ENVIRONMENT-jira-user-siebel
 
При этом вместо ENVIRONMENT необходимо подставить название нового окружения.
 
Процесс добавление новых кред Jenkins указан ниже:
 
Находясь в папке Siebel нажимаем **credentials**

В открывшемся окне, внизу страницы находим секцию **Stores scoped to Siebel** и в ней выбираем папку **Siebel**
 
В открывшемся окне выбираем **Siebel-domain**
 
Если нужно добавить новые креды, тослева нажимаем **Add Credentials**
 
Если нужно обновить текущие креды, то напротив требуемых нажимаем:
 
В открывшемся окне добавляем соответствующие креды.
 
* В качестве kind указываем **Username with password** (исключение **ENVIRONMENT-cicd-siebel-ssh**)
* Username - имя пользователя
* Password - пароль
* ID - ID креды **строго** определенного вида. Пример: **ENVIRONMENT-cicd-siebel-ad**. Список требуемых ID указан выше.
* Description - описание креды.
 
Соответственно необходимо заменить **ENVIRONMENT** на название требуемого окружения
 
Если креда с ID **ENVIRONMENT-cicd-siebel-ssh**
 
* В качестве kind указываем **SSH Username with private key**
* ID - ID креды **строго** **ENVIRONMENT-cicd-siebel-ssh**, где **ENVIRONMENT** название требуемого окружения
* Username - username от используемого SSH аккаунта
* Private Key - необходимо загрузить **приватную часть** SSH ключа
* Passphrase - необязательный параметр. Необходимо указать пароль от приватного ключа при его наличии
 
## <a name="ParameterizationPipelineAddEnvironment"></a> Добавление окружения в Jenkinsfile
 
Во всех Jenkinsfile необходимо найти строку вида **choice(name: 'ENVIRONMENT', choices: ['test'], description: 'What environment to deploy')**. Она находится в блоке **parameters** в самом низу. Пример:
 

В данной строке необходимо дописать название нового окружения в блок **choices**. Например:
 
Было:
 
* choice(name: 'ENVIRONMENT', choices: ['test'], description: 'What environment to deploy')
 
Стало:
 
* choice(name: 'ENVIRONMENT', choices: ['test'**, 'cert'**], description: 'What environment to deploy')
 
## <a name="ParameterizationPipelineAddEnvironmentManyHosts"></a> Добавление нескольких хостов Siebel App/Web/Gate в рамках одного окружения
 
Добавление хостов происходит внутри файла inventory.yml, который соответствует требуемому окружению. Соответственно, если нам необходимо добавить новый хост в cert окружение, то необходимо править файл ansible/environments/**cert**/inventory.yml
 
Рассмотрим добавление хоста Siebel App и Siebel Web на примере.
 
1. Предположим, что в данный момент в окружении cert имеет один хост Siebel App и Siebel Web. Соответственно inventory.yml выглядит следующим образом:
 

2. Для того, чтобы добавить новые хосты необходимо дописать в файл информацию о новых хостах по аналогии с имеющимся. **Важно!** названия разных хостов не должны совпадать! Если есть хост с названием siebel_1, то другого хоста с таким именем уже быть не должно. Пример:
 
 
3. Теперь в папке ansible/environments/**cert**/host_vars необходимо создать файлы .yml, которые будут иметь названия добавленных хостов. В данном примере были добавлены хосты siebel_2 и siebel_web_2, соответственно файлы должны иметь названия **siebel_2.yml** и **siebel_web_2.yml**. Переменные, которые должны содержаться в данных файлах, можно скопировать из аналогичных файлов **siebel_1.yml** и **siebel_web_2.yml** соответственно.
 
 
4. После создания файлов необходимо заменить переменные в только что созданных файлах на актуальные для хостов.
 
### <a name="ParameterizationPipelineAddEnvironmentGate"></a> Добавление Siebel Gate
 
В версии Siebel 16.19 работает только с одним Siebel Gate. Соответственно, для каждой инсталяции Siebel App есть свой Siebel Gate. Его IP необходимо указать в файле с переменными siebel хоста. Например в ansible/environment/test/siebel_1.yml
 
# <a name="Pipelines"></a> Работа пайплайнов
 
Основные этапы работы пайплайнов происходят путем запуска ansible playbook. Плейбуки лежат по пути `ansible/playbooks` Запускается плейбук внутри Docker контейнера ([Подробнее](#DockerImage)), а не напрямую на агенте. Запускается docker контейнер из Jenkinsfile, путем вызова bash скрипта docker-run-ansible.sh (лежит по пути `scripts/docker-run-ansible.sh`), который в свою очередь копирует внутрь контейнера плейбук и запускает его. Все скрипты, которые необходимы для работы пайплайна запускаются плейбуком и так же работают внутри контейнера.
 
## <a name="PipelinesRocketSiebelGeneratePatch"></a> RocketSiebel.GeneratePatch
 
Пайплайн описан в файле `pipelines/generatePatch.Jenkinsfile`. Для своей работы использует плейбук `generate-patch.yml`, который находится по следующему пути: `ansible/playbooks/generate-patch.yml`
 
Состоит из следующих стадий:
 
* [Checkout](#PipelinesRocketSiebelGeneratePatchStageCheckout)
* [Get issue jira](#PipelinesRocketSiebelGeneratePatchStageGetIssueJira)
* [Create Siebel patch](#PipelinesRocketSiebelGeneratePatchStageCreateSiebelPatch)
* [Get conflict patch](#PipelinesRocketSiebelGeneratePatchStageGetConflictPatch)
* [Create release branch](#PipelinesRocketSiebelGeneratePatchStageCreateReleaseBranch)
* [Import_dop_object](#PipelinesRocketSiebelGeneratePatchStageImportDopObject)
* [Resolve conflict patch](#PipelinesRocketSiebelGeneratePatchStageResolveConflictPatch)
* [Merge patch](#PipelinesRocketSiebelGeneratePatchStageMergePatch)
* [Sleep to start RocketSeibel.Deploy](#PipelinesRocketSiebelGeneratePatchStageSleepToStartRocketSeibelDeploy)
* [Push release branch](#PipelinesRocketSiebelGeneratePatchStagePushReleaseBranch)
* [Start RocketSeibel.Deploy](#PipelinesRocketSiebelGeneratePatchStageStartRocketSeibelDeploy)
* [Merge release branch](#PipelinesRocketSiebelGeneratePatchStageMergeReleaseBranch)
* [Add 'Development object' labels](#PipelinesRocketSiebelGeneratePatchStageAddDevelopmentObjectLabels)
* [Send result comments in Jira](#PipelinesRocketSiebelGeneratePatchStageSendResultCommentsInJira)
* [Set status tasks in Jira](#PipelinesRocketSiebelGeneratePatchStageSetStatusTasksInJira)
 
В основе его работы лежит скрипт, написанный на python3 и который находится в каталоге `ansible/playbooks/templates/generate-patch.py.j2`. В данном каталоге лежит шаблонизированная Jinja2 версия. Это означает, что для его работы необходимо подставить требуемые шаблоном переменные. Переменные автоматически подставляются ansible во время работы пайплайна. Данные переменные находятся в каталоге `ansible/playbooks/environments/ENVIRONMENT`, где `ENVIRONMENT` название среды, в которой запускается пайплайн.
 
Подробнее о работе каждой стадии описано ниже.
 
### <a name="PipelinesRocketSiebelGeneratePatchParameters"></a> Параметры запуска


* GENERATE_PATCH_NAME - название генерируемого патча RocketSiebel. Может принимать любое значение. Пример: `080420-214dailyfix-night`
* SKIP_* (вместо * указано название шага) - служит для пропуска какой либо из стадии пайплайна. Например, если необходимо пропустить стадию **Get issue jira** необходимо отметить параметр **SKIP_GET_ISSUE_JIRA**
* SLEEP_TO_START_ROCKETSIEBEL_DEPLOY - указывает, какая задержка должна быть на стадии **Sleep to start RocketSeibel.Deploy**. [Подробнее о стадии](#PipelinesRocketSiebelGeneratePatchStageSleepToStartRocketSeibelDeploy) Указывать строго цифры. Указывать задержку необходимо в секундах.
*  <a name="PipelinesRocketSiebelGeneratePatchParametersListStatusTasksJira"></a> LIST_STATUS_TASKS_JIRA - список статусов, которые необходимо установить задачам в рамках стадии **Set status tasks in Jira**. [Подробнее о стадии](#PipelinesRocketSiebelGeneratePatchStageSetStatusTasksInJira). Писать статусы необходимо **строго** как они указаны в Jira. Пример:
 
 
Данная задача имеет два возможных статуса. Это **On Hold** и **В UAT пройден**. Соответственно, чтобы перевести данную задачу в **UAT** необходимо в LIST_STATUS_TASKS_JIRA указать **В UAT пройден**.
 
Если необходимо передать больше одного статуса, необходимо их разделить ; с пробелом. Пример: `Передать на FAT; В FCT; Testing;`
 
* BRANCH - указывает, из какой ветки репозитория Siebel CICD необходимо клонировать код на агент.
* ENVIRONMENT - указывает, на какую среду необходимо производить деплой.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageCheckout"></a> Checkout
 
Выгружает код репозитория Siebel CICD из Bitbucket на агент. Это происходит с помощью Jenkins.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageGetIssueJira"></a> Get issue jira
 
Получает список тасок в Jira, которые войдут в создаваемый патч. Получает путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch), который в свою очередь запрашивает их путем запроса к API Jira, где получает их список исходя из фильтра. Номер фильтра задается в файле `ansible/environments/ENVIRONMENT/localhost.yml`, где `ENVIRONMENT` название окружения, в который происходит деплой, в параметре `jira_filter`.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageCreateSiebelPatch"></a> Create Siebel patch
 
Создает Siebel patch. Создает путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch), который в свою очередь отправляет запрос к API RocketSiebel. Во время работы скрипта так же происходит проверка, что все требуемые таски из Jira существуют в RocketSiebel. Если какие то таски не существуют, они не добавляются в патч.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageGetConflictPatch"></a> Get conflict patch
 
Проверяет наличие конфликтов в патче, который был создан на стадии [Create Siebel patch](#PipelinesRocketSiebelGeneratePatchStageCreateSiebelPatch). Проверяет путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch), который в свою очередь отправляет запрос к API RocketSiebel. Если в патче есть конфликты, то предлагается их разрешить до окончании таймаута. Так же по конфликтующим таскам отправляется сообщение в чат-бот Telegramm о наличии конфликтов.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageCreateReleaseBranch"></a> Create release branch
 
Конвеер откалывает ветку test_dd.mm.yyyy_build_n от ветки test\cert\master. Собирает задачи JIRA в статусе "Разработка Завершена" по ним находит ветку GIT по номеру задачи и делает cherry-pick этих изменений (commit-ов) в ветку test_dd.mm.yyy_build_n. После обработки всех задач делает pull request ветки test_dd.mm.yyyy_build_n в ветку test. Происходит путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch)
 
### <a name="PipelinesRocketSiebelGeneratePatchStageImportDopObject"></a> Import dop object
 
Параметр, который передаётся на стадию [RocketSeibel.Deploy](#PipelinesRocketSeibelDeploy). Если этот шаг указан к выполненю, то на этапе [RocketSeibel.Deploy](#PipelinesRocketSeibelDeploy) будет выполняться установка доп объектов.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageSleepToStartRocketSeibelDeploy"></a> Sleep to start RocketSeibel.Deploy
 
Приостанавливает работу пайплайна на N секунд, где N количество секунд указанных в параметре **SLEEP_TO_START_ROCKETSIEBEL_DEPLOY** при запуске пайплайна.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageResolveConflictPatch"></a> Resolve conflict patch
 
Проверяет наличие конфликтов в патче, который был создан на стадии [Create Siebel patch](#PipelinesRocketSiebelGeneratePatchStageCreateSiebelPatch). Проверяет путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch), который в свою очередь отправляет запрос к API RocketSiebel. Если в патче есть конфликты, то конфликтующие задачи из патча удаляются. Так же конфликтующим таскам отправляется сообщение в Jira о наличии конфликтов.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageMergePatch"></a> Merge patch
 
Происходит мердж патча, созданного на предыдущих этапах пайплайна. Происходит путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch), который в свою очередь отправляет запрос к API RocketSiebel.
 
### <a name="PipelinesRocketSiebelGeneratePatchStagePushReleaseBranch"></a>  Push release branch
 
Конвеер откалывает ветку test_dd.mm.yyyy_build_n от ветки test\cert\master. Собирает задачи JIRA в статусе "Разработка Завершена" по ним находит ветку GIT по номеру задачи и делает cherry-pick этих изменений (commit-ов) в ветку test_dd.mm.yyy_build_n. После обработки всех задач делает pull request ветки test_dd.mm.yyyy_build_n в ветку test. Если pull request прошел без ошибок - добавляет созданную ветку в Bitbucket. Происходит путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch)
 
### <a name="PipelinesRocketSiebelGeneratePatchStageStartRocketSeibelDeploy"></a> Start RocketSeibel.Deploy
 
Запускает в работу пайплайн RocketSeibel.Deploy. Запускает с помощью Jenkins. Для запуска пайплайна RocketSeibel.Deploy передает текущие параметры **GENERATE_PATCH_NAME**, **ENVIRONMENT**, **SIEBEL_CICD_BRANCH**, **SIEBEL_NRT_BRANCH**, **IMPORT_DOP_OBJECT**, **CREATE_SIEBEL_PATCH**, **THE_PATCH_IN_ROCKET_SIEBEL_ALREADY_BEEN_BUILT**.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageMergeReleaseBranch"></a> Merge release branch
 
Сливает ветку, созданную на этапе Crate Release Branch в ветку test\cert\master. Происходит путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch)
 
### <a name="PipelinesRocketSiebelGeneratePatchStageAddDevelopmentObjectLabels"></a> Add 'Development object' labels
 
Добавляет задачам в Jira, которые содержатся в патче, метку с названием патча в поле 'Development object'. Добавлением происходит путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch). Он в свою очередь совершает запрос к API RocketSiebel, в рамках которого получает список тасков, включенных в патч. Затем путем вызова API Jira проставляет метки. Таким образом, данную стадию пайплайна можно использовать независимо от других, если необходимо проставить метки таскам, включенным в патч. Для этого необходимо указать параметр **GENERATE_PATCH_NAME** и пропустить все другие стадии пайплайна.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageSendResultCommentsInJira"></a> Send result comments in Jira
 
Отправляет сообщение об успешно установки патча таскам в Jira, которые содержатся в патче. Отправка сообщений происходит путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch). Он в свою очередь совершает запрос к API RocketSiebel, в рамках которого получает список тасков, включенных в патч. Затем рассылает сообщение полученному списку тасков. Таким образом, данную стадию пайплайна можно использовать независимо от других, если необходимо только разослать сообщение об успешности установки патча. Для этого необходимо указать параметр **GENERATE_PATCH_NAME** и пропустить все другие стадии пайплайна.
 
### <a name="PipelinesRocketSiebelGeneratePatchStageSetStatusTasksInJira"></a> Set status tasks in Jira
 
Устанавливает таскам в Jira, которые содержатся в патче, один из переданных статусов при запуске пайплайна в параметре **LIST_STATUS_TASKS_JIRA** ([подробнее, как передавать список статусов](#PipelinesRocketSiebelGeneratePatchParametersListStatusTasksJira)). Установка статусо происходит путем вызова скрипта [generate-patch.py](#StructAnsibleGenerate-patch). Он в свою очередь совершает запрос к API RocketSiebel, в рамках которого получает список тасков, включенных в патч. Затем определяет для каждой задачи в Jira подходящий статус (при наличии) и устанавливает его. Если статус для задачи не найден, то статус задачи не меняется. Таким образом, данную стадию пайплайна можно использовать независимо от других, если необходимо только проставить статусы таскам, включенных в патч. Для этого необходимо указать параметры **GENERATE_PATCH_NAME** и **LIST_STATUS_TASKS_JIRA** и пропусти все другие стадии пайплайна.
 
## <a name="PipelinesRocketSeibelDeploy"></a> RocketSeibel.Deploy
 
Пайплайн описан в файле `pipelines/Jenkinsfile`. Для своей работы использует плейбук `deploy.yml`, который находится по следующему пути: `ansible/playbooks/deploy.yml`
 
Состоит из следующих стадий:
 
* [Checkout](#PipelinesRocketSeibelDeployStageCheckout)
* [Download patch](#PipelinesRocketSeibelDeployStageDownloadPatch)
* [Prepare patch](#PipelinesRocketSeibelDeployStagePreparePatch)
* [Create backup repo](#PipelinesRocketSeibelDeployStageCreatebackuprepo)
* [Create backup rocket adm](#PipelinesRocketSeibelDeployStageCreatebackuprocketadm)
* [Create Workspace](#PipelinesRocketSeibelDeployStageCreateWorkspace)
* [Rename WF](#PipelinesRocketSeibelDeployStageRenameWF)
* [Update WF DB](#PipelinesRocketSeibelDeployStageUpdateWFDB)
* [Lock Objects](#PipelinesRocketSeibelDeployStageLockObjects)
* [Import SIF](#PipelinesRocketSeibelDeployStageImportSIF)
* [CheckWorkspace](#PipelinesRocketSeibelDeployStageCheckWorkspace)
* [Apply DDL](#PipelinesRocketSeibelDeployStageApplyDDL)
* [IncrementalTablePublish](#PipelinesRocketSeibelDeployStageIncrementalTablePublish)
* [Checkpoint Workspace](#PipelinesRocketSeibelDeployStageCheckpointWorkspace)
* [Deliverworkspace](#PipelinesRocketSeibelDeployStageDeliverworkspace)
* [Import ADM](#PipelinesRocketSeibelDeployStageImportADM)
* [Import dop object](#PipelinesRocketSeibelDeployStageImportdopobject)
* [Import manual ADM](#PipelinesRocketSeibelDeployStageImportManualADM)
* [Deploy dop Web Frontend](#PipelinesRocketSeibelDeployStageDeploydopWebFrontend)
* [Import dop DB](#PipelinesRocketSeibelDeployStageImportdopDB)
* [Backup results](#PipelinesRocketSeibelDeployStageBackupResults)
* [Ping](#PipelinesRocketSeibelDeployStagePing)
* [Restart Siebel Web servers](#PipelinesRocketSeibelDeployStageRestartSiebelWebservers)
* [Restart Siebel Component](#PipelinesRocketSeibelDeployStageRestartSiebelComponent)
 
В основе его работы лежат два скрипта, написанные на bash и  powershell. Они находятся по следующему пути: `ansible/playbooks/templates/siebrunner.ps1.j2` и `ansible/playbooks/templates/siebwrapper.sh.j2`. В данном каталоге лежат шаблонизированные Jinja2 версии. Это означает, что для их работы необходимо подставить требуемые шаблоном переменные. Переменные автоматически подставляются ansible во время работы пайплайна. Данные переменные находятся в каталоге `ansible/playbooks/environments/ENVIRONMENT`, где `ENVIRONMENT` название среды, в которой запускается пайплайн.
 
По результатам работы пайплайна рассылаются письма, указанным в `pipelines/Jenkinsfile` адресатам.
 
### <a name="PipelinesRocketSeibelDeployParameters"></a> Параметры запуска
 
Данный пайплайн имеет следующие параметры запуска:
 
![rocketsiebel-deploy-parameters.png](assets/rocketseibel-deploy-parameters.png)
 
Подробнее о параметрах:
 
* PATCH_NAME - название патча RocketSiebel для деплоя. Может принимать любое значение. Пример: `080420-214dailyfix-night`
* SKIP_* (вместо * указано название шага) - служит для пропуска какой либо из стадии пайплайна. Например, если необходимо пропустить стадию **Download patch** необходимо отметить параметр **SKIP_DOWNLOAD_PATCH**
* INITIATOR_EMAIL - указывается почта, от имени которой будет по итогу рассылаться сообщения об успешности работы пайплайна.
* SIEBEL_CICD_BRANCH - указывает, из какой ветки репозитория Siebel CICD необходимо клонировать код на агент.
* ENVIRONMENT - указывает, на какую среду необходимо производить деплой.
* THE_PATCH_IN_ROCKET_SIEBEL_ALREADY_BEEN_BUILT - необходимо выбрать Yes\No. Указывает собран ли патч в RocketSiebel.
* SIEBEL_NRT_BRANCH - указывает, из какой ветки репозитория Siebel NRT будет выполняться deploy доп объектов на серверы Web и App.
* ANSIBLE_ARGS_FOR_SIEBEL_WEB_RESTART - указывает требуется ли выполнять рестарт Tomcat на Web-серверах.
* SIEBEL_COMPONENTS_FOR_RESTART - список компонент в srvmgr для  их рестарта.
 
### <a name="PipelinesRocketSeibelDeployStageCheckout"></a> Checkout SIEBEL-CICD
 
Выгружает код репозитория Siebel CICD из Bitbucket на агент. Это происходит с помощью Jenkins.
 
### <a name="PipelinesRocketSeibelDeployStageCheckout"></a> Checkout SIEBEL-NRT
 
Выгружает код репозитория Siebel NRT из Bitbucket на агент в том случае, если будет выполняться стадия Deploy Web Frontend или Import manual ADM. Это происходит с помощью Jenkins.
### <a name="PipelinesRocketSeibelDeployStageDownloadPatch"></a> Download patch
 
На данной стадии происходит скачивание патча и информации о тасках в патче из RocketSiebel на jenkins агент. Скачивается патч в виде .zip архива. Скачивается путем выполнения основного плейбука deploy.yml с тегом download-patch. При этом задания выполняются из плейбука ./siebel-cicd/ansible/playbooks/deploy/download-patch.yml
 
### <a name="PipelinesRocketSeibelDeployStagePreparePatch"></a> Prepare patch
 
На данной стадии происходит подготовка патча к работе. Данная стадия выполняется на хосте RocketSiebel с помощью ansible. Происходит копирование патча, который был скачан на шаге [Download patch](#), с jenkins агента на хост RocketSiebel. На хосте RocketSiebel он разархивируется. Так же в рамках данного этапа создается структура каталогов, которая требуется для дальнейшей работы пайплайна. Так же на хост RocketSiebel копируется скрипт siebrunner.ps1, для его дальнейшего запуска в рамках других этапов пайплайна.
 
### <a name="PipelinesRocketSeibelDeployStageLockObjects"></a> Lock Objects
 
На данной стадии происходит блокировка объектов Siebel. Данная стадия выполняется на хосте RocketSiebel с помощью ansible. Происходит вызов скрипта siebrunner.ps1, который путем отправки SQL запроса в БД блокирует объекты.
 
### <a name="PipelinesRocketSeibelDeployStageExpireWorkflow"></a> Expire Workflow
 
На данной стадии происходит установка статуса **NOT_IN_USE** для workflow в патче RocketSiebel. Данная стадия выполняется на хосте RocketSiebel с помощью ansible. Происходит вызов скрипта siebrunner.ps1, который путем отправки SQL запроса в БД устанавливает требуемый статус.
 
### <a name="PipelinesRocketSeibelDeployStageImportSIF"></a> Import SIF
 
На данной стадии происходит импортирование SIF объектов. Данная стадия выполняется на хосте RocketSiebel с помощью ansible. Происходит вызов скрипта siebrunner.ps1, который путем вызова утилиты siebdev.exe импортирует ранее сохраненные во время выполнения этапа [Prepare patch](#) на хосте RocketSiebel SIF объекты.
 
### <a name="PipelinesRocketSeibelDeployStageApplyDDL"></a> Apply DDL
 
На данной стадии происходит перенос схемы БД из dev БД в Siebel БД. Данная стадия выполняется на хосте RocketSiebel с помощью ansible. Происходит вызов скрипта siebrunner.ps1, который путем вызова утилиты ddldict.exe генерирует ddl файл, который содержит мета описание всех таблиц схемы SIEBEL, а затем передает созданный ddl файл утилите ddlimp.exe, которая применяет схему на новой БД.
 
### <a name="PipelinesRocketSeibelDeployStageCompileSRF"></a> Compile SRF
 
На данной стадии происходит компиляция srf объекта. Данная стадия выполняется на хосте RocketSiebel с помощью ansible. Происходит вызов скрипта siebrunner.ps1, который путем вызова утилиты siebdev.exe запускает компиляцию srf объекта.
 
### <a name="PipelinesRocketSeibelDeployStageDeploySRF"></a> Deploy SRF
 
На данной стадии происходит деплой ранее скомпилированного srf объекта. Данная стадия выполняется на хосте Siebel с помощью ansible. Сначала на агент копируются скрипт siebwrapper.sh, с помощью которого в дальнейшем и будут производиться действия на хосте. После этого на jenkins агент скачивается srf объект с хоста RocketSiebel, который затем копируется на Siebel хост с jenkins агента. После этого вызывается скрипт siebwrapper.sh, который останавливает Siebel. Затем с помощью ansible заменяются srf файлы на актуальные. После замены srf файлов опять вызывается скрипт siebwrapper.sh, который запускает ранее остановленный Siebel.
 
### <a name="PipelinesRocketSeibelDeployStageImportADM"></a> Import ADM
 
На данной стадии происходит импорт ADM файлов. Данная стадия выполняется на хосте RocketSiebel с помощью ansible. Проверяется, существует ли каталог с ADM файлами. Если каталог существует, то на агент копируется конфигурационный файл клиента RocketSiebel rs-client.cfg, а затем вызывается скрипт siebrunner.ps1, который в свою очередь путем вызова утилиты siebel-import-cli.jar импортирует ADM объекты. Затем на jenkins агент выгружается информация об импортированных ADM объектах.
 
 
### <a name="PipelinesRocketSeibelDeployStageImportdopobject"></a> Import dop object
 
Данный этап включает в себя три подэтапа:
-Import manual ADM
-Deploy dop Web Frontend
-Import dop DB
### <a name="PipelinesRocketSeibelDeployStageImportManualADM"></a> Import manual ADM
 
На данной стадии происходит импорт вручную созданных ADM файлов. Данная стадия выполняется на jenkins агенте с помощью ansible. На jenkins агент клонируется репозиторий Siebel NRT. Генерируется список всех файлов ADM, затем считывается список установленных файлов и формируется список файлов, которые еще не были установлены. Затем ansible подключается к Siebel и загружает на этот хост ADM файлы. После этого сохраняет информацию о новых установленных файлах ADM в git репозиторий Siebel NRT.
 
### <a name="PipelinesRocketSeibelDeployStageDeploydopWebFrontend"></a> Deploy dop Web Frontend
 
На данной стадии происходит деплой Web фронтенда. Данная стадия выполняется на хостах Siebel и Siebel Web с помощью ansible. Файлы копируются в соответствии с их dest. Фолдер cc-react единственная из всех папок которая перед копированием на хост Siebel Web удаляет содержимое и потом происходит синхронизация файлов с репозиторным.
 
### <a name="PipelinesRocketSeibelDeployStageImportdopDB"></a> Import dop DB
 
На данной стадии происходит сначала diff между ветками test/cert/prod и релизной веткой на наличие изменений. Если в ветках обнаруженны различия он запускает ansible скрипт который копирует содежимое папки DB на хост рокетсибеля. Если различий нету после выполнения команды git diff, он выводит сообщение что изменений нету.
### <a name="PipelinesRocketSeibelDeployStageActivateWorkFlow"></a> Activate WorkFlow
 
На данной стадии происходит активация WorkFlow в Siebel Web. Данная стадия выполняется на хосте RocketSiebel с помощью ansible. Происходит вызов скрипта siebrunner.ps1 который путем отправки специально оформленных POST запросов активироует WorkFlow.
 
 
 
### <a name="PipelinesRocketSeibelDeployStageBackupResults"></a> Backup results
 
На данной стадии выполняется резервная копия сделанных изменений в репозиторий Nexus. Данная стадия выполняется на хосте RocketSiebel и jenkins агенте с помощью ansible. Первоначально, на хосте RocketSiebel полученные в рамках работы пайплайна файлы упаковываются в zip архив. Затем полученный zip архив выгружается на jenkins агент. После этого, на jenkins агенте происходит выгрузка zip архива в nexus репозиторий.
 
### <a name="PipelinesDockerBuildDev"></a> Docker.Build.Dev
 
Пайплайн описан в файле `pipelines/dockerBuild.Jenkinsfile`.
 
Состоит из следующих стадий:
 
* [Checkout](#PipelinesDockerBuildDevStageCheckout)
* [Build image](#PipelinesDockerBuildDevStageBuildImage)
* [Publish](#PipelinesDockerBuildDevStagePublish)
 
### <a name="PipelinesDockerBuildDevParameters"></a> Параметры запуска
 
Данный пайплайн имеет следующие параметры запуска:
 
![docker-build-dev-parameters.png](assets/docker-build-dev-parameters.png)
 
Подробнее о параметрах:
 
* BRANCH - указывает, из какой ветки репозитория Siebel CICD необходимо клонировать код на агент.
 
### <a name="PipelinesDockerBuildDevStageCheckout"></a> Checkout
 
Выгружает код репозитория Siebel CICD из Bitbucket на агент. Это происходит с помощью Jenkins.
 
### <a name="PipelinesDockerBuildDevStageBuildImage"></a> Build image
 
Собирает docker образ на агенте. Dockerfile находится по пути `scripts/Dockerfile`. [Подробнее о сборке Docker образов](#Docker)
 
### <a name="PipelinesDockerBuildDevStagePublish"></a> Publish# old_pipeline_rosbank
