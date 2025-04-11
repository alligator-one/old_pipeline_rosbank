@#!/bin/bash
 
. /opt/siebel/ses/siebsrvr/siebenv.sh
 
set -o errexit
 
function isSiebelStarted()
{
    set -o nounset # вызвать ошибку при попытке использовать необъявленную переменную
 
    local SIEBSVC_PROC_COUNTER_EXPECTED={{ SIEBSVC_PROC_COUNTER_EXPECTED_START }}
    local SIEBMP_PROC_COUNTER_EXPECTED={{ SIEBMP_PROC_COUNTER_EXPECTED_START }}
    local SIEB_SRV_CONN_COUNTER_EXPECTED={{ SIEB_SRV_CONN_COUNTER_EXPECTED_START }}
    local SIEB_SRV_TOTAL_COUNTER_EXPECTED={{ SIEB_SRV_TOTAL_COUNTER_EXPECTED_START }}
 
    printf "Check siebel start...\n"
 
    printf "Check SIEBSVC_PROC_COUNTER..."
    local SIEBSVC_PROC_COUNTER=$(ps -ef | egrep 'siebsv[c]' | wc -l)
    printf "OK\n"
    printf "Expected: ${SIEBSVC_PROC_COUNTER} > ${SIEBSVC_PROC_COUNTER_EXPECTED}\n"
 
    printf "Check SIEBMP_PROC_COUNTER..."
    local SIEBMP_PROC_COUNTER=$(ps -ef | egrep 'sieb[mp]' | wc -l)
    printf "OK\n"
    printf "Expected: ${SIEBMP_PROC_COUNTER} > ${SIEBMP_PROC_COUNTER_EXPECTED}\n"
 
    printf "Get SIEB_SRV_RAW..."
    local SIEB_SRV_RAW=$(srvrmgr -g {{ siebel_gate_ip }} -e {{ siebel_gate_server_name }} \
    -u {{ siebel_user }} -p {{ siebel_pass }} -c 'exit' | \
    awk '/^Connected to/ {print($3 " " $10)}')
    printf "OK\n"
    printf "Received: ${SIEB_SRV_RAW}\n"
 
    printf "Check SIEB_SRV_CONN_COUNTER..."
    local SIEB_SRV_CONN_COUNTER=$(echo ${SIEB_SRV_RAW} | awk '{print($1)}')
    printf "OK\n"
    printf "Received: ${SIEB_SRV_CONN_COUNTER} Expected: ${SIEB_SRV_CONN_COUNTER_EXPECTED}\n"
 
    printf "Check SIEB_SRV_TOTAL_COUNTER..."
    local SIEB_SRV_TOTAL_COUNTER=$(echo ${SIEB_SRV_RAW} | awk '{print($2)}')
    printf "OK\n"
    printf "Received: ${SIEB_SRV_TOTAL_COUNTER} Expected: ${SIEB_SRV_TOTAL_COUNTER_EXPECTED}\n"
 
    if ([ "${SIEBSVC_PROC_COUNTER}" -gt ${SIEBSVC_PROC_COUNTER_EXPECTED} ] && \
    [ "${SIEBMP_PROC_COUNTER}" -gt ${SIEBMP_PROC_COUNTER_EXPECTED} ] && \
    [ "${SIEB_SRV_CONN_COUNTER}" -eq ${SIEB_SRV_CONN_COUNTER_EXPECTED} ] && \
    [ "${SIEB_SRV_TOTAL_COUNTER}" -eq ${SIEB_SRV_TOTAL_COUNTER_EXPECTED} ])
    then
        echo "RESULT: YES"
    else
        echo "RESULT: NO"
    fi
}
 
function isSiebelStopped()
{
    set -o nounset
 
    local SIEBM_PROC_COUNTER_EXPECTED={{ SIEBM_PROC_COUNTER_EXPECTED_STOP }}
    local SIEBP_PROC_COUNTER_EXPECTED={{ SIEBP_PROC_COUNTER_EXPECTED_STOP }}
    local SIEBSVC_PROC_COUNTER_EXPECTED={{ SIEBSVC_PROC_COUNTER_EXPECTED_STOP }}
    local WATCHDOG_PROC_COUNTER_EXPECTED={{ WATCHDOG_PROC_COUNTER_EXPECTED_STOP }}
    local REGSS_PROC_COUNTER_EXPECTED={{ REGSS_PROC_COUNTER_EXPECTED_STOP }}
    local MWRPCSS_PROC_COUNTER_EXPECTED={{ MWRPCSS_PROC_COUNTER_EXPECTED_STOP }}
 
    printf "Check siebel stop..."
 
    printf "Check SIEBM_PROC_COUNTER..."
    local SIEBM_PROC_COUNTER=$(ps -ef | egrep 'sieb[m]' | wc -l)
    printf "OK\n"
    printf "Received: ${SIEBM_PROC_COUNTER} Expected: ${SIEBM_PROC_COUNTER_EXPECTED}\n"
 
    printf "Check SIEBP_PROC_COUNTER..."
    local SIEBP_PROC_COUNTER=$(ps -ef | egrep 'sieb[p]' | wc -l)
    printf "OK\n"
    printf "Received: ${SIEBP_PROC_COUNTER} Expected: ${SIEBP_PROC_COUNTER_EXPECTED}\n"
 
    printf "Check SIEBSVC_PROC_COUNTER..."
    local SIEBSVC_PROC_COUNTER=$(ps -ef | egrep 'siebsv[c]' | wc -l)
    printf "OK\n"
    printf "Received: ${SIEBSVC_PROC_COUNTER} Expected: ${SIEBSVC_PROC_COUNTER_EXPECTED}\n"
 
    printf "Check WATCHDOG_PROC_COUNTER..."
    local WATCHDOG_PROC_COUNTER=$(ps -ef | egrep 'watchdo[g] ' | wc -l)
    printf "OK\n"
    printf "Received: ${WATCHDOG_PROC_COUNTER} Expected: ${WATCHDOG_PROC_COUNTER_EXPECTED}\n"
 
    printf "Check REGSS_PROC_COUNTER..."
    local REGSS_PROC_COUNTER=$(ps -ef | egrep 'regs[s] 5' | wc -l)
    printf "OK\n"
    printf "Received: ${REGSS_PROC_COUNTER} Expected: ${REGSS_PROC_COUNTER_EXPECTED}\n"
 
    printf "Check MWRPCSS_PROC_COUNTER..."
    local MWRPCSS_PROC_COUNTER=$(ps -ef | egrep 'mwrpcs[s]' | wc -l)
    printf "OK\n"
    printf "Received: ${MWRPCSS_PROC_COUNTER} Expected: ${MWRPCSS_PROC_COUNTER}\n"
 
    if ([ "${SIEBM_PROC_COUNTER}" -eq ${SIEBM_PROC_COUNTER_EXPECTED} ] && \
    [ "${SIEBP_PROC_COUNTER}" -eq ${SIEBP_PROC_COUNTER_EXPECTED} ] && \
    [ "${SIEBSVC_PROC_COUNTER}" -eq ${SIEBSVC_PROC_COUNTER_EXPECTED} ] && \
    [ "${WATCHDOG_PROC_COUNTER}" -eq ${WATCHDOG_PROC_COUNTER_EXPECTED} ] && \
    [ "${REGSS_PROC_COUNTER}" -eq ${REGSS_PROC_COUNTER_EXPECTED} ] && \
    [ "${MWRPCSS_PROC_COUNTER}" -eq ${MWRPCSS_PROC_COUNTER_EXPECTED} ])
    then
        echo "RESULT: YES"
    else
        echo "RESULT: NO"
    fi
}
 
function KillSiebelProcs ()
{
    ps -ef | egrep 'sieb[m]' | awk '{system("kill -9 "$2)}'
    ps -ef | egrep 'sieb[p]' | awk '{system("kill -9 "$2)}'
    ps -ef | egrep 'siebsv[c]' | awk '{system("kill -9 "$2)}'
    ps -ef | egrep 'watchdo[g] ' | awk '{system("kill -9 "$2)}'
    ps -ef | egrep 'regs[s] 5' | awk '{system("kill -9 "$2)}'
    ps -ef | egrep 'mwrpcs[s]' | awk '{system("kill -9 "$2)}'
}
 
function ClearSiebelState ()
{
    find /opt/siebel/ses/siebsrvr/ -name "osdf.*" -delete
    find /opt/siebel/ses/siebsrvr/ -name "*.shm" -delete
    find /opt/siebel/ses/siebsrvr/ -name "diccache.dat" -delete
}
 
# Siebel start
if [ "$1" == "start" ]
then
    echo "Starting Siebel"
    # Check if Siebel stopped before starting
    SIEBEL_STOPPED=$(isSiebelStopped)
 
    echo -e ${SIEBEL_STOPPED}
 
    if [ $(echo ${SIEBEL_STOPPED} | grep -Eo 'RESULT: ([NOYES]{2,3})' | awk '{print $2}') == "NO" ]
    then
        echo "Can't start Siebel. Siebel NOT stopped."
        exit 1
    fi
    list_server all
    start_server all
    # Check status for 10 mins every 2 mins
    for MIN in {0..10..2}
    do
        sleep 2m
        SIEBEL_STARTED=$(isSiebelStarted)
 
        echo -e ${SIEBEL_STARTED}
 
        if [ $(echo ${SIEBEL_STARTED} | grep -Eo 'RESULT: ([NOYES]{2,3})' | awk '{print $2}') == "YES"  ]
        then
            echo "Siebel started correctly."
            break
        fi
    done
    # Check if Siebel started
    SIEBEL_STARTED=$(isSiebelStarted)
 
    echo -e ${SIEBEL_STARTED}
 
    if [ $(echo ${SIEBEL_STARTED} | grep -Eo 'RESULT: ([NOYES]{2,3})' | awk '{print $2}') == "NO" ]
    then
        echo "Siebel NOT started correctly."
        exit 1
    fi
    list_server all
# Siebel stop
elif [ "$1" == "stop" ]
then
    echo "Stoping Siebel"
    list_server all
    stop_server all || echo "Found error while stopping"
    mwadm stop || echo "Found error while stopping"
    # Check if Siebel stopped correctly
    SIEBEL_STOPPED=$(isSiebelStopped)
 
    echo -e ${SIEBEL_STOPPED}
 
    if [ $(echo ${SIEBEL_STOPPED} | grep -Eo 'RESULT: ([NOYES]{2,3})' | awk '{print $2}') == "YES" ]
    then
        echo "Siebel stopped correctly."
    elif [ $(echo ${SIEBEL_STOPPED} | grep -Eo 'RESULT: ([NOYES]{2,3})' | awk '{print $2}') == "NO" ]
    then
        echo "Siebel NOT stopped correctly."
        echo "Killing Siebel procs"
        KillSiebelProcs
        echo "Clearing Siebel procs"
        ClearSiebelState
    fi
    list_server all
# Siebel status
elif [ "$1" == "status" ]
then
    SIEBEL_STARTED=$(isSiebelStarted)
    SIEBEL_STOPPED=$(isSiebelStopped)
 
    echo -e ${SIEBEL_STARTED}
    echo -e ${SIEBEL_STOPPED}
 
    if [ $(echo ${SIEBEL_STARTED} | grep -Eo 'RESULT: ([NOYES]{2,3})' | awk '{print $2}') == "YES" ]
    then
        echo "Siebel Status: STARTED"
    elif [ $(echo ${SIEBEL_STOPPED} | grep -Eo 'RESULT: ([NOYES]{2,3})' | awk '{print $2}') == "YES" ]
    then
        echo "Siebel Status: STOPPED"
    else
        echo "Siebel Status: UNKNOWN"
        exit 1
    fi
# Siebel clean afterf failed start
elif [ "$1" == "clear" ]
then
    stop_server all
    KillSiebelProcs
    ClearSiebelState
# How to use
else
    echo "Use: start, stop, status, clear"
fi