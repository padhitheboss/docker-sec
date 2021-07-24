#!/bin/bash
banner(){
echo ""
echo "|  _ \  ___   ___| | _____ _ __   / ___|  ___  ___ _   _ _ __(_) |_ _   _   "
echo "| | | |/ _ \ / __| |/ / _ \ '__|  \___ \ / _ \/ __| | | | '__| | __| | | |  "
echo "| |_| | (_) | (__|   <  __/ |      ___) |  __/ (__| |_| | |  | | |_| |_| |  "
echo "|____/ \___/ \___|_|\_\___|_|     |____/ \___|\___|\__,_|_|  |_|\__|\__, |  "
echo "                                                                    |___/   "
echo ""
echo ""
}
banner
if [[ $EUID -ne 0 ]]; then
    echo "You must be root"
    exit 1
fi
pwd=$(pwd)
function mainmenu(){
    clear
    banner
    echo " "
    echo " "
    echo "Choose a option from below:"
         echo " "
         echo "1. Install Docker"
         echo " "
         echo "2. Docker CIS Benchmark"
         echo " "
         echo "3. Host OS Hardening"
         echo " "
         echo "4. Docker Daemon Security Hardening"
         echo " "
         echo "5. Docker TLS Remote Access Configuration"
         echo " "
         echo "6. Image Scanning"
         echo " "
         echo "7. Kernel Capabilities Templates"
         echo " "
         echo "8. Exit"
    echo " "
    echo -n "Enter Option No.:"
    read option
    case $option in
    1)  curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
        clear
        echo "Run "dockerd-rootless-setuptool.sh install" as a user to run docker as non-root user "
        sleep 3
        read -n 1 -p "<Enter> for main menu"
        mainmenu
        ;;

	2)
	git clone https://github.com/docker/docker-bench-security.git
        cd docker-bench-security && sudo ./docker-bench-security.sh
        read -n 1 -p "<Enter> for main menu"
        mainmenu
        ;;

    3)
        cd $pwd
        sudo ./os-sec.sh
			read -n 1 -p "<Enter> for main menu"
			mainmenu
	;;

	4)
                cd $pwd
		sudo ./docker-daemon-sec.sh
			read -n 1 -p "<Enter> for main menu"
			mainmenu
	;;

	5)
        cd $pwd
	sudo ./gen_tls_cert.sh
        mkdir -p /etc/docker/tls
        cp $HOME/.docker/server-cert.pem /etc/docker/tls/servercert.pem
        cp $HOME/.docker/server-key.pem /etc/docker/tls/serverkey.pem
        cp $HOME/.docker/ca.pem /etc/docker/tls/ca.pem
        mkdir -p /etc/systemd/system/docker.service.d/
        cat files/override.txt >> /etc/systemd/system/docker.service.d/override.conf
        sudo systemctl daemon-reload
        sudo systemctl restart docker
			read -n 1 -p "<Enter> for main menu"
			mainmenu
	;;

	6)
        cd $pwd
        sudo ./image-scan.sh
            read -n 1 -p "<Enter> for main menu"
		    mainmenu
        ;;
    7)   sudo apt install python3
        python3 cap_template.py
           read -n 1 -p "<Enter> for main menu"
                    mainmenu
        ;;
    8)
		function goout () {
			TIME=2
			echo " "
			echo Leaving the system ......
			sleep $TIME
			exit 0
		}
		goout
	;;

esac
}
mainmenu
