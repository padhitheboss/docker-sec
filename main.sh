echo ""
echo "|  _ \  ___   ___| | _____ _ __   / ___|  ___  ___ _   _ _ __(_) |_ _   _   "
echo "| | | |/ _ \ / __| |/ / _ \ '__|  \___ \ / _ \/ __| | | | '__| | __| | | |  "
echo "| |_| | (_) | (__|   <  __/ |      ___) |  __/ (__| |_| | |  | | |_| |_| |  "
echo "|____/ \___/ \___|_|\_\___|_|     |____/ \___|\___|\__,_|_|  |_|\__|\__, |  "
echo "                                                                    |___/   "
echo ""
echo ""
if [[ $EUID -ne 0 ]]; then
    echo "You must be root"
    exit 1
fi
function mainmenu(){
    clear
    echo " "
    echo " "
    echo "Choose a option from below:" 
         echo 1. Docker CIS Benchmark 
         echo 2. Host OS Hardening
         echo 3. Docker Daemon Security Hardening
         echo 4. Docker TLS Remote Access Configuration
         echo 5. Image Scanning
         echo 6. Run All 
         echo 7. Exit
    echo " "
    echo -n "Enter Option No.:"
    read option
    case $option in
	1)
		git clone https://github.com/docker/docker-bench-security.git
        cd docker-bench-security && sudo ./docker-bench-security.sh
        read -n 1 -p "<Enter> for main menu"
        mainmenu
        ;;  

    2)
        sudo ./os-sec.sh
			read -n 1 -p "<Enter> for main menu"
			mainmenu
	;;

	3)
		sudo ./docker-daemon-sec.sh
			read -n 1 -p "<Enter> for main menu"
			mainmenu
	;;

	4)
		./gen_tls_cert.sh
        mkdir -p /etc/docker/tls
        cp $HOME/.docker/server-cert.pem /etc/docker/tls/servercert.pem
        cp $HOME/.docker/server-key.pem /etc/docker/tls/serverkey.pem
        cp $HOME/.docker/ca.pem /etc/docker/tls/ca.pem
        mkdir -p /etc/systemd/system/docker.service.d/override.conf
        cat files/override.txt >> /etc/systemd/system/docker.service.d/override.conf
        sudo systemctl daemon-reload
        sudo systemctl docker restart
			read -n 1 -p "<Enter> for main menu"
			mainmenu
	;;

	5)
        ./image-scan.sh
            read -n 1 -p "<Enter> for main menu"
		    mainmenu
    
    6)
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
}