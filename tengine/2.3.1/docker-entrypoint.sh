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

#write zipkin server address before nginx start;
generateZipKin(){
    zipkin_config="/etc/nginx/conf.d/zipkin.json"
    cat <<EOT > ${zipkin_config}
{
  "service_name": "${ZIPKIN_SERVICE_NAME:-tengine-2.3.1}",
  "collector_host": "${ZIPKIN_HOST:-zipkin}",
  "collector_port": ${ZIPKIN_PORT:-9411}
}
EOT
    echo -e "\033[31m ====Generate zipkin config Done==== \033[0m"
}

#write opentrace conf file before nginx start
generateOpenTrace(){
    opentrace="/etc/nginx/conf.d/opentrace.conf"
    cat <<EOT > ${opentrace}
#This is default http settings for nginx open trace with zipkin

# Load a vendor tracer
opentracing_load_tracer /usr/local/lib/libzipkin_opentracing.so /etc/nginx/conf.d/zipkin.json;

# Enable tracing for all requests.
opentracing ${OPENTRACE:-on};

# Optionally, set additional tags.
opentracing_tag bytes_sent \$bytes_sent;
opentracing_tag http_user_agent \$http_user_agent;
opentracing_tag request_time \$request_time;
opentracing_tag upstream_addr \$upstream_addr;
opentracing_tag upstream_bytes_received \$upstream_bytes_received;
opentracing_tag upstream_cache_status \$upstream_cache_status;
opentracing_tag upstream_connect_time \$upstream_connect_time;
opentracing_tag upstream_header_time \$upstream_header_time;
opentracing_tag upstream_response_time \$upstream_response_time;

# Propagate the active span context upstream, so that the trace can be
# continued by the backend.
# See http://opentracing.io/documentation/pages/api/cross-process-tracing.html
opentracing_propagate_context;

# Propagates the active span context for FastCGI requests.
opentracing_fastcgi_propagate_context;

# Propagates the active span context for gRPC requests.
opentracing_grpc_propagate_context;

# Enables the creation of OpenTracing spans for location blocks within a request.
opentracing_trace_locations ${OPENTRACE:-on};
EOT
    echo -e "\033[31m ====Generate opentrace config Done==== \033[0m"
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
        echo "enable opentrace"
        generateOpenTrace
        generateZipKin
    else
        echo "disable opentrace"
        OPENTRACE="off"
        generateOpenTrace
    fi
    echo "Generated Nginx default Conf"
fi
nginx -g 'daemon off;'