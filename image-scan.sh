#!/bin/bash
#installing Trivy
# Here for Demonstration Purpose we are using Trivy
#Any Paid or opensouce toolscan be used forthis purpose
install_trivy(){
    echo"Installing Trivy"
    wget https://github.com/aquasecurity/trivy/releases/download/v0.19.1/trivy_0.19.1_Linux-64bit.deb
    chmod +x trivy_0.19.1_Linux-64bit.deb
    dpkg -i trivy_0.19.1_Linux-64bit.deb
}
install_trivy
scan_image(){
    echo "Specify the image name you want to scan:"
    read name
    trivy image $name > logs/$name.txt
    cat logs/$name.txt
}

scan_config(){
    echo "Enter Path of folder containing dockerfile or directory conatining IaC:"
    read loc
    trivy config $loc > logs/$loc.txt
    cat logs/$loc.txt
}
main_menu(){
    clear
    echo " "
    echo "Scanner For Images And Config Files"
    echo " "
    echo "Choose a option from below:"
         echo "1. Scan a Image"
         echo "2. Scan a Config File"
         echo "3. Exit Image Scanner"
    echo " "
    echo -n "Enter Option No.:"
    read option
    case $option in
	1)scan_image
    read -n 1 -p "<Enter> for main menu"
        main_menu
        ;;
    2)scan_config
    read -n 1 -p "<Enter> for main menu"
        main_menu
        ;;
    3)
		function goout () {
			TIME=2
			echo " "
			echo Exiting Image Scanner .....
			exit 0
		}
		goout
	;;

esac
}
main_menu

if [grep -q "USER" trivy config $loc];then
    echo "ADD the following Lines to Docker File"
    echo "RUN groupadd -r app_user && useradd -r -g app_user app_user"
    echo "RUN chsh -s /usr/sbin/nologin root"
    echo "The Application in container should not run with root privileges"
