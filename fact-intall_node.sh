#!/bin/bash

#public settings
currentPath=~
path=$currentPath/factorn
serviceScript=factnode.sh
servicePath=/etc/systemd/system
nameService=factnode.service

#stop service if it is running
systemctl is-active --quiet factnode && systemctl stop --no-block factnode

cd $currentPath


FILE=factorn
if [ ! -d "$FILE" ]; then
  mkdir factorn
fi

cd $currentPath/factorn

wget https://github.com/FACT0RN/FACT0RN/releases/download/v4.23.69/factorn-f597273f3bdc-x86_64-linux-gnu.tar.gz
tar -xvf factorn-f597273f3bdc-x86_64-linux-gnu.tar.gz
mv factorn-f597273f3bdc factorn-run
mkdir ~/.factorn && touch ~/.factorn/factorn.conf
cat /dev/null > ~/.factorn/factorn.conf
echo "rpcuser=USERNAME" >> ~/.factorn/factorn.conf
echo "rpcpassword=USERPASSSS" >> ~/.factorn/factorn.conf
echo "rpcbind=0.0.0.0" >> ~/.factorn/factorn.conf
echo "rpcallowip=0.0.0.0/0" >> ~/.factorn/factorn.conf

echo -e "#!/bin/bash\n$path/factorn-run/bin/factornd -datadir=$currentPath/.factorn >$path/fact.log" >$path/$serviceScript
chmod u+x $path/$serviceScript

echo -e "[Unit]\nAfter=network-online.target\n[Service]\n#StandardOutput=append:$path/factnode.log\n#StandardError=append:$path/factnode.error.log\nExecStart=/bin/bash $path/$serviceScript\nRestart=on-failure\nRestartSec=1s\n[Install]\nWantedBy=default.target" > $servicePath/$nameService 

chmod 664 $servicePath/$nameService
systemctl daemon-reload
systemctl enable --no-block $nameService
systemctl start --no-block $nameService

