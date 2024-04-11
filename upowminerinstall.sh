#!/usr/bin/bash

#public settings
currentPath=~
FILE=upowminer
path=$currentPath/$FILE
serviceScript=upowminer.sh
servicePath=/etc/systemd/system
nameService=$FILE.service

if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]
then
echo "node:$1\naddress:$2\nworkers:$3"
cd $currentPath

if [ ! -d "$FILE" ]; then
    mkdir $FILE
fi
cd $FILE

wget -O stand-alone-miner-linux64 https://github.com/upowai/uPowBlockMiner/releases/download/v1/stand-alone-miner-linux64
chmod +x stand-alone-miner-linux64 

echo -e "#!/usr/bin/bash\n\n$path/stand-alone-miner-linux64 -node $1 -address $2 -workers $3 | tee $path/$FILE.out.log" >$path/$serviceScript
chmod u+x $serviceScript


#else
#echo -e "\n\nNo parameters found.\nAfter the script name, specify the values separated by a space. As an example:\n\nupowminer.sh https://api.upow.ai/ Dj2MdQRcpemTbaGhxpsyNJ4CGDiuWNHJfdhT6UtJpSNYJ 16\n\n"
#fi

question() {
  while echo -ne "$1 [Y/N] " && read answer || true && ! grep -e '^[YyNn]$' <<< $answer > /dev/null; do echo -n "Enter N or Y! "; done
  return $(tr 'YyNn' '0011' <<< $answer)
}

if question "\nCreate Autostart miner in systemd?:"; then
  echo "\nGood choice\n\n"
echo -e "[Unit]\nAfter=network-online.target\n[Service]\nExecStart=/bin/bash $path/$serviceScript\nRestart=on-failure\nRestartSec=1s\n[Install]\nWantedBy=default.target" > $servicePath/$nameService


chmod 664 $servicePath/$nameService
systemctl daemon-reload
systemctl enable --no-block $nameService
systemctl start --no-block $nameService

echo -e "systemctl enable --no-block $nameService - поставить в автозагрузку, сделано "
echo -e "systemctl start --no-block $nameService - запустить,  сделано "
echo -e "посмотреть отчет майнера: \"tail -f -n 20 $path/$FILE.out.log"\"
echo -e "\nsystemctl stop $nameService (остановить)"
echo -e " \nsystemctl restart $nameService (перезапустить), \nsystemctl disable $nameService (убрать из автозагрузки)\n\n"

else
  echo -e "\n\nOhhh.\n\n"
fi


else
echo -e "\n\nNo parameters found.\nAfter the script name, specify the values separated by a space. As an example:\n\nupowminer.sh https://api.upow.ai/ Dj2MdQRcpemTbaGhxpsyNJ4CGDiuWNHJfdhT6UtJpSNYJ 16\n\n"
fi
