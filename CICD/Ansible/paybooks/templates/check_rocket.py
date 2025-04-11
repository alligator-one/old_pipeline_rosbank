# Поиск пересекающихся объектов в Rocket и JIRA
from datetime import datetime
import urllib3
import requests
import re
from requests.auth import HTTPBasicAuth
from jira import JIRA
import sys
 
projects = [
    "Digital-PRO-P18150",  # PRODBO
    "Siebel Platform Team",  # SPT
    "Siebel CRM",  # CRM
    "Siebel CRM CORP",  # PCCRM
    "EXPRESS BANKING GUARANTEES",  # DBG
    "Trade Finance Platform",  # TFP
    "CARD Product"  # CARD
]
 
projects = [
    "Siebel Platform Team",  # SPT
    "Siebel CRM CORP"  # PCCRM
]
 
projects = [
    "Siebel Platform Team"  # SPT
]
 
statuses_SPT = ["DEV CHECK", "РАЗРАБОТКА ЗАВЕРШЕНА", "FCT", "FCT DONE", "UAT", "UAT ПРОЙДЕН"]
statuses_CARD = ["DEV CHECK", "DEVELOPMENT DONE",  "FCT", "FCT DONE", "UAT", "UAT ПРОЙДЕН"]
statuses_TFP = ["DEVELOPMENT DONE", "INSTALLATION TEST", "INSTALLATION TEST DONE", "FCT", "FCT DONE","INSTALLATION CERT DONE", "UAT", "UAT DONE"]
 
all_wfs = []
check_task_1 = ''
 
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
 
def sendStatusTelegram(text):
    tg_apim_consumer_key = '***'
    tg_apim_consumer_secret = '***'
    token_url = 'APIM_SERVER/oauth2/token?grant_type=client_credentials'
    token_headers = {'Content-type': 'application/json'}
    token_body = '{}'
    token_body = token_body.encode('utf-8')
    token_responce = requests.post(token_url, headers=token_headers, data=token_body, verify=False, auth=(tg_apim_consumer_key, tg_apim_consumer_secret))
    token = str(token_responce.content).split('"')[3]
#    print('====================== token ==========================')
#    print(str(token_responce.content))
    print('====================== token_split ==========================')
    print(str(token_responce.content).split('"')[3])
    tg_bot_token = '***'
    tg_group_id = '***'
    headers = {'Content-type': 'application/json', 'AuthorizationWSO': 'Bearer ' + token}
    body = '{"token":"' + tg_bot_token + '","id":"' + tg_group_id + '","text":"' + text + '"}'
    body = body.encode('utf-8')
    url = 'TELEGRAM_SERVER/Telegram/3.0/sendmessage'
    response = requests.post(url, headers=headers, data=body, verify=False)
    print('========================== SEND MESSAGE TELEGRAM ==========================')
    print(url)
    print(text)
    print(body)
    print(response)
    print(str(response.content))
    print('====================== END SEND MESSAGE TELEGRAM ==========================')
 
 
 
# получаем все задачи из рокета
def get_all_fws(env):
    print("---Получим все задачи из Рокет---")
    url = f"ROCKET_SIEBEL/SiebelConfigurator/api/featureBranches/listnew/{env}"
    response = requests.get(url=url,
                            auth=HTTPBasicAuth('***',
                                               '***'), verify=False)
    json_data = response.json()
 
    for name in json_data:
        feature = (name["featureName"])
        # print(feature)
 
        all_wfs.append(feature)
    print(f"Всего задач в Рокет: {len(all_wfs)}")
 
# Получаем wf по имени задачи из рокета
def get_fws(task):
    # print(f"проверяем {task}")
    # SPT-17770-TEST
    # url = f"SIEBEL_SERVER/SiebelConfigurator/api/featureBranches/diffnew/my/objectNames/dev:{task}"
    url = f"https:SIEBEL_SERVER/SiebelConfigurator/api/featureBranches/diffnew/internal/dev:{task}"
    wfs = []
    response = requests.get(url=url,
                            auth=HTTPBasicAuth('***',
                                               '***'), verify=False)
    json_state = response.status_code
 
    if json_state == 200:
        json_data = response.json()
 
        for name in json_data:
            objects = (name["items"][0]["items"])
            for object in objects:
                for k, v in object.items():
 
                    # print(f"{k}, {v}")
                    if v == "Workflow Process":
                        for l, m in object.items():
                            if l == 'items':
                                for wf in m:
                                    #print(wf["name"])
                                    wfs.append(wf["name"])
                                # print(len(m))
    return wfs
 
 
def getIssueFromJira(filter):
    jira_options = {'server': "JIRA", 'verify': False}
    jira = JIRA(
        auth=("***", "***"),
        options=jira_options
    )
    tasks = jira.search_issues(jql_str=f"filter={filter}", maxResults=False)
    print(f"Задачи из Джира: {tasks}")
    return tasks
 
def getAllFromJira(project):
    jira_options = {'server': "JIRA", 'verify': False}
    jira = JIRA(
        auth=("***", "***"),
        options=jira_options
    )
    # print(f"---Получим все задачи из Jira в проекте : {project}---")
    statuses = f'project="{project}" AND (status = "{statuses_SPT[0]}"'
    for status in statuses_SPT[1:]:
        statuses = statuses + f' OR status = "{status}"'
    statuses = statuses + ')'
    all_tasks = jira.search_issues(f'{statuses}', maxResults=False)
    # print(f"Всего задач в проекте Jira {project}: {(str(len(all_tasks)))}")
    return all_tasks
 
    # for task in all_tasks:
    # pass
    # print(task)
    # return all_tasks
 
 
def getStatusFromJira(task):
    jira_options = {'server': "JIRA_SERVER", 'verify': False}
    jira = JIRA(
        auth=("***", "***"),
        options=jira_options
    )
    #  print(f"---start getting status of task {task}---")
 
    new_issue = jira.search_issues("id = " + task, startAt=0, maxResults=False)
    for issue in new_issue:
        task_stat = []
        key = issue.key
        issue = jira.issue(key, fields="status, created, issuetype")
        stat2 = issue.fields.status
        task_date = issue.fields.created
        task_type = issue.fields.issuetype
        task_stat.append(stat2)
        task_stat.append(task_date)
        task_stat.append(task_type)
        #print('***type***')
        #print(task_type)
        # print(task_date)
        # task_stat.append(stat2, task_date)
        # = {stat2, task_date}
        # print(task_stat)
    return task_stat
 
def return_pr(task1, task_1):
    # print(task1)
    stop = "-"
    pr = (re.search(fr'(.+?){stop}', task1).group(1))
    if pr == 'SPT' or pr == 'CRM' or pr == 'PCCRM':
        # print(check_status_1)
        # print(statuses_SPT.index(task_1.upper()))
        #if task_1 == 'PCCRM-8176':
        #    return 5
        return statuses_SPT.index(task_1.upper())
    if pr == 'CARD':
        # print(check_status_1)
        # print(statuses_SPT.index(task_1.upper()))
        return statuses_CARD.index(task_1.upper())
    if pr == 'CARD':
        # print(check_status_1)
        # print(statuses_SPT.index(task_1.upper()))
        return statuses_CARD.index(task_1.upper())
    if pr == 'TFP':
        # print(check_status_1)
        # print(statuses_SPT.index(task_1.upper()))
        return statuses_CARD.index(task_1.upper())
 
print("***start check rocket***")
get_all_fws("dev")
check_wf = []
# 21403 - cert
# 36091 - devupg
Jira_Tasks = getIssueFromJira("36091") # devupg
#Jira_Tasks = getIssueFromJira("37144")  # prod
for task in Jira_Tasks:
    print(f"Проверяем, есть ли у задачи из {task} wf в Рокете")
    task = str(task)
    check_task_1 = (getStatusFromJira(task))
    # if task == ''
    # date_to_check = (getStatusFromJira(task[1]))
    if task in all_wfs:
        if len(get_fws(task)) > 0:
            print(f"wf в задаче {task} найден!")
            # print(f"тип задачи Джира: {check_task_1[2]}")
            # получить список задач из рокета для задачи
            tasks2 = get_fws(task)  #
            # преобразовать список в множество
           set1 = set(tasks2)
        else:
            set1 = set()
            print(f"---Нет wf в задаче {task}---")
        # ищем все задачи в статусе разработка во всех проектах и для которых заведены задачи в рокете и в которых есть такой же ВФ
        for project in projects:
            issues = getAllFromJira(project)
            for issue in issues:
                stat = issue.fields.status
                name = issue.key
                # print(f"{name} - {stat}")
                n = get_fws(name)
                if len(n) != 0:
                    if task != name:
                        # print(f"---wf из {task} найден в {name}---")
                        # print(getStatusFromJira(name))
                        check_task_2 = (getStatusFromJira(name))
                        date_temp1 = check_task_1[1][:-10]
                        date_temp2 = check_task_2[1][:-10]
                        date1 = datetime.strptime(date_temp1, "%Y-%m-%dT%H:%M:%S")
                        date2 = datetime.strptime(date_temp2, "%Y-%m-%dT%H:%M:%S")
 
                        date1_formatted = date1.strftime("%d/%m/%Y %H:%M:%S")
                        date2_formatted = date2.strftime("%d/%m/%Y %H:%M:%S")
 
                        check_status_1 = str(check_task_1[0]).upper()
                        check_status_2 = str(check_task_2[0]).upper()
 
                        # Если задача из рокета по статусу ниже чем задача из конвейера и задача из конвейера создана раньше чем
                        # задача из рокета
                        # if check_status_2 in statuses_low and check_status_1 in statuses_high:
 
                        print(f"*** Проверяем задачи {task},{name} ***\n со статусами {check_status_1}, {check_status_2} \n c датами: {date1_formatted}, {date2_formatted}")
 
                        if return_pr(task, check_status_1) < return_pr(name,  check_status_2) and date1 < date2:
                            # print(print(getStatusFromJira(name)))
                            print(f"Проверяем задачу {name} на конфликты")
                            set2 = set(n)
                            diff = set1.intersection(set2)
                            if len(diff) != 0:
 
                                print(f"Возможные конфликты в {task}, есть пересечения в {name}:")
                                print(
                                    f"Статус задачи {name} (найдена в Рокете): \"{check_task_2[0]}\" \t \t  Время создания задачи: {date2_formatted}")
                                print(
                                    f"Статус задачи {task} (из конвейера): \"{check_task_1[0]}\" \t \t  Время создания задачи: {date1_formatted}")
 
                                print(f"Найдено пересечений: {len(diff)}")
                                if len(diff) <= 50:
                                    send_text = []
                                    print(f"Возможные пересечения:")
                                    for d in diff:
                                        # pass
                                        # Выводим или добавляем в список найденные пересекающиеся wf
                                        print(f"{d}")
                                        send_text.append(d)
                                    task_to_send = ''
                                    for task_c in send_text:
                                        task_to_send = task_to_send + ''.join(task_c) + ','
 
                                    sendStatusTelegram(f'Конфликтующие задачи: {task} и {name}, workflows: {task_to_send[:-1]} ')
                            else:
                                print(f'В задаче {name} нет конфликта')