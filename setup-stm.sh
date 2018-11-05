#!/bin/bash
#
# Install all necessary packages etc to build and run Saisei Flow Manager on Ubuntu
#
# Must be run as root.
#

# Each run gets its own log file
LOG_FILE=/var/log/stm_setup_$(date -Iseconds).log
UBUNTU_13_04=13.04
UBUNTU_13_10=13.10
UBUNTU_14_04=14.04
STOPWAITING="apport stop/waiting"
UBUNTU_VER=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d= -f2)
BOOST_VER=$(cat /usr/include/boost/version.hpp | grep "BOOST_LIB_VERSION" | grep "#define" | cut -f3 -d" " | sed "s/\"//g")
if [ ! -f /.dockerinit ]; then 
    I40E_VER=$(modinfo i40e | grep version | head -n 1 |rev | cut -d " " -f 1 | rev)
    I40E_REQUIRED_VER="1.2.48.2"40E_VER=$(modinfo i40e | grep version | head -n 1 |rev | cut -d " " -f 1 | rev)
fi
SAISEI_APACHE_INSTALLED=0
if [ -f /etc/apache2/sites-available/stm.conf ]; then
    SAISEI_APACHE_INSTALLED=1
fi
NAVLLIB=/usr/lib/libnavl.so.4.4.1
BOOTTARGETDIR=/etc/stmboottarget
BOOTALT=0
MYSQL_INSTALLED=0
VERREQUIRED=14.04
MEMREQUIRED=16000000
MEMMEDIUMMODEL=50000000
DISK_MIN=400000000

######################################################
# Installation Functions
######################################################

function log_info
{
    local msg=$*
    echo $(date -Iseconds) " INFO  $msg" >> $LOG_FILE
}

function log_info_and_echo
{
    local msg=$*
    log_info $msg
    echo $msg
}

function log_error
{
    local msg=$*
    echo $(date -Iseconds) " ERROR $msg" >> $LOG_FILE
}

function log_error_and_echo
{
    local msg=$*
    log_error $msg
    echo $msg
}

function log_error_on_fail
{
    local err=$1
    local msg=$2
    if [ $err != 0 ]; then
        log_error $msg
    fi
}

function aptget_and_log_fail
{
    local pkg=$1
    apt-get install -y --force-yes $pkg
    log_error_on_fail $? "$(echo apt-get install of $pkg failed)"
}

function pip_and_log_fail
{
    local pkg=$1
    /usr/bin/yes | pip install $pkg
    log_error_on_fail $? "$(echo pip install of $pkg failed)"
}

function mkdir_and_log_fail
{
    local pth=$1
    mkdir -p $pth
    log_error_on_fail $? "$(echo mkdir of $pth failed)"
}

function setup_navl {
    log_info_and_echo "setup navl - start"
    rm -f /opt/stm/target.alt/NAVL_VERSION_*
    touch /opt/stm/target.alt/NAVL_VERSION_4_4_1_FILE
    if [ ! -f $NAVLLIB ]; then
        cp /opt/stm/target.alt/libs/* /usr/lib/.
        rm -f /usr/lib/libnavl.so.4.4
        rm -f /usr/lib/libnavl.so
        ln -s /usr/lib/libnavl.so.4.4.1 /usr/lib/libnavl.so.4.4
        ln -s /usr/lib/libnavl.so.4.4.1 /usr/lib/libnavl.so
        log_error_on_fail $? "Failed to install navl libraries"
    fi
    log_info_and_echo "setup navl - end"
}

function install_boost {
    log_info_and_echo "install boost - start"
    if [[ -z "$BOOST_VER" ]]; then
        if [ $UBUNTU_VER = $UBUNTU_14_04 ]; then
            apt-get install -y --force-yes libboost1.54-all-dev
            log_error_on_fail $? "initial libboost-all-dev apt-get install failed"
        fi
    else
        if [ $BOOST_VER != "1_54" ]; then
            if [ $UBUNTU_VER = $UBUNTU_14_04 ]; then
                if [ $BOOST_VER = "1_53" ]; then
                    apt-get autoremove -y --force-yes libboost-all-dev
                    log_error_on_fail $? "libboost-all-dev apt-get autoremove failed"
                    apt-get install -y --force-yes libboost1.54-all-dev
                    log_error_on_fail $? "upgrade libboost-all-dev apt-get install failed"
                else
                    log_error "Failed to upgrade to boost 54 from incompatible boost version"
                fi
            else
                log_error "Wrong Ubuntu version, libboost-all-dev install failed"
            fi
        fi
    fi
    log_info_and_echo "install boost - end"
}

function install_apache_first_step {
    log_info_and_echo "install apache, first step - start"
    if [ $SAISEI_APACHE_INSTALLED = 0 ]; then
        if [ $UBUNTU_VER = $UBUNTU_14_04 ]; then
            aptget_and_log_fail apache2
            aptget_and_log_fail apache2-utils
        fi
        aptget_and_log_fail libapache2-mod-wsgi
    fi
    log_info_and_echo "install apache, first step - end"
}

function install_apache_second_step {
    log_info_and_echo "install apache, second step - start"
    if [ ! -f /etc/stmfiles/files/ssl/saisei-stm.crt ] && [ ! -f /etc/stmfiles/files/ssl/saisei-stm.key ]; then
        cp -p /opt/stm/target.alt/saisei-stm.crt /etc/stmfiles/files/ssl/saisei-stm.crt
        log_error_on_fail $? "install apache, second step - failed to install certficate for stm apache HTTPS"
        cp -p /opt/stm/target.alt/saisei-stm.key /etc/stmfiles/files/ssl/saisei-stm.key
        log_error_on_fail $? "install apache, second step - failed to install key file for stm apache HTTPS"
    fi
    awk '!/^Listen (5000|5002|5029)/' /etc/apache2/ports.conf > /etc/apache2/ports.conf.tmp && mv /etc/apache2/ports.conf.tmp /etc/apache2/ports.conf
    log_error_on_fail $? "install apache, second step - failed to configure listening port for apache (awk)"
    sed -i "/^Listen 80/a Listen 5000\nListen 5002\nListen 5029" /etc/apache2/ports.conf
    log_error_on_fail $? "install apache, second step - failed to configure listening port for apache (sed)"
    a2enmod -q ssl
    log_error_on_fail $? "failed to enable ssl apache module"
    a2enmod -q rewrite
    log_error_on_fail $? "failed to enable rewrite apache module"
    a2enmod -q macro
    log_error_on_fail $? "failed to enable macro apache module"
    if [ $SAISEI_APACHE_INSTALLED = 0 ]; then
        a2ensite stm
        log_error_on_fail $? "failed to enable stm apache module"
        rm -f /etc/apache2/sites-enabled/000-default.conf
        log_error_on_fail $? "failed to remove default apache configuration"
        service apache2 reload
        log_error_on_fail $? "failed to reload apache service"
    fi
    cp /opt/stm/target.alt/logrotate.stm.conf /etc/logrotate.stm.conf
    log_error_on_fail $? "failed to setup log rotation for stm apache log files - logrotate.stm.conf"
    cp /opt/stm/target.alt/30-rsyslog.stm.conf /etc/rsyslog.d/.
    log_error_on_fail $? "failed to setup log rotation for stm apache log files - 30-rsyslog.stm.conf"
    cp /opt/stm/target.alt/logrotate /etc/cron.hourly/.
    log_error_on_fail $? "failed to setup log rotation for stm apache log files - cron.hourly/logrotate"
    cp /opt/stm/target.alt/0hourly /etc/cron.d/.
    log_error_on_fail $? "failed to setup log rotation for stm apache log files - cron.hourly/0hourly"
    log_info_and_echo "install apache, second step - end"
}

function install_snmp_first_step {
    log_info_and_echo "install snmp, first step - start"
    aptget_and_log_fail snmp
    aptget_and_log_fail snmpd
    aptget_and_log_fail libsnmp-dev
    aptget_and_log_fail snmp-mibs-downloader
    log_info_and_echo "install snmp, first step - end"
}

function disable_apport {
    log_info_and_echo "disable apport - start"
    APPORTSTATUS=$(service apport status)
    if [ "$APPORTSTATUS" != "$STOPWAITING" ]; then
        service apport stop
    fi
    if [ -f /etc/default/apport ]; then
        sed -i "s/enabled=1/enabled=0/g" /etc/default/apport
        log_error_on_fail $? "failed to set enabled to 0 in /etc/default/apport"
    fi
    log_info_and_echo "disable apport - end"
}

function install_snmp_second_step {
    log_info_and_echo "install snmp, second step - start"
    sed -i "/^agentAddress  udp:127.0.0.1:161/s/^/#/" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to disable upd agent address in snmpd.conf"
    awk '!/udp:161/' /etc/snmp/snmpd.conf  > /etc/snmp/snmpd.conf.tmp && mv /etc/snmp/snmpd.conf.tmp /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to remove mention of udp:161 from snmpd.conf"
    sed -i "/^#  Listen for connections on all interfaces/a agentAddress udp:161,udp6:[::1]:161" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to add agentAddress to snmpd.conf"
    awk '!/view   systemonly  included   .1.3.6.1.4.1.41720/' /etc/snmp/snmpd.conf > /etc/snmp/snmpd.conf.tmp && mv /etc/snmp/snmpd.conf.tmp /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to remove Saisei IANA number(41720) from systemonly view in snmpd.conf"
    awk '!/view   systemonly  included SNMPv2-MIB/' /etc/snmp/snmpd.conf > /etc/snmp/snmpd.conf.tmp && mv /etc/snmp/snmpd.conf.tmp /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to remove SNMPv2-MIB from systemonly view in snmpd.conf"
    awk '!/view   systemonly  included IF-MIB::ifTable/' /etc/snmp/snmpd.conf > /etc/snmp/snmpd.conf.tmp && mv /etc/snmp/snmpd.conf.tmp /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to remove IF-MIB::ifTable from systemonly view in snmpd.conf"
    awk '!/view   systemonly  included IF-MIB::ifXTable/' /etc/snmp/snmpd.conf > /etc/snmp/snmpd.conf.tmp && mv /etc/snmp/snmpd.conf.tmp /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to remove IF-MIB::ifXTable from systemonly view in snmpd.conf"
    sed -i "/^view   systemonly  included   .1.3.6.1.2.1.25.1/a view   systemonly  included   .1.3.6.1.4.1.41720" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to add Saisei IANA number(41720) to systemonly view in snmpd.conf"
    sed -i "/^view   systemonly  included   .1.3.6.1.4.1.41720/a view   systemonly  included SNMPv2-MIB" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to add SNMPv2-MIB to systemonly view in snmpd.conf"
    sed -i "/^view   systemonly  included SNMPv2-MIB/a view   systemonly  included IF-MIB::ifTable" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to add IF-MIB::ifTable to systemonly view in snmpd.conf"
    sed -i "/^view   systemonly  included IF-MIB::ifTable/a view   systemonly  included IF-MIB::ifXTable" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to add IF-MIB::ifXTable to systemonly view in snmpd.conf"
    sed -i "/^ *rocommunity/s/^/#/" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to disable rocommunity in snmpd.conf"
    awk '!/rwcommunity public  default    -V systemonly/' /etc/snmp/snmpd.conf > /etc/snmp/snmpd.conf.tmp && mv /etc/snmp/snmpd.conf.tmp /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to remove rwcommunity from snmpd.conf"
    sed -i "/^# *rocommunity public  default/a rwcommunity public  default    -V systemonly" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to add rwcommunity to snmpd.conf"
    sed -i "/^sysContact/s/^/#/" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to disable sysContact in snmpd.conf"
    awk '!/sysDescr     Saisei Traffic Manager/' /etc/snmp/snmpd.conf > /etc/snmp/snmpd.conf.tmp && mv /etc/snmp/snmpd.conf.tmp /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to remove sysDescr from snmpd.conf"
    sed -i "/^#sysContact/a sysDescr     Saisei Traffic Manager" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to add sysDescr to snmpd.conf"
    sed -i "/^sysLocation/s/^/#/" /etc/snmp/snmpd.conf
    log_error_on_fail $? "failed to disable sysLocation in snmpd.conf"
    sed -i -e "s/mibs :/mibs +ALL:/" /etc/snmp/snmp.conf
    log_error_on_fail $? "failed to add mibs +ALL to snmpd.conf"
    awk '!/SNMPDOPTS/' /etc/default/snmpd > /etc/default/snmpd.tmp && mv /etc/default/snmpd.tmp /etc/default/snmpd
    log_error_on_fail $? "failed to remove SNMPDOPTS from snmpd.conf"
    sed -i "/^# snmpd options/a SNMPDOPTS='-Lsd -Lf /dev/null -u snmp -g snmp --master=agentx -I -ifTable -I -ifXTable -I -smux,mteTrigger,mteTriggerConf -p /var/run/snmpd.pid'" /etc/default/snmpd
    log_error_on_fail $? "failed to add SNMPDOPTS to snmpd.conf"
    log_info_and_echo "install snmp, second step - end"
}

function install_mibs {
    log_info_and_echo "install mibs - start"
    download-mibs
    log_error_on_fail $? "download-mibs failed"
    rm -f /usr/share/mibs/ietf/IPSEC-SPD-MIB
    log_error_on_fail $? "failed to remove IPSEC-SPD-MIB"
    rm -f /usr/share/mibs/ietf/IPSEC-SPD-MIB
    log_error_on_fail $? "failed to remove IPSEC-SPD-MIB"
    rm -f /usr/share/mibs/ietf/IPATM-IPMC-MIB
    log_error_on_fail $? "failed to remove IPATM-IPMC-MIB"
    rm -f /usr/share/mibs/iana/IANA-IPPM-METRICS-REGISTRY-MIB
    log_error_on_fail $? "failed to remove IANA-IPPM-METRICS-REGISTRY-MIB"
    rm -f /usr/share/mibs/ietf/SNMPv2-PDU
    log_error_on_fail $? "failed to remove SNMPv2-PDU MIB"
    rm -f /usr/share/snmp/mibs/saisei-mib.txt
    log_error_on_fail $? "failed to remove saisei-mib.txt MIB"
    mkdir_and_log_fail /usr/share/snmp/mibs
    cp /opt/stm/target.alt/saisei-mib.txt /usr/share/snmp/mibs/.
    log_error_on_fail $? "failed to copy saisei-mib.txt"
    service snmpd restart
    err=$?
    sleep 2
    log_error_on_fail $err "failed restart snmpd service"
    log_info_and_echo "install mibs - end"
}

function setup_init_dot_d {
    log_info_and_echo "setup init.d - start"
    cp /opt/stm/target.alt/stm-start.sh /etc/init.d/.
    log_error_on_fail $? "failed to copy stm-start.sh"
    update-rc.d start-stm.sh remove
    log_error_on_fail $? "failed: update-rc.d start-stm.sh remove"
    rm -f /etc/init.d/start-stm.sh
    log_error_on_fail $? "failed to remove stm-start.sh"
    chmod a+x /etc/init.d/stm-start.sh
    log_error_on_fail $? "failed to make stm-start.sh executable"
    update-rc.d stm-start.sh defaults
    log_error_on_fail $? "failed to install stm-start.sh"
    log_info_and_echo "setup init.d - end"
}

function configure_linux {
    log_info_and_echo "configure linux - start"
    if [ ! -f /.dockerinit ]; then 
        sed -i "s/Prompt=normal/Prompt=never/g" /etc/update-manager/release-upgrades
        log_error_on_fail $? "failed to change Linux upgrade popups from normal to never"
        sed -i "s/Prompt=lts/Prompt=never/g" /etc/update-manager/release-upgrades
        log_error_on_fail $? "failed to change Linux upgrade popups from lts to never"
        if [ -f /etc/apt/apt.conf.d/10periodic ]; then
            sed -i "s/1/0/g" /etc/apt/apt.conf.d/10periodic
            log_error_on_fail $? "failed to disable Linux update popups"
        fi
    fi
    echo linux-image-generic hold | dpkg --set-selections
    log_error_on_fail $? "failed to disable kernel upgrades"
    chmod a+w /etc/sudoers
    log_error_on_fail $? "failed to make sudoers writable"
    awk '!/%sudo/' /etc/sudoers > /etc/sudoers.tmp && mv /etc/sudoers.tmp /etc/sudoers
    log_error_on_fail $? "failed to remove %sudo from sudoers"
    sed -i "/^# Allow members of group sudo to execute any command/a%sudo ALL=NOPASSWD: ALL" /etc/sudoers
    log_error_on_fail $? "failed to add %sudo from sudoers"
    chmod a-w /etc/sudoers
    log_error_on_fail $? "failed to make sudoers not writable"
    usermod -g sudo www-data
    log_error_on_fail $? "failed to add www-data to the sudo group"
    sed -i "s/#FSCKFIX=no/FSCKFIX=yes/g" /etc/default/rcS
    log_error_on_fail $? "failed to set fsck to fix errors on boot"
    touch /var/log/sshd_jail.log
    log_error_on_fail $? "failed to create sshd_jail.log"
    aptget_and_log_fail fail2ban
    cp /opt/stm/target.alt/jail.local /etc/fail2ban/.
    log_error_on_fail $? "failed to copy jail.local"
    cp /opt/stm/target.alt/mysql_stm.cnf /etc/mysql/conf.d/.
    log_error_on_fail $? "failed to copy mysql_stm.cnf"
    if [ ! -f /.dockerinit ]; then 
        awk '!/^i40e/' /etc/modules > /etc/modules.tmp && mv /etc/modules.tmp /etc/modules
        log_error_on_fail $? "failed to enable Intel i710 NIC support: removal of i40e from modules file failed"
        sed -i '/^rtc/a i40e' /etc/modules
        log_error_on_fail $? "failed to enable Intel i710 NIC support: adding i40e to modules file failed"
        update-initramfs -u
        log_error_on_fail $? "failed to enable Intel i710 NIC support: update-initramfs failed"
    fi
    log_info_and_echo "configure linux - end"
}

function install_ntp {
    log_info_and_echo "install ntp - start"
    aptget_and_log_fail ntp
    sed -i "/^server/s/^/#/" /etc/ntp.conf
    log_error_on_fail $? "failed to disable all servers in ntp.conf"
    sed -i "s/#server 0.ubuntu.pool.ntp.org/server 0.ubuntu.pool.ntp.org/g" /etc/ntp.conf
    log_error_on_fail $? "failed to enable server 0 in ntp.conf"
    sed -i "s/#server 1.ubuntu.pool.ntp.org/server 1.ubuntu.pool.ntp.org/g" /etc/ntp.conf
    log_error_on_fail $? "failed to enable server 1 in ntp.conf"
    sed -i "s/#server 2.ubuntu.pool.ntp.org/server 2.ubuntu.pool.ntp.org/g" /etc/ntp.conf
    log_error_on_fail $? "failed to enable server 2 in ntp.conf"
    sed -i "s/#server 3.ubuntu.pool.ntp.org/server 3.ubuntu.pool.ntp.org/g" /etc/ntp.conf
    log_error_on_fail $? "failed to enable server 3 in ntp.conf"
    awk '!/#Saisei configured NTP servers/' /etc/ntp.conf > /etc/ntp.conf.tmp && mv /etc/ntp.conf.tmp /etc/ntp.conf
    log_error_on_fail $? "failed to remove Saisei comment from ntp.conf"
    sed -i "/^# Specify one or more NTP servers./a #Saisei configured NTP servers" /etc/ntp.conf
    log_error_on_fail $? "failed to add Saisei comment to ntp.conf"
    log_info_and_echo "install ntp - end"
}

function configure_ssh {
    log_info_and_echo "configure ssh - start"
    if [ -f /etc/update-motd.d/90-updates-available ]; then
        sed -i 's/^#//' /etc/update-motd.d/90-updates-available
        log_error_on_fail $? "clean up of ssh login output: failed to uncomment all lines in 90-updates-available"
        sed -i 's/^/#/' /etc/update-motd.d/90-updates-available
        log_error_on_fail $? "clean up of ssh login output: failed to comment all lines in 90-updates-available"
    fi
    if [ -f /etc/update-motd.d/91-release-upgrade ]; then
        sed -i 's/^#//' /etc/update-motd.d/91-release-upgrade
        log_error_on_fail $? "clean up of ssh login output: failed to uncomment all lines in 91-release-upgrade"
        sed -i 's/^/#/' /etc/update-motd.d/91-release-upgrade
        log_error_on_fail $? "clean up of ssh login output: failed to comment all lines in 91-release-upgrade"
    fi
    if [ -f /etc/update-motd.d/00-header ]; then
        sed  -i "/^printf/s/^/#/" /etc/update-motd.d/00-header
        log_error_on_fail $? "clean up of ssh login output: failed to disable the printf in 00-header"
    fi
    if [ -f /etc/update-motd.d/10-help-text ]; then
        sed  -i "/^printf/s/^/#/" /etc/update-motd.d/10-help-text
        log_error_on_fail $? "clean up of ssh login output: failed to disable the printf in 10-help-text"
    fi
    log_info_and_echo "configure ssh - end"
}

function install_mysql {
    log_info_and_echo "install mysql - start"
    export DEBIAN_FRONTEND=noninteractive
    if [ -f /usr/bin/mysql ]; then
        MYSQL_INSTALLED=1
    fi

    if  [ -f $ETCPATH/sqlpasswd ];
    then
        source $ETCPATH/sqlpasswd
        if [ ! -z ${new_password+x} ];
        then
            password=$new_password
        else
            password="saisei"
        fi
    else
            password="saisei"
    fi

    aptget_and_log_fail mysql-server-5.6
    aptget_and_log_fail mysql-utilities
    pip_and_log_fail MySQL-python
    pip_and_log_fail SQLAlchemy
    if [ $MYSQL_INSTALLED = 0 ]; then
        mysqladmin -u root password $password
        log_error_on_fail $? "failed to set mysql root password"
    fi
    if [ ! -d /var/lib/mysql/history ]; then
        mysql -u root --password=$password -s -N -e "select user from mysql.user where user = 'history'" | egrep '^history$' -q
        if [ $? != 0 ]; then
            mysql -u root --password=$password -e "grant all on history.* to 'history'@'localhost' identified by 'saisei'"
            log_error_on_fail $? "failed to grant access to history DB tables for user history"
        fi
        mysql -u history --password=$password -s < /opt/stm/target.alt/create_history_db.sql
        log_error_on_fail $? "failed to create history DB base tables"
        mysql -u history --password=$password -s < /opt/stm/target.alt/create_history_db_class_tables.sql
        log_error_on_fail $? "failed to create history DB per-class tables"
    fi
    if [ -f /etc/init/mysql.conf ]; then
        mv /etc/init/mysql.conf /etc/init/mysql.conf.disabled
        log_error_on_fail $? "failed to disable /etc/init/mysql.conf"
    fi
    log_info_and_echo "install mysql - end"
}    

function install_report_writer {
    log_info_and_echo "install report writer - start"
    aptget_and_log_fail python-lxml
    pip_and_log_fail python-docx
    aptget_and_log_fail python-numpy
    aptget_and_log_fail python-scipy
    aptget_and_log_fail python-matplotlib
    aptget_and_log_fail ipython
    aptget_and_log_fail ipython-notebook
    aptget_and_log_fail python-pandas
    aptget_and_log_fail python-nose
    pip install brewer2mpl
    log_error_on_fail $? "pip install of brewer2mpl failed"
    aptget_and_log_fail cython
    aptget_and_log_fail libgeos-dev
    aptget_and_log_fail libgeos++-dev
    aptget_and_log_fail libproj-dev
    aptget_and_log_fail libudunits2-dev
    aptget_and_log_fail libnetcdf-dev
    aptget_and_log_fail unoconv
    pip install pyshp
    log_error_on_fail $? "pip install of pyshp failed"
    mkdir_and_log_fail tools/report_writer/graphics
    sed -i "s/: TkAgg/: Agg/g" /etc/matplotlibrc 
    log_error_on_fail $? "failed update of /etc/matplotlibrc"
    aptget_and_log_fail libreoffice
    mkdir_and_log_fail /var/stm/reports
    chmod a+w /var/stm/reports
    log_error_on_fail $? "failed to make /var/stm/reports writeable"
    rm -f /var/stm/reports/*
    log_error_on_fail $? "failed to remove cached reports"
    log_info_and_echo "install report writer - end"
}

function setup_stm_file_system_first_step {
    log_info_and_echo "setup stm file system, first step - start"
    if [ ! -d /etc/stmfiles/files/log ]; then
        mkdir_and_log_fail /etc/stm
        mkdir_and_log_fail /etc/stm/cli
        mkdir_and_log_fail /etc/stmfiles
        mkdir_and_log_fail /etc/stmfiles/files/ssl
        mkdir_and_log_fail /etc/stmfiles/files
        mkdir_and_log_fail /etc/stmfiles/files/scripts
        mkdir_and_log_fail /etc/stmfiles/files/auto_scripts
        mkdir_and_log_fail /etc/stmfiles/files/config
        mkdir_and_log_fail /etc/stmfiles/files/config/stm
        mkdir_and_log_fail /etc/stmfiles/files/config/stm.alt
        mkdir_and_log_fail /etc/stmfiles/files/cores
        mkdir_and_log_fail /etc/stmfiles/files/diagnostics
        mkdir_and_log_fail /etc/stmfiles/files/install_images
        mkdir_and_log_fail /etc/stmfiles/nlri
        mkdir_and_log_fail /etc/stmfiles/files/licenses
        chown -R www-data:www-data /etc/stmfiles/files
        log_error_on_fail $? "failed to change ownership of /etc/stmfiles/files"
        chown -R nobody:nogroup /etc/stmfiles/nlri
        log_error_on_fail $? "failed to change ownership of /etc/stmfiles/nlri"
        if [ -d /etc/stm/conf_files ]; then
            if [ "$(ls -A /etc/stm/conf_files)" ]; then
                mv /etc/stm/conf_files/* /etc/stmfiles/files/config/stm/.
                log_error_on_fail $? "failed to move contents of /etc/stm/conf_files dir"
            fi
            if [ "$(ls -A /etc/stm.alt/conf_files)" ]; then
                mv /etc/stm.alt/conf_files/* /etc/stmfiles/files/config/stm.alt/.
                log_error_on_fail $? "failed to move contents of /etc/stm.alt/conf_files dir"
            fi
            rm -rf /etc/stm/conf_files 
            log_error_on_fail $? "failed to remove /etc/stm/conf_files"
            rm -rf /etc/stm.alt/conf_files 
            log_error_on_fail $? "failed to remove /etc/stm.alt/conf_files"
            ln -s /etc/stmfiles/files/config/stm /etc/stm/conf_files 
            log_error_on_fail $? "failed to create link /etc/stm/conf_files"
        fi
        mkdir_and_log_fail /etc/stm.alt
        mkdir_and_log_fail /etc/stm.alt/navl
        chmod a+rx /etc/stm.alt
        log_error_on_fail $? "failed to set priorities for stm.alt dir"
        ln -s /etc/stmfiles/files/config/stm.alt /etc/stm.alt/conf_files 
        log_error_on_fail $? "failed to create link /etc/stm.alt/conf_files"
        service rsyslog stop
        log_error_on_fail $? "failed to stop rsyslog service"
        mv /var/log /etc/stmfiles/files/.
        log_error_on_fail $? "failed to move contents of /var/log dir"
        ln -s /etc/stmfiles/files/log /var/log 
        log_error_on_fail $? "failed to create link /var/log"
        chmod a+w /var/log
        log_error_on_fail $? "failed to set permissions on log directory"
        sed -i "s/^\$FileCreateMode 064./\$FileCreateMode 0644/" /etc/rsyslog.conf
        log_error_on_fail $? "failed to change FileCreateMode in /etc/rsyslog.conf"
        if test -n "$(find /var/log -maxdepth 1 -name 'stm_proxy.log*' -print -quit)"; then
            chown syslog:adm /var/log/stm_proxy.log*
            log_error_on_fail $? "failed to change owner of /var/log/stm_proxy.log*"
        fi
        if test -n "$(find /var/log -maxdepth 1 -name 'stm_reports.log*' -print -quit)"; then
            chown syslog:adm /var/log/stm_reports.log*
            log_error_on_fail $? "failed to change owner of /var/log/stm_reports.log*"
        fi
        service rsyslog start
        log_error_on_fail $? "failed to start rsyslog service"
    else
        # Check existence of new directories in stmfiles before creating them
        if [ ! -d /etc/stmfiles/files/auto_scripts ]; then
            mkdir_and_log_fail /etc/stmfiles/files/auto_scripts
        fi
        chown -R www-data:www-data /etc/stmfiles/files/auto_scripts
        log_error_on_fail $? "failed to change ownership of /etc/stmfiles/files/auto_scripts"
        if [ -f /var/log/stm_rest_b.log ]; then
            chmod o+r /var/log/stm_rest_b.log
            log_error_on_fail $? "failed chmod on /var/log/stm_rest_b.log"
        fi
        if [ -f /var/log/syslog ]; then
            chmod o+r /var/log/syslog
            log_error_on_fail $? "failed chmod on /var/log/syslog"
        fi
    fi
    if [ -d /etc/stmfiles/files/nlri ]; then
        rm -rf /etc/stmfiles/files/nlri
        log_error_on_fail $? "failed to delete old nlri directory"
    fi
    cp /opt/stm/target.alt/GeoIPCountryWhois.csv /etc/stm.alt/.
    log_error_on_fail $? "failed to install GEO DB"
    cp /opt/stm/target.alt/as_info_db.txt /etc/stm.alt/.
    log_error_on_fail $? "failed to install as_info.txt"
    cp /opt/stm/target.alt/applications.csv /etc/stm.alt/.
    log_error_on_fail $? "failed to install applications.csv"
    cp /opt/stm/target.alt/applications-pace2.csv /etc/stm.alt/.
    log_error_on_fail $? "failed to install applications-pace2.csv"
    cp /opt/stm/target.alt/alarms_config.csv /etc/stm.alt/.
    log_error_on_fail $? "failed to install alarms_config.csv"
    cp /opt/stm/target.alt/host_reputation_dbs_config.csv /etc/stm.alt/.
    log_error_on_fail $? "failed to install host_reputation_dbs_config.csv"
    cp /opt/stm/target.alt/stm.wsgi /etc/stm.alt/.
    log_error_on_fail $? "failed to install stm.wsgi"
    cp /opt/stm/target.alt/callhome.pub /etc/stmfiles/files/ssl/
    log_error_on_fail $? "failed to install callhome.pub"
    if [ $SAISEI_APACHE_INSTALLED = 0 ]; then
        cp /opt/stm/target.alt/stm-apache /etc/apache2/sites-available/stm.conf
        log_error_on_fail $? "failed to configure apache sites-available"
    fi
    cp -drf /opt/stm/target.alt/etc/* /etc/.
    log_error_on_fail $? "failed to install stm preferences in /etc"
    log_info_and_echo "setup stm file system, first step - end"
}

function setup_stm_file_system_second_step {
    log_info_and_echo "setup stm file system, second step - start"
    if [ ! -d /etc/stm ]; then
        cp -dprf /etc/stm.alt /etc/stm
        rm -rf /etc/stm/conf_files 
        log_error_on_fail $? "failed to remove /etc/stm/conf_files"
        ln -s /etc/stmfiles/files/config/stm /etc/stm/conf_files 
        log_error_on_fail $? "failed to create link /etc/stm/conf_files"
    fi
    log_info_and_echo "setup stm file system, second step - end"
}

function configure_grub {
    log_info_and_echo "configure grub - start"
    awk '!/^GRUB_RECORDFAIL_TIMEOUT/' /etc/default/grub > /etc/default/grub.tmp && mv /etc/default/grub.tmp /etc/default/grub
    log_error_on_fail $? "failed to remove GRUB_RECORDFAIL_TIMEOUT from /etc/default/grub"
    sed -i '/^GRUB_TIMEOUT/a GRUB_RECORDFAIL_TIMEOUT=2' /etc/default/grub
    log_error_on_fail $? "failed to add GRUB_RECORDFAIL_TIMEOUT to /etc/default/grub"
    awk '!/^GRUB_CMDLINE_LINUX_DEFAULT/' /etc/default/grub > /etc/default/grub.tmp && mv /etc/default/grub.tmp /etc/default/grub
    log_error_on_fail $? "failed to remove GRUB_CMDLINE_LINUX_DEFAULT from /etc/default/grub"
    awk '!/^GRUB_CMDLINE_LINUX=/' /etc/default/grub > /etc/default/grub.tmp && mv /etc/default/grub.tmp /etc/default/grub
    log_error_on_fail $? "failed to remove GRUB_CMDLINE_LINUX from /etc/default/grub"
    sed -i '/^GRUB_DISTRIBUTOR/a GRUB_CMDLINE_LINUX_DEFAULT="pci=conf1"' /etc/default/grub
    log_error_on_fail $? "failed to add GRUB_CMDLINE_LINUX_DEFAULT to /etc/default/grub"
    sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/a GRUB_CMDLINE_LINUX=""' /etc/default/grub
    log_error_on_fail $? "failed to add GRUB_CMDLINE_LINUX to /etc/default/grub"
    if [ $? != 0 ]; then
        log_error "failed to add GRUB_CMDLINE_LINUX_DEFAULT to /etc/default/grub"
    else
        MIN_GENERAL_CORES=2
        NO_CORES_PER_SOCKET=$(lscpu | grep "Core(s)" | rev |cut -d" " -f1 | rev)
        NO_SOCKETS=$(lscpu | grep "Socket(s)" | rev |cut -d" " -f1 | rev)
        MAX_ISOLATED_CORES_PER_SOCKET=10
        BASELINE_SOCKETS_PER_CORE=12
        MAX_CORE_ID=$(($NO_CORES_PER_SOCKET*$NO_SOCKETS -1))
        MIN_CORE_ID=0
        if [ $NO_CORES_PER_SOCKET -gt $BASELINE_SOCKETS_PER_CORE ]; then
            MAX_ISOLATED_CORE_ID=$(($MAX_ISOLATED_CORES_PER_SOCKET*$NO_SOCKETS -1))
        else
            MAX_ISOLATED_CORE_ID=$(($NO_CORES_PER_SOCKET*$NO_SOCKETS - $MIN_GENERAL_CORES*$NO_SOCKETS -1))
        fi
        NOHZ_CPU="nohz_full=$MIN_GENERAL_CORES-$MAX_CORE_ID"
        RCU_NOCBS="rcu_nocbs=$MIN_GENERAL_CORES-$MAX_CORE_ID"
        MEMTOTAL=$(cat /proc/meminfo | grep MemTotal | tr -d ' ' | cut -d: -f2 | tr -d 'kB')
        if [ $MEMTOTAL -lt $MEMMEDIUMMODEL ]; then
            sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"pci=conf1\"/GRUB_CMDLINE_LINUX_DEFAULT=\"pci=conf1 reboot=acpi nmi_watchdog=panic default_hugepagesz=2M hugepagesz=2M hugepages=1024 $NOHZ_CPU $RCU_NOCBS\"/" /etc/default/grub
            sed -i "s/^GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"default_hugepagesz=2M hugepagesz=2M hugepages=1024/" /etc/default/grub
        else
            sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"pci=conf1\"/GRUB_CMDLINE_LINUX_DEFAULT=\"pci=conf1 reboot=acpi nmi_watchdog=panic default_hugepagesz=1G hugepagesz=1G hugepages=8 $NOHZ_CPU $RCU_NOCBS\"/" /etc/default/grub
            sed -i "s/^GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"default_hugepagesz=1G hugepagesz=1G hugepages=8/" /etc/default/grub
        fi

        if [ $? != 0 ]; then
            log_error "Failed to set GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub"
        else
            update-grub
            log_error_on_fail $? "failed to updata grub pci conf"
        fi
    fi
    log_info_and_echo "configure grub - end"
}

function install_linux_utilities {
    log_info_and_echo "install linux utilities - start"
    aptget_and_log_fail liblog4cxx10-dev
    aptget_and_log_fail curl
    aptget_and_log_fail libcurl4-openssl-dev
    aptget_and_log_fail python-pip
    aptget_and_log_fail ethtool
    aptget_and_log_fail python-dev
    aptget_and_log_fail libpcap-dev
    aptget_and_log_fail vlan
    aptget_and_log_fail openssh-server
    aptget_and_log_fail python-simplejson
    aptget_and_log_fail whois
    aptget_and_log_fail gdb
    aptget_and_log_fail unzip
    aptget_and_log_fail biosdevname
    apt-get install -y --force-yes --only-upgrade bash
    log_error_on_fail $? "apt-get install of bash failed - failed to install shellshock patch"
    aptget_and_log_fail php5
    aptget_and_log_fail libbatik-java
    aptget_and_log_fail sipcalc
    #util-linux provides lscpu
    aptget_and_log_fail util-linux
    if [ -f /sys/hypervisor/uuid ] && [ `head -c 3 /sys/hypervisor/uuid` == ec2 ]; then
        aptget_and_log_fail linux-image-generic
        aptget_and_log_fail linux-generic
        aptget_and_log_fail linux-headers-generic
    fi
    aptget_and_log_fail isc-dhcp-server
    if [ ! -f /etc/dhcp/dhcpd-orig.conf ]; then
        cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd-orig.conf
    fi 
    service isc-dhcp-server stop
    log_info_and_echo "install linux utilities - end"
}

function install_python_utilities {
    log_info_and_echo "install python utilities - start"
    pip_and_log_fail "flask>=0.12.2"
    pip_and_log_fail netaddr
    pip_and_log_fail netifaces
    pip_and_log_fail tzlocal
    pip_and_log_fail python-dateutil
    ln -sf /opt/stm/target/python /usr/local/lib/python2.7/dist-packages/saisei 
    log_error_on_fail $? "failed to set cli softlink"
    aptget_and_log_fail python-subnettree
    aptget_and_log_fail python-pyrad
    /usr/bin/yes | pip uninstall exabgp 1> /dev/null
    pip_and_log_fail 'exabgp<4.0.0'
    pip_and_log_fail jose
    log_info_and_echo "install python utilities - end"
}

function install_i_40e {
    log_info_and_echo "install i40e - start"
    if [ $I40E_VER != $I40E_REQUIRED_VER ]; then
        $(rm -rf /opt/i40e-1.2.48.2*)
        $(cp /opt/stm/target.alt/i40e-1.2.48.2.tar.gz /opt/.)
        cd /opt
        tar xzvf /opt/i40e-1.2.48.2.tar.gz
        cd /opt/i40e-1.2.48.2/src
        make install
        log_error_on_fail $? "failed to make i40e driver for Intel i710 NIC"
    fi
    log_info_and_echo "install i40e - end"
}

function final_install_copy {
    log_info_and_echo "final install copy - start"
    if [ ! -d $BOOTTARGETDIR ];
    then
        mkdir /etc/stmboottarget
        log_error_on_fail $? "failed to create boot target dir"
        touch /etc/stmboottarget/ALT
        log_error_on_fail $? "failed to mark alternate boot target"
        cp -dprf /opt/stm/target.alt /opt/stm/target
        log_error_on_fail $? "failed to copy alt target to main"
    else
        if [ ! /etc/stm/boottarget/ALT ];
        then
            BOOTALT=1
            log_info_and_echo "=========================================================================================="
            log_info_and_echo "STM image installed as alternate. To boot  this image configure boot image to be alternate"
            log_info_and_echo "=========================================================================================="
        fi
    fi
    log_info_and_echo "final install copy - end"
}

######################################################
# Main Installation Body
######################################################
log_info_and_echo "Start setup"
setup_navl
install_boost
install_linux_utilities
install_apache_first_step
install_snmp_first_step
install_ntp
configure_ssh
if [ ! -d /var/lib/mysql/history ]; then
    install_mysql
fi
install_report_writer
install_python_utilities
setup_stm_file_system_first_step
install_apache_second_step
disable_apport
install_snmp_second_step 
install_mibs
setup_init_dot_d
configure_linux
setup_stm_file_system_second_step
if [ ! -f /.dockerinit ]; then 
    install_i_40e
    configure_grub
fi
final_install_copy

# Errors in log are of the form "2016-09-30T21:39:13-0700 ERROR ..."
FAILCOUNTER=$(egrep "^[^ ]+ +ERROR " -c $LOG_FILE)
if [ $FAILCOUNTER = 0 ]; then
    log_info_and_echo "========================================"
    log_info_and_echo "STM Installation completed  successfully"
    log_info_and_echo "========================================"
    if [ $BOOTALT != 0 ]; then
        log_info_and_echo "=========================================================================================="
        log_info_and_echo "STM image installed as alternate. To boot  this image configure boot image to be alternate"
        log_info_and_echo "=========================================================================================="
    fi
    VER=$(lsb_release -r | rev | cut -d: -f1 | cut -c1-5 | rev)
    if [ "${VERREQUIRED/$VER}" = "$VERREQUIRED" ] ; then
        VERWARNING="$(printf "This system has an unsupported version (%s) of Ubuntu" "$VER")"
        log_info_and_echo $VERWARNING
        log_info_and_echo "Supported Versions"
        log_info_and_echo "==========================="
        log_info_and_echo "Ubuntu 14.04 64 bit Server"
    fi
    MEMTOTAL=$(cat /proc/meminfo | grep MemTotal | tr -d ' ' | cut -d: -f2 | tr -d 'kB')
    if [ $MEMTOTAL -lt $MEMREQUIRED ]; then
        MEMWARNING=$(printf "The total available memory size on this system is %s. That is less then the required %s" "$MEMTOTAL", "$MEMREQUIRED")
        log_info_and_echo $MEMWARNING
    fi
    DISK_TOTAL=$(df -k | fgrep -m 1  / | sed 's/  */\;/g' | cut -d";" -f2)
    if [ $DISK_TOTAL -lt $DISK_MIN ]; then
        DISKWARNING=$(printf "The total disk size on this system is %s. That is less then the required %skB" "$DISK_TOTAL", "$DISK_MIN")
        log_info_and_echo $DISKWARNING
    fi
    X8664FLAG=$(uname -m)
    if [ $X8664FLAG != "x86_64" ]; then
        BITSWARNING=$(printf "The STM requires a 64 bit OS. This is %s which is a 32 bit OS" "$X8664FLAG")
        log_info_and_echo $BITSWARNING
    fi
else
    # display the logged errors
    egrep "^[^ ]+ ERROR " $LOG_FILE
    log_error_and_echo "====================================================================="
    log_error_and_echo "STM Installation failed, $FAILCOUNTER errors."
    log_error_and_echo "Make sure you are running as root and check you internet connection."
    log_error_and_echo "====================================================================="
fi

