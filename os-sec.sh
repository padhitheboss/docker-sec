#!/bin/bash
#This is Script for Ubuntu OS Hardening
setup_audit(){
    #Installing Auditd
    (>&2 echo "Installing Auditd")
    if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

apt-get install -y "auditd"

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

(>&2 echo "Enabling service_auditd")

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask 'auditd.service'
"$SYSTEMCTL_EXEC" start 'auditd.service'
"$SYSTEMCTL_EXEC" enable 'auditd.service'

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi
}
setup_rsyslog(){
(>&2 echo "Installing rsyslog")

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

apt-get install -y "rsyslog"

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi


(>&2 echo "Enabling rsyslog")

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask 'rsyslog.service'
"$SYSTEMCTL_EXEC" start 'rsyslog.service'
"$SYSTEMCTL_EXEC" enable 'rsyslog.service'

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi




(>&2 echo "ensure logrotate activated")

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

LOGROTATE_CONF_FILE="/etc/logrotate.conf"
CRON_DAILY_LOGROTATE_FILE="/etc/cron.daily/logrotate"

# daily rotation is configured
grep -q "^daily$" $LOGROTATE_CONF_FILE|| echo "daily" >> $LOGROTATE_CONF_FILE

# remove any line configuring weekly, monthly or yearly rotation
sed -i '/^\s*\(weekly\|monthly\|yearly\).*$/d' $LOGROTATE_CONF_FILE

# configure cron.daily if not already
if ! grep -q "^[[:space:]]*/usr/sbin/logrotate[[:alnum:][:blank:][:punct:]]*$LOGROTATE_CONF_FILE$" $CRON_DAILY_LOGROTATE_FILE; then
	echo "#!/bin/sh" > $CRON_DAILY_LOGROTATE_FILE
	echo "/usr/sbin/logrotate $LOGROTATE_CONF_FILE" >> $CRON_DAILY_LOGROTATE_FILE
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi


}

securing_ssh(){
    (>&2 echo "Disabling Root Login")

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

if [ -e "/etc/ssh/sshd_config" ] ; then
    LC_ALL=C sed -i "/^\s*PermitRootLogin\s\+/Id" "/etc/ssh/sshd_config"
else
    touch "/etc/ssh/sshd_config"
fi
cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"

line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^Match', insert at
    # the end of the file.
    printf '%s\n' "PermitRootLogin no" >> "/etc/ssh/sshd_config"
else
    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
    printf '%s\n' "PermitRootLogin no" >> "/etc/ssh/sshd_config"
    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
fi
# Clean up after ourselves.
rm "/etc/ssh/sshd_config.bak"

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi


(>&2 echo "Configuring SSH Timeout")

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then


sshd_idle_timeout_value="300"



if [ -e "/etc/ssh/sshd_config" ] ; then
    LC_ALL=C sed -i "/^\s*ClientAliveInterval\s\+/Id" "/etc/ssh/sshd_config"
else
    touch "/etc/ssh/sshd_config"
fi
cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
# Insert before the line matching the regex '^Match'.
line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^Match', insert at
    # the end of the file.
    printf '%s\n' "ClientAliveInterval $sshd_idle_timeout_value" >> "/etc/ssh/sshd_config"
else
    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
    printf '%s\n' "ClientAliveInterval $sshd_idle_timeout_value" >> "/etc/ssh/sshd_config"
    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
fi
# Clean up after ourselves.
rm "/etc/ssh/sshd_config.bak"

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi



(>&2 echo "sshd Disable_Empty Passwords")

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

if [ -e "/etc/ssh/sshd_config" ] ; then
    LC_ALL=C sed -i "/^\s*PermitEmptyPasswords\s\+/Id" "/etc/ssh/sshd_config"
else
    touch "/etc/ssh/sshd_config"
fi
cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
# Insert before the line matching the regex '^Match'.
line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^Match', insert at
    # the end of the file.
    printf '%s\n' "PermitEmptyPasswords no" >> "/etc/ssh/sshd_config"
else
    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
    printf '%s\n' "PermitEmptyPasswords no" >> "/etc/ssh/sshd_config"
    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
fi
# Clean up after ourselves.
rm "/etc/ssh/sshd_config.bak"

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi


(>&2 echo "Setting sshd_set_keepalive_0")

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]; then

if [ -e "/etc/ssh/sshd_config" ] ; then
    LC_ALL=C sed -i "/^\s*ClientAliveCountMax\s\+/Id" "/etc/ssh/sshd_config"
else
    touch "/etc/ssh/sshd_config"
fi
cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
# Insert before the line matching the regex '^Match'.
line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^Match', insert at
    # the end of the file.
    printf '%s\n' "ClientAliveCountMax 0" >> "/etc/ssh/sshd_config"
else
    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
    printf '%s\n' "ClientAliveCountMax 0" >> "/etc/ssh/sshd_config"
    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
fi
# Clean up after ourselves.
rm "/etc/ssh/sshd_config.bak"

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi


}

correct_permissions(){
    echo "Fixing Common File Permissions"
    chgrp 42 /etc/shadow #file_groupowner_etc_shadow
    chown 0 /etc/passwd #file_owner_etc_passwd
    chgrp 42 /etc/gshadow #file_groupowner_etc_gshadow
    chgrp 0 /etc/group #file_groupowner_etc_group
    chmod 0640 /etc/gshadow  #file_permissions_etc_gshadow
    chown 0 /etc/shadow #file_owner_etc_shadow
    chmod 0640 /etc/shadow #file_permissions_etc_shadow
    chown 0 /etc/gshadow #file_owner_etc_gshadow
    chmod 0644 /etc/group #file_permissions_etc_group
    chmod 0644 /etc/passwd #file_permissions_etc_passwd
    chown 0 /etc/group #file_owner_etc_group
}
echo "Enabling Audit and Logging for OS"
setup_audit
echo "WARNING:Private Key Authentication to SSH should be configured prior to running this otherwise you not SSH into the system"
read -p "Are you sure? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Executed"
else
    securing_ssh
fi
correct_permissions
