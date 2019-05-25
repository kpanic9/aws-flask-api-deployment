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

