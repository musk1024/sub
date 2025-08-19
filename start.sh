#/bin/sh
if [ ! -f /usr/share/nginx/html/conf/config.js ]; then
  cp /app/conf/config.js /usr/share/nginx/html/conf
fi

if [ ! -f /base/pref.toml ]; then
  cp /base/pref.example.toml /base/pref.toml
fi

if [ $API_URL ]; then
  echo "当前 API 地址为: $API_URL"
  sed -i "s#http://127.0.0.1:25500#$API_URL#g" /usr/share/nginx/html/conf/config.js
  sed -i "s#managed_config_prefix = \"http://127.0.0.1:25500\"#managed_config_prefix = \"$API_URL\"#g" /base/pref.toml
else
  echo "当前为默认本地 API 地址: http://127.0.0.1:25500"
  echo "如需修改请在容器启动时使用 -e API_URL='https://sub.ops.ci' 传递环境变量"
fi

if [ $EXTERNAL_CONFIG_URL ]; then
  echo "当前外部配置文件地址为: $EXTERNAL_CONFIG_URL"
  sed -i "s|^# default_external_config = \"config/example_external_config.toml\"|default_external_config = \"$EXTERNAL_CONFIG_URL\"|g" /base/pref.toml
else
  echo "当前为默认本地 External Config 地址: config/example_external_config.toml"
  echo "如需修改请在容器启动时使用 -e EXTERNAL_CONFIG_URL='https://sub.ops.ci/config/example_external_config.toml' 传递环境变量"
fi

if [ $SHORT_URL ]; then
  echo "当前短链接地址为: $SHORT_URL"
  sed -i "s#https://s.ops.ci#$SHORT_URL#g" /usr/share/nginx/html/conf/config.js
else
  echo "当前为默认本地 ShortUrl 地址: https://s.ops.ci"
  echo "如需修改请在容器启动时使用 -e SHORT_URL='https://s.ops.ci' 传递环境变量"
fi

if [ $SITE_NAME ]; then
  sed -i "s#Subconverter Web#$SITE_NAME#g" /usr/share/nginx/html/conf/config.js
fi

nohup /base/subconverter & echo "启动成功"

init_nginx (){
  sed -i '$d' /etc/nginx/conf.d/default.conf
  sed -i '$d' /etc/nginx/conf.d/default.conf
  sed -i '$d' /etc/nginx/conf.d/default.conf
  cat >> /etc/nginx/conf.d/default.conf <<EOF
    location ~* /(sub|render|getruleset|surge2clash|getprofile|flushcache) {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:25500;
    }
  }
EOF
}

if [[ ! $(cat /etc/nginx/conf.d/default.conf | grep 25500) ]]; then
	init_nginx
fi

nginx -g "daemon off;"