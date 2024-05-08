#!/usr/bin/bash

currentPath=~
datapath=.spectred
FILE=spectre
path=$currentPath/$FILE
serviceScript=spectrenode.sh
servicePath=/etc/systemd/system
nameService=$FILE.service

#stop service if it is running
systemctl is-active --quiet $FILE && systemctl stop --no-block $FILE

cd $currentPath

if [ ! -d "$FILE" ]; then
    mkdir $FILE
fi
cd $FILE

echo "create folder $currentPath/$FILE"
sleep 2

wget -O spectred-v0.3.14-linux-x86_64.zip https://spectre-network.org/downloads/spectred-v0.3.14-linux-x86_64.zip
apt install zip -y 
unzip -o spectred-v0.3.14-linux-x86_64.zip
mv bin/* .
rm -r bin
rm spectred-v0.3.14-linux-x86_64.zip

mkdir -p $currentPath/$datapath/spectre-mainnet/
cd $currentPath/$datapath/spectre-mainnet/
wget -O datadir2.zip https://spectre-network.org/downloads/datadir2.zip
unzip -o datadir2.zip
rm datadir2.zip

cd $path

echo -e "#!/usr/bin/bash\n\n$path/spectred --utxoindex | tee $path/$FILE.out.log" >$path/$serviceScript
chmod u+x $serviceScript

echo -e "[Unit]\nAfter=network-online.target\n[Service]\nExecStart=/bin/bash $path/$serviceScript\nRestart=on-failure\nRestartSec=1s\n[Install]\nWantedBy=default.target" > $servicePath/$nameService


chmod 664 $servicePath/$nameService
systemctl daemon-reload
systemctl enable --no-block $nameService
systemctl start --no-block $nameService


echo "INFO"
echo "_________________________________________________________________"
echo "все файлы ноды, кошелька , майнера хранятся в $path"
echo "нода уже запущена в автостарте, что бы посмотеть лог ноды дать команду:"
echo "tail -f -n 30 $path/$FILE.out.log"



