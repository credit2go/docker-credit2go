#!/bin/sh

set -x
set -e

#write backend upstream server list before nginx start, default to localhost:8080.
generateBackendsvcLB(){
    ngx_upstream_file="/etc/nginx/conf.d/backendSvc.conf"
    svclist=""
    #Write Upstream Server List
    #pool对应ip地址列表,多个ip以逗号改开
    pool_ip=`awk 'BEGIN{list="'${BACKENDSVC_URL:-localhost:8080}'";split(list,ip_list,",");for(ip in ip_list){print ip_list[ip];}}'`
    for ip in ${pool_ip}; do
        svclist="server "${svclist}"${ip};\n"
    done
    svclist=$(echo -e $svclist)
cat <<EOT > ${ngx_upstream_file}
#This is default backendsvc upstream conf;
upstream backendsvcLB {
${svclist}
}
EOT
    echo -e "\033[31m ====Generate upstream.conf Done==== \033[0m"
}

#write real ip address list before nginx start and with default 0.0.0.0/8 to get ip;
generateRealIP(){
    ngx_real_ip_file="/etc/nginx/conf.d/realip.conf"
    real_ip=""
    pool_ip=`awk 'BEGIN{list="'${REAL_IP:-0.0.0.0/8}'";split(list,ip_list,",");for(ip in ip_list){print ip_list[ip];}}'`
    for ip in ${pool_ip}; do
        real_ip=${real_ip}"set_real_ip_from     ${ip};\n"
    done
    real_ip=$(echo -e ${real_ip})
    cat <<EOT > ${ngx_real_ip_file}
${real_ip}
real_ip_header    X-Forwarded-For;
real_ip_recursive on;
EOT
    echo -e "\033[31m ====Generate real_ip.conf Done==== \033[0m"
}

#write opentrace conf file before nginx start
generateOpenTrace(){
    opentrace="/etc/nginx/conf.d/skywalking.conf"
    cat <<EOT > ${opentrace}
#Skywalking Lua APM settings    

# Buffer represents the register inform and the queue of the finished segment
lua_shared_dict tracing_buffer 100m;

# Init is the timer setter and keeper
# Setup an infinite loop timer to do register and trace report.
init_worker_by_lua_block {
    local metadata_buffer = ngx.shared.tracing_buffer

    -- Set service name
    metadata_buffer:set('serviceName', "${ZIPKIN_SERVICE_NAME:-tengine-2.3.2}")
    -- Instance means the number of Nginx deployment, does not mean the worker instances
    metadata_buffer:set('serviceInstanceName', '${HOSTNAME}')

    require("client"):startBackendTimer("http://${ZIPKIN_HOST:-oap.apm}:${ZIPKIN_PORT:-12800}")

    -- fix for enable prometheus metrics
    prometheus:init_worker()
}
EOT
    echo -e "\033[31m ====Generate enable opentrace config Done==== \033[0m"
}

disableOpenTrace(){
    opentrace="/etc/nginx/conf.d/skywalking.conf"
    cat <<EOT > ${opentrace}
init_worker_by_lua_block {
    -- fix for enable prometheus metrics
    prometheus:init_worker()
}
EOT
    echo -e "\033[31m ====Generate disable opentrace config Done==== \033[0m"
}

update_ZIPKIN_NAMESPACE(){
    ZIPKIN_NAMESPACE=${ZIPKIN_NAMESPACE:-}
    if [[ "$ZIPKIN_NAMESPACE" != "" ]]; then
      #update zipkin namespace with current value
      sed -i "s/ZIPKIN_NAMESPACE/\"${ZIPKIN_NAMESPACE}\"/g" /etc/nginx/conf.d/default.conf
    else
      #remove ZIPKIN NAMESPACE as per it is blank
      sed -i 's/,ZIPKIN_NAMESPACE//g' /etc/nginx/conf.d/default.conf
    fi
}
echo "[Entrypoint] Tengine Docker Image with Zipkin Open Trace Conf Generator"

#Default Enable ZIPKIN Open Trace
OPENTRACE=${OPENTRACE:-on}
#Default disable load conf from volume to generate conf
LOAD_NGINX_CONF_FROM_VOLUME=${LOAD_NGINX_CONF_FROM_VOLUME:-false}

if [[ "$LOAD_NGINX_CONF_FROM_VOLUME" != "true" ]]; then
    #Generate Backend Upstream
    generateBackendsvcLB
    #Set Real IP Address
    generateRealIP
    #Geneate Zipkin Related when opentrace enabled
    if [[ "$OPENTRACE" == "on" ]]; then
        echo "enable skywalking"
        generateOpenTrace
        update_ZIPKIN_NAMESPACE
    else
        echo "disable skywalking"
        disableOpenTrace
    fi
    echo "Generated Nginx default Conf"
fi

#nginx -g 'daemon off;'
nginx
tail -f /var/log/nginx/*.log