FROM alpine:3.10 AS builder

ARG TENGINE="http://tengine.taobao.org/download/tengine-2.3.1.tar.gz" 
ARG OPENTRACE="https://github.com/opentracing/opentracing-cpp/archive/v1.5.1.tar.gz"
ARG ZIPKIN="https://github.com/rnburn/zipkin-cpp-opentracing/archive/v0.5.2.tar.gz"
ARG NGINX_TRACE="https://github.com/opentracing-contrib/nginx-opentracing/archive/v0.8.0.tar.gz"
ARG NGINX_VTS="https://github.com/vozlt/nginx-module-vts/archive/v0.1.18.tar.gz"

RUN echo "https://mirrors.aliyun.com/alpine/v3.10/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.10/community" >> /etc/apk/repositories && \
  	CONFIG="\
  		--prefix=/etc/nginx \
      --sbin-path=/usr/sbin/nginx \
      --modules-path=/usr/lib/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/var/run/nginx.pid \
      --lock-path=/var/run/nginx.lock \
      --http-client-body-temp-path=/var/cache/nginx/client_temp \
      --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
      --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
      --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
      --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
      --user=nginx \
      --group=nginx \
      --with-http_ssl_module \
      --with-http_realip_module \
      --with-http_addition_module \
      --with-http_sub_module \
      --with-http_dav_module \
      --with-http_flv_module \
      --with-http_mp4_module \
      --with-http_gunzip_module \
      --with-http_gzip_static_module \
      --with-http_random_index_module \
      --with-http_secure_link_module \
      --with-http_stub_status_module \
      --with-http_auth_request_module \
      --with-http_xslt_module=dynamic \
      --with-http_image_filter_module=dynamic \
      --with-http_geoip_module=dynamic \
      --with-threads \
      --with-stream \
      --with-stream_ssl_module \
      --with-stream_ssl_preread_module \
      --with-stream_realip_module \
      --with-stream_geoip_module=dynamic \
      --with-http_slice_module \
      --with-mail \
      --with-mail_ssl_module \
      --with-compat \
      --with-file-aio \
      --with-http_v2_module \
  	  --with-http_perl_module \
  	  --add-module=modules/ngx_http_concat_module \
      --add-module=modules/ngx_http_footer_filter_module \
      --add-module=modules/ngx_http_proxy_connect_module \
      --add-module=modules/ngx_http_reqstat_module \
      --add-module=modules/ngx_http_sysguard_module \
      --add-module=modules/ngx_http_trim_filter_module \
      --add-module=modules/ngx_http_upstream_check_module \
      --add-module=modules/ngx_http_upstream_consistent_hash_module \
      --add-module=modules/ngx_http_upstream_dynamic_module \
      --add-module=modules/ngx_http_upstream_session_sticky_module \
      --add-module=modules/ngx_http_user_agent_module \
      --add-module=modules/ngx_opentrace \
      --add-module=modules/nginx-module-vts \
      --with-cc-opt=-Os  \
      --with-ld-opt=-Wl,-rpath,--as-needed \
	  " && \
    addgroup -S nginx && \
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
    apk add --no-cache curl-dev gcc libc-dev make openssl-dev pcre-dev zlib-dev linux-headers curl gnupg1 libxslt-dev gd-dev geoip-dev cmake g++ perl-dev && \
    #Download Open Trace Lib
    wget -O /opt/opentracing.tar.gz ${OPENTRACE} && \
    cd /opt && \
    tar -zxvf opentracing.tar.gz && \
    rm -rf opentracing.tar.gz && \
    mv opentracing* opentracing && \    
    cd opentracing && \
    mkdir .build && \
    cd .build && \
    cmake -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF .. && \
    make && \
    make install && \
    #Download Open Trace Zipkin Lib
    wget -O /opt/zipkin.tar.gz ${ZIPKIN} && \
    cd /opt && \
    tar -zxvf zipkin.tar.gz && \
    rm -rf zipkin.tar.gz && \
    mv zipkin* zipkin && \    
    cd zipkin && \
    mkdir .build && \
    cd .build && \
    cmake  -DBUILD_SHARED_LIBS=1 -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF .. && \
    make && \
    make install && \
    #Download Nginx Open Trace Module
    wget -O /opt/nginx-opentracing.tar.gz ${NGINX_TRACE} && \
    cd /opt && \
    tar -zxvf nginx-opentracing.tar.gz && \
    rm -rf nginx-opentracing.tar.gz && \
    mv nginx-opentracing* nginx-opentracing && \    
    #Download Nginx VTS Module
    wget -O /opt/nginx-module-vts.tar.gz ${NGINX_VTS} && \
    cd /opt && \
    tar -zxvf nginx-module-vts.tar.gz && \
    rm -rf nginx-module-vts.tar.gz && \
    mv nginx-module-vts* nginx-module-vts && \      
    #Download Tengine
    wget -O /opt/tengine.tar.gz ${TENGINE} && \
    cd /opt/ && \
    tar -zxvf tengine.tar.gz && \
    rm -rf tengine.tar.gz && \
    mv tengine* tengine && \
    ln -s /opt/nginx-opentracing/opentracing /opt/tengine/modules/ngx_opentrace && \
    ln -s /opt/nginx-module-vts /opt/tengine/modules/nginx-module-vts && \
    cd tengine && \
    ./configure $CONFIG && \
    make && \
    make install

FROM alpine:3.10
RUN echo "https://mirrors.aliyun.com/alpine/v3.10/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.10/community" >> /etc/apk/repositories && \
    addgroup -S nginx && \
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
	  apk add --no-cache gcc openssl pcre zlib gnupg1 libxslt gd geoip perl tzdata && \
	  echo "upgrade to fix Vulnerabilities" && \
    apk upgrade --no-cache && \
	  # forward request and error logs to docker log collector
	  mkdir -p /var/log/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /usr/lib/nginx /usr/lib/nginx
COPY --from=builder /usr/local/lib/ /usr/local/lib
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d /etc/nginx/conf.d/
#Copy Default Nginx entry point file
COPY docker-entrypoint.sh /opt

ENTRYPOINT ["sh", "/opt/docker-entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGTERM