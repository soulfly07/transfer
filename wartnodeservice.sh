#!/usr/bin/bash

#public settings
currentPath=/home/user
path=$currentPath/wartnode
serviceScript=wartnode.sh
servicePath=/etc/systemd/system
nameService=wartnode.service

#stop service if it is running
systemctl is-active --quiet wartnode && systemctl stop --no-block wartnode


cd /home/user
mkdir .warthog

FILE=wartnode
if [ ! -d "$FILE" ]; then
    mkdir wartnode
fi
cd wartnode

wget -O wart-node-linux https://github.com/warthog-network/Warthog/releases/download/master-0.1.8-ff6b90d/wart-node-linux
echo -e "#!/usr/bin/bash\n/home/user/wartnode/wart-node-linux --rpc=0.0.0.0:3000 --chain-db=/home/user/.warthog/chain.db3 --peers-db=/home/user/.warthog/peers.db3 >/home/user/wartnode/wartnode.log" >/home/user/wartnode/wartnode.sh
chmod +x *


echo -e "[Unit]\nAfter=network-online.target\n[Service]\n#StandardOutput=append:wartnode/wartnode.log\n#StandardError=append:wartnode/wartnode.error.log\nExecStart=/bin/bash $path/$serviceScript\nRestart=on-failure\nRestartSec=1s\n[Install]\nWantedBy=default.target" > $servicePath/$nameService


chmod 664 $servicePath/$nameService
systemctl daemon-reload
systemctl enable --no-block $nameService
systemctl start --no-block $nameService

chmod u+x $path/$serviceScript
