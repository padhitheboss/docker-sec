#!/bin/bash
# Defining Colors for text output

red=$( tput setaf 1 );
yellow=$( tput setaf 3 );
green=$( tput setaf 2 );
blue=$( tput setaf 4 )
normal=$( tput sgr 0 );

fix_part()
{
    echo "For better security a separate partition for containers"
    read -p "Do you have an extra empty disk which can be dedicated to docker(y/n): " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Create Partion Manually for Containers"
else
    echo "Enter a Disk Path:(ex:/dev/sda2):"
    read Disk
    systemctl stop docker
    mv /var/lib/docker /var/lib/docker-backup
    sudo mkfs.ext4 /dev/xvdf
    echo $Disk" /var/lib/docker auto noatime 0 0" | sudo tee -a /etc/fstab
    sudo mount /var/lib/docker
    if [ $? -eq 0 ]; then
        cp -rf /var/lib/docker-backup/* /var/lib/docker
        echo "Changed Parttion Successfully."
    else
        echo "Unable to Mount Partiton"
        echo "Reverting Changes"
        mv /var/lib/docker-backup /var/lib/docker
    fi
    systemctl start docker
fi
}
enable_auditing_docker()
{
    # Configure auditing for Docker directories, files, and services.
    # See CIS Benchmark 1.5 to 1.13
    echo "${yellow}Creating a backup of /etc/audit/audit.rules.${normal}"
    cp /etc/audit/audit.rules /etc/audit/audit.rules.bak
    echo "
    ${green}Backup created and it can be found at /etc/audit/audit.rules.bak.${normal}"
    
    # Make appropriate auditing entries to audit.rules if they do not exist already.
    
    if ! grep -q  "docker.service" /etc/audit/audit.rules;
    then
        echo "-w /lib/systemd/system/docker.service -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "docker.socket" /etc/audit/audit.rules;
    then
        echo "-w /lib/systemd/system/docker.socket -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "/usr/bin/docker" /etc/audit/audit.rules;
    then
        echo "-w /usr/bin/docker -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "/var/lib/docker" /etc/audit/audit.rules;
    then
        echo "-w /var/lib/docker -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "/etc/docker" /etc/audit/audit.rules;
    then
        echo "-w /etc/docker -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "/etc/default/docker" /etc/audit/audit.rules;
    then
        echo "-w /etc/default/docker -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "/etc/docker/daemon.json" /etc/audit/audit.rules;
    then
        echo "-w /etc/docker/daemon.json -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "/usr/bin/containerd" /etc/audit/audit.rules;
    then
        echo "-w /usr/bin/containerd -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "/usr/bin/runc" /etc/audit/audit.rules;
    then
        echo "-w /usr/bin/runc -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "/run/containerd" /etc/audit/audit.rules;
    then
        echo "-w /run/containerd -p wa" >> /etc/audit/rules.d/audit.rules
    fi

    if ! grep -q  "/etc/containerd/config.toml" /etc/audit/audit.rules;
    then
        echo "-w /etc/containerd/config.toml -p wa" >> /etc/audit/rules.d/audit.rules
    fi
    
    if ! grep -q  "/usr/bin/containerd-shim" /etc/audit/audit.rules;
    then
        echo "-w /usr/bin/containerd-shim-runc-v1 -p wa" >> /etc/audit/rules.d/audit.rules
        echo "-w /usr/bin/containerd-shim-runc-v2 -p wa" >> /etc/audit/rules.d/audit.rules
        echo "-w /usr/bin/containerd-shim" >> /etc/audit/rules.d/audit.rules
    fi

    if ! grep -q  "/usr/bin/dockerd" /etc/audit/audit.rules;
    then
        echo "-w /usr/bin/dockerd -k docker" >> /etc/audit/rules.d/audit.rules
    fi

    echo "
    ${green}auditd set.${normal}"
    
    echo "${yellow}
    Restarting auditd service.${normal}"
    
    service auditd restart
    
    echo "
    ${green}auditd service restarted.${normal}"
    
}

enable_content_trust()
{
    echo "Enabling Docker Content Trst"
    export DOCKER_CONTENT_TRUST=1
    echo "DOCKER_CONTENT_TRUST=1" | sudo tee -a /etc/environment
}


docker_daemon_config(){
    echo "Creating a backup of /etc/default/docker."
    
    cp /etc/default/docker /etc/default/docker.bak
    
    echo "${green}Backup created and it can be found at /etc/default/docker.bak.${normal}"
    
    # Setting Docker to check daemon.json file if needed
    
    if ! grep -q  "daemon.json" /etc/default/docker;
    then
        echo "# Pointing docker to daemon.json file.
DOCKER OPTS=\"--config-file=/etc/docker/daemon.json\"" >> /etc/default/docker
fi

# If /etc/docker/daemon.json file exists, create backup. Else continue and create file.

if [[ -f /etc/docker/daemon.json ]];
then
  echo "${yellow}Creating a backup of /etc/docker/daemon.json file.${normal}"

cp /etc/docker/daemon.json /etc/docker/daemon.json.bak

  echo "${green}Backup has been created and can be found at /etc/docker/daemon.json.bak.${normal}"
fi

# Adding relevant lines to /etc/docker/daemon.json file if they are not already there.

if ! grep -q  "{" /etc/docker/daemon.json;
then
        cp files/basic.txt /etc/docker/daemon.json
    else
        echo "Some Custom Configuration is Present Check Before Applying"
    fi

    
    # Restart Docker Service
    
    echo "${yellow}
    Restarting docker service.${normal}"
    
    service docker restart
    
    echo "
    ${green}Docker service restarted.${normal}"
}
fix_part

read -p "Do you want to enable docker Auditing and logging(y/n)" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ""
else
    enable_auditing_docker
    docker_daemon_config
    enable_content_trust
fi

fix_part
