FROM alpine:3.10 AS builder

ARG TENGINE="https://tengine.taobao.org/download/tengine-2.3.2.tar.gz"
ARG LUAJIT="https://github.com/openresty/luajit2/archive/v2.1-20200102.tar.gz"
ARG PROMETHEUS="https://github.com/knyar/nginx-lua-prometheus/archive/master.zip"
ARG SKYWALKING="https://github.com/apache/skywalking-nginx-lua/archive/master.zip"

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
      --add-module=modules/ngx_http_lua_module \
      --add-module=modules/ngx_http_upstream_vnswrr_module \
      --add-module=modules/ngx_http_upstream_dyups_module \
      --with-cc-opt=-Os  \
      --with-ld-opt=-Wl,-rpath,/usr/local/include/luajit-2.1,--as-needed \
	  " && \
    addgroup -S nginx && \
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
    apk add --no-cache curl-dev gcc libc-dev make openssl-dev pcre-dev zlib-dev linux-headers curl gnupg1 libxslt-dev gd-dev geoip-dev cmake g++ perl-dev lua5.1-dev && \
    #Download Openresty luajit2 lib
    wget --no-check-certificate -O /opt/luajit2.tar.gz ${LUAJIT} && \
    cd /opt && \
    tar -zxvf luajit2.tar.gz && \
    rm -rf luajit2.tar.gz && \
    mv luajit* luajit2 && \
    cd /opt/luajit2 && \
    make && \
    make install && \
    export LUAJIT_LIB=/usr/local/lib/ && \
    export LUAJIT_INC=/usr/local/include/luajit-2.1 && \
    #Download Tengine
    wget -O /tmp/tengine.tar.gz ${TENGINE} && \
    cd /tmp/ && \
    tar -zxvf tengine.tar.gz && \
    rm -rf tengine.tar.gz && \
    mv tengine* tengine && \
    cd tengine && \
    ./configure $CONFIG && \
    make && \
    make install && \
    wget --no-check-certificate -O /opt/prometheus.zip ${PROMETHEUS} && \
    wget --no-check-certificate -O /opt/skywalking.zip ${SKYWALKING} && \
    cd /opt && \
    unzip prometheus.zip && \
    unzip skywalking.zip && \
    mkdir -p /opt/lua-lib && \
    mv /opt/nginx-lua-prometheus*/prometheus.lua /opt/lua-lib && \
    mv /opt/skywalking-nginx-lua*/lib/skywalking/* /opt/lua-lib

FROM alpine:3.10
RUN echo "https://mirrors.aliyun.com/alpine/v3.10/main" > /etc/apk/repositories && \
    echo "https://mirrors.aliyun.com/alpine/v3.10/community" >> /etc/apk/repositories && \
    addgroup -S nginx && \
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
	  apk add --no-cache gcc openssl pcre zlib gnupg1 libxslt gd geoip perl lua5.1 lua-cjson tzdata && \
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
COPY --from=builder /opt/lua-lib /opt/lua-lib
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d /etc/nginx/conf.d/
#Copy Default Nginx entry point file
COPY docker-entrypoint.sh /opt

ENTRYPOINT ["sh", "/opt/docker-entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGTERM
