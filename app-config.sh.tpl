#!/bin/bash

# updating server and installing required packages
amazon-linux-extras install nginx1.12 -y
yum install python2-pip -y
yum install python-virtualenv -y
yum install git -y



cd /home/ec2-user/
git clone https://${git_user}:${git_password}@${git_url}


# configuring python virtual environment
python2.7 -m virtualenv venv 
source venv/bin/activate
pip install wheel 
pip install gunicorn flask 
pip install jsonschema requests jschema log ConfigParser functools32

cat > ./${api_dir}/wsgi.py << EOF
from ### main api script ### import app
if __name__ == "__main__":
    app.run()

EOF

cat >> ./${api_dir}/app.py << EOF


if __name__ == "__main__":
    app.run(host='0.0.0.0')
EOF


cat >> ./${api_dir}/config << EOF
[API]
SN_URL = ${snow_url}
EOF

deactivate

chmod -R 750 /home/ec2-user/
chown -R ec2-user:nginx /home/ec2-user/

cat > /etc/systemd/system/api.service << EOF
[Unit]
Description=SNOW API
After=network.target	

[Service]
User=ec2-user
Group=nginx
WorkingDirectory=/home/ec2-user/${api_dir}
Environment="PATH=/home/ec2-user/venv/bin"
ExecStart=/home/ec2-user/venv/bin/gunicorn --workers 3 --bind unix:app.sock -m 007 wsgi:app
		
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable api 
systemctl start api

cat > /etc/nginx/nginx.conf << EOF
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
			proxy_pass http://unix:/home/ec2-user/${api_dir}/api.sock;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

}
EOF

systemctl enable nginx			
systemctl start nginx		

