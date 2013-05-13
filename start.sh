#!/bin/sh

lynis=lynis-1.3.0/
checksec=checksec/
upc=unix-privesc-check-read-only/
name_folder=AUDIT-LINUX

# usage()
# {
# 	echo "usage"
# }

# read -p "Do you wanna run the wizzard [y/N] ?  : " wizzard
# if test $wizzard = 'y'
# then
# 	read -p "Remote[R] or Localy[L] ? " answer
# 	if test $answer = 'R'
# 	then
# 		echo "[*] Remote"
# 		read -p "- Host/IP : " host
# 		read -p "- User : " user
# 		read -p "- Port : " port
# 		read -p "- Upload Folder : " folder
		
# 		if test "$folder" = ""
# 		then
# 			read -p "[*] Wanna find a folder where you have write permission ? [Y/N]: " folder_search
# 			if test "$folder_search" != "Y"
# 			then
# 				echo "Provide a folder then..."
# 			fi
# 		else
# 			#scp -P "$port" -r ../"$name_folder" "$user"@"$host":"$folder" || { echo 'scp failed' ; exit 1; }
# 			ssh -p "$port" "$user"@"$host" gogo || { echo "ssh failed" ; exit 2; }
# 		fi
# 	elif test $answer = 'L'
# 	then
# 		echo "Local" 
# 	else
# 		usage
# 	fi
# else
# 	echo "Launch the script"
# fi

# gogo()
# {
# cd $folder

cd output
if [ -d "$(hostname)" ]; then
	read -p "The directory "$(hostname)" already exists. Wanna erase it ? [y/N] ?  : " wizzard
	if test $wizzard = 'y'; then
		rm -r $(hostname)
	else
		name=$(stat -c %y $(hostname) | cut -d '.' -f1 | tr -s ' ' '_')
		mv $(hostname) $(hostname)"_"$name 
		echo "- The directory has been renamed with the following : "$(hostname)"_"$name		
	fi
fi
mkdir $(hostname)
cd $(hostname)
mkdir lynis
mkdir upc
mkdir checksec
mkdir system-info
cd ../..

echo "[*] Lynis"
echo "- Follow the advancement : tail -f output/"$(hostname)"/lynis/resultat-lynis-"$(hostname)".txt"
cd $lynis
sh lynis -c -Q --reverse-colors > ../output/$(hostname)/lynis/resultat-lynis-$(hostname).txt
cat /var/log/lynis-report.dat | grep warning | sed --e 's/warning\[\]\=//g' > ../output/$(hostname)/lynis/resultat-lynis-$(hostname)-warning.txt
cat /var/log/lynis-report.dat | grep suggestion | sed --e 's/suggestion\[\]\=//g' > ../output/$(hostname)/lynis/resultat-lynis-$(hostname)-suggestion.txt
cat /var/log/lynis-report.dat | grep installed_package | sed --e 's/installed_package\[\]\=//g' > ../output/$(hostname)/lynis/resultat-lynis-$(hostname)-installed_package.txt
cat /var/log/lynis-report.dat | grep available_shell | sed --e 's/available_shell\[\]\=//g' > ../output/$(hostname)/lynis/resultat-lynis-$(hostname)-available_shell.txt
mv /var/log/lynis-report.dat ../output/$(hostname)/lynis/resultat-lynis-$(hostname)-report.dat
mv /var/log/lynis.log ../output/$(hostname)/lynis/resultat-lynis-$(hostname)-all_test.log
cd ..
echo "[*] Lynis is done\n\n"

echo "[*] CheckSec"
cd $checksec
./checksec.sh --proc-all > ../output/$(hostname)/checksec/resultat-checksec-proc-all-$(hostname).txt
./checksec.sh --kernel > ../output/$(hostname)/checksec/resultat-checksec-kernel-$(hostname).txt
cd ..
echo "[*] CheckSec is done\n\n"

echo "[*] Upc"
echo "- Follow the advancement : tail -f output/"$(hostname)"/upc/resultat-upc-all-"$(hostname)".txt"
cd $upc
sh upc.sh --type all > ../output/$(hostname)/upc/resultat-upc-all-$(hostname).txt
cd ..
echo "[*] Upc is done\n\n"


##gather information
cd output
cd $(hostname)
cd system-info
#common info


mkdir common && cd common

uptime > uptime.txt
id -a > id.txt
uname -a > uname.txt
uname -mrs >> uname.txt
cat /etc/issue > issue.txt
cat /etc/*-release > release.txt
awk -F: '($3 == "0") {print}' /etc/passwd > super_user.txt
cat /etc/sudoers > sudoers.txt

cd ..


#important directories
mkdir important-directories && cd important-directories

ls -al ~ > ~.txt
ls -al /tmp > tmp.txt
ls -al /media/ > media.txt
ls -al /mnt/ > mnt.txt
ls -al /etc/ > etc.txt
ls -al /home/ > home.txt

cd ..


#proc/kernel information
mkdir proc-kernel-information && cd proc-kernel-information

cat /proc/version > proc-version.txt
cat /proc/cpuinfo > proc-cpuinfo.txt
cat /proc/meminfo > proc-meminfo.txt
cat /proc/partitions > proc-partitions.txt
cat /proc/swaps > proc-swaps.txt
cat /proc/devices > proc-devices.txt
cat /proc/mounts > proc-mounts.txt
find /proc/scsi/ -ls -type f -exec cat {} \; > proc-scsi.txt
find /proc/lvm/ -ls -type f -exec cat {} \; > proc-lvm.txt
lsmod > lsmod.txt
rpm -q kernel > rpm.txt
dmesg | grep -i Linux > dmesg.txt
ls /boot | grep vmlinuz- > boot.txt

cd ..

#environement variable information
mkdir environement-variable && cd environement-variable

cat /etc/profile > etc-profile.txt
cat /etc/bashrc > etc-bashrc.txt
cat ~/.bash_profile > bash_profile.txt
cat ~/.bashrc > bashrc.txt
cat ~/.bash_logout > bash_logout.txt
env > env.txt
set > set.txt

cd ..


#printer information
mkdir printer-information && cd printer-information

lpstat -a > lpstat.txt 

cd ..


 #package information
mkdir package-information && cd package-information

cat /etc/apt/sources.list > sources.list.txt
rpm -qa > rpm.txt
dpkg -l > dpkg.txt
ls -lrtd /*bin/* /*/*bin/* >> ls-lrtd.txt

cd ..


#partitions information
mkdir partitions-information && cd partitions-information

cat /etc/fstab > fstab.txt
fdisk -l > fdisk.txt
blkid > blkid.txt
df -h > df.txt

cd ..


#processus information
mkdir processus-information && cd processus-information

ps aux | sort > ps-aux.txt

cd ..


# configuration files information
mkdir etc && cd etc

cat /etc/inittab > inittab
cat /etc/passwd > passwd
cat /etc/group > group
cat /etc/hosts > hosts 
cat /etc/aliases > aliases
cat /etc/bootptab > bootptab
cat /etc/crontab > crontab
cat /etc/ethers > ethers
cat /etc/exports > exports
cat /etc/fdprm > fdprm
cat /etc/filesystems > filesystems
cat /etc/fstab > fstab
cat /etc/groups > groups
cat /etc/gshadow > gshadow
cat /etc/issue > issue
cat /etc/issue.net > issue.net
cat /etc/limits > limits
cat /etc/localtime > localtime
cat /etc/login.defs > login.defs
cat /etc/magic > magic
cat /etc/motd > motd
cat /etc/mtab > mtab
cat /etc/networks > networks
cat /etc/nologin > nologin
cat /etc/printcap > printcap
cat /etc/cshlogin > cshlogin
cat /etc/csh/cshrc > cshrc
cat /etc/protocols > protocols
cat /etc/securetty > securetty
cat /etc/services > services
cat /etc/shadow > shadow
cat /etc/shadow.group > shadow.group
cat /etc/shells > shells
cat /etc/skel/.profile > skel.profile
cat /etc/sudoers > sudoers
cat /etc/X11/XF86Config > XF86Config
cat /etc/termcap > termcap
cat /etc/terminfo > terminfo
cat /etc/usertty > usertty
cat /dev/MAKEDEV > MAKEDEV

mkdir sysconfig && cd sysconfig

cat /etc/sysconfig/amd > amd
cat /etc/sysconfig/clock > clock
cat /etc/sysconfig/i18n > i18n
cat /etc/sysconfig/init > init
cat /etc/sysconfig/keyboard > keyboard
cat /etc/sysconfig/mouse > mouse
cat /etc/sysconfig/network-scripts/ifcfg-interface > ifcfg-interface
cat /etc/sysconfig/pcmcia > pcmcia
cat /etc/sysconfig//routed > routed
cat /etc/sysconfig/static-routes > static-routes
cat /etc/sysconfig/tape > tape 

cd ..

# echo " FIND"
# res=$(find /etc/ -maxdepth 3 -type f -name *.conf)
# #echo $res > conf_file.txt
# print $res
# for i in $res; do 
# 	echo "ok"
# 	#dirname $i
# done


cd ..

#log information
mkdir log-information && cd log-information

ls -alrt /var/adm /var/log /var/log/syslog > syslog.txt
find /etc/logrotate.* -ls -type f -exec cat {} \; > logrotate.txt
dmesg > dmsg.txt

cd ..


#connexion information
mkdir connexion-information && cd connexion-information

who > who.txt
w > w.txt

cd ..


#reboot/boot information
mkdir boot_reboot-information && cd boot_reboot-information

last -100 > last.txt
find /etc/default -type f -ls -exec cat {} \; > default.txt

cd ..


#ip/services information
mkdir ip_services-information && cd ip_services-information

ifconfig -a > ifconfig.txt
cat /proc/net/vlan/config > vlanconfig.txt
netstat -i > netstat_i.txt
netstat -rn > netstat_rn.txt
netstat -anptev > netstat_anptev.txt
cat /etc/sysctl.conf > sysconf.conf
for i in `find /proc/sys/net -type f -perm -0400` ; do echo -n "$i " >> net.txt ; cat $i >> net.txt; done
tail -50 /etc/services > services.txt
chkconfig --list | grep 3:on > chkconfigboot.txt
find /etc/xinetd.* -ls -type f -exec cat {} \; >> xinetd.txt
find /etc/inetd.* -ls -type f -exec cat {} \; >> inetd.txt
ls -l /etc/hosts.allow && cat /etc/hosts.allow >> hosts.allow
ls -l /etc/hosts.deny && cat /etc/hosts.deny >> hosts.deny
ls -l /etc/hosts.equiv && cat /etc/hosts.equiv >> hosts.equiv
ls -l /etc/ftpusers && cat /etc/ftpusers >> ftpusers
find /etc/pam.* -ls -type f -exec cat {} \; >> pam.txt

cd ..


#network information
mkdir network && cd network

arp -e > arp.txt
route > route.txt
/sbin/route -nee > route_nee.txt
cat /etc/sysconfig/network > network.txt
cat /etc/networks > networks.txt
dnsdomainname > dnsdomainname.txt

cd ..


#rpc
mkdir rpc && cd rpc

cat /etc/exports > exports.txt
rpcinfo -p > rpcinfo.txt
showmount -e > showmount.txt
part=`grep -w ext3 /proc/mounts | awk '{print $2}'`
echo $part > mounts.txt
nice find $part -xdev -type f \( -perm -04000 -o -perm -02000 \) -exec ls -ld {} \; 2>/dev/null >> findins_rpc.txt

cd ..


# misc ( TO CUSTOMIZE...)
mkdir misc && cd misc

ls -alh /var/mail/ >> misc.txt
#seek for passwords
cat ~/.bash_history >> misc.txt
cat ~/.nano_history >> misc.txt
cat ~/.atftp_history >> misc.txt
cat ~/.mysql_history >> misc.txt
cat ~/.php_history >> misc.txt
cat /var/mail/root >> misc.txt
cat /var/spool/mail/root >> misc.txt
cat /var/apache2/config.inc >> misc.txt 
cat /var/lib/mysql/mysql/user.MYD >> misc.txt
cat /root/anaconda-ks.cfg >> misc.txt

#Any settings/files (hidden) on website Any settings file with database information?
ls -alhR /var/www/ >> misc.txt
ls -alhR /srv/www/htdocs/ >> misc.txt
ls -alhR /usr/local/www/apache22/data/ >> misc.txt
ls -alhR /opt/lampp/htdocs/ >> misc.txt
ls -alhR /var/www/html/ >> misc.txt

exit 0
