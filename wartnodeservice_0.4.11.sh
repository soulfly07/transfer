#!/usr/bin/bash

#public settings
currentPath=/home/user
path=$currentPath/wartnode
serviceScript=wartnode.sh
servicePath=/etc/systemd/system
nameService=wartnode.service

#stop service if it is running
systemctl is-active --quiet wartnode && systemctl stop --no-block wartnode


cd $currentPath
mkdir .warthog

FILE=wartnode
if [ ! -d "$FILE" ]; then
    mkdir wartnode
fi
cd wartnode

wget -O wart-node-linux https://github.com/warthog-network/Warthog/releases/download/0.4.11/wart-node-linux
echo -e "#!/usr/bin/bash\n$path/wart-node-linux --rpc=0.0.0.0:3000 --stratum=0.0.0.0:3456 --chain-db=$currentPath/.warthog/chain.db3 --peers-db=$currentPath/.warthog/peers.db3 >$path/wartnode.log" >$path/wartnode.sh
chmod +x *


echo -e "[Unit]\nAfter=network-online.target\n[Service]\n#StandardOutput=append:$path/wartnode.log\n#StandardError=append:$path/wartnode.error.log\nExecStart=/bin/bash $path/$serviceScript\nRestart=on-failure\nRestartSec=1s\n[Install]\nWantedBy=default.target" > $servicePath/$nameService


chmod 664 $servicePath/$nameService
systemctl daemon-reload
systemctl enable --no-block $nameService
systemctl start --no-block $nameService

chmod u+x $path/$serviceScript
