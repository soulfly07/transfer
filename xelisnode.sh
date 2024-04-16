#!/usr/bin/bash

#public settings
currentPath=~
FILE=xelis
path=$currentPath/$FILE
serviceScript=xelisnode.sh
servicePath=/etc/systemd/system
nameService=$FILE.service

cd $currentPath

if [ ! -d "$FILE" ]; then
    mkdir $FILE
fi
cd $FILE

wget -O xelis-blockchain.tar.gz https://github.com/xelis-project/xelis-blockchain/releases/download/v1.8.0/x86_64-unknown-linux-gnu.tar.gz
tar -xvzf xelis-blockchain.tar.gz
mv x86_64-unknown-linux-gnu/* .
rm -r x86_64-unknown-linux-gnu
rm xelis-blockchain.tar.gz

echo -e "#!/usr/bin/bash\n\n$path/xelis_daemon --network testnet --allow-boost-sync | tee $path/$FILE.out.log" >$path/$serviceScript
chmod u+x $serviceScript


##screen session
#screen -XS $FILE quit
#screen -dmS $FILE ./$serviceScript

echo -e "[Unit]\nAfter=network-online.target\n[Service]\nExecStart=/bin/bash $path/$serviceScript\nRestart=on-failure\nRestartSec=1s\n[Install]\nWantedBy=default.target" > $servicePath/$nameService


chmod 664 $servicePath/$nameService
systemctl daemon-reload
systemctl enable --no-block $nameService
systemctl start --no-block $nameService