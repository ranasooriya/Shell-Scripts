#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo -n "Enter Folder Create Location: "
read FLOCATION

echo -n "Enter Folder name need to create: "
read FNAME

echo -n "$FLOCATION/$FNAME" "Is this path correct (Y/N): "
read ANSWER

if [ "$ANSWER" = "Y" ];then
	if [ -d $FLOCATION ];then
		echo -n "Give subfolders need to be created separate by (,) eg: bin,conf,lib"
		read SFNAMES
		if [ "$SFNAMES" = "" ];then
			mkdir -p $FLOCATION/$FNAME
		else
			mkdir -p $FLOCATION/$FNAME/{$SFNAMES}
		fi
		
		echo -n "Are you need to change folder permmision: (Y/N)"
		read CONFIRM
		if [ "CONFIRM" = "Y" ];then
			echo -n "Enter username for folder permmision: "
			read USER
			echo -n "Enter groupname for folder permmision: "
			read GROUP
			if id -u $USER >/dev/null 2>&1;then
				if [ -d $FLOCATION/$FNAME ];then
					cd $FLOCATION
					chown -R $USER:$GROUP $FNAME
					echo "Folder Creation Successfull with new premmision on $date"
				else
					echo "Folder is not Exsist : $FLOCATION/$FNAME"
					exit 1
				fi
			else
				echo "User dose not exist!"
				echo "################################################################"
				echo "#############                                 ##################"
				echo "############# Folder Permmition change FAILED ##################"
				echo "#############                                 ##################"
				echo "################################################################"
				exit 1
			fi			
		else
			echo "Folder Creation Successfull on $date"
		fi
	else
		echo "Folder is not Exsist : $FLOCATION"
		exit 1
	fi
else
	echo -n "Do you need to modify PATH: (Y/N)"
	read ANSWER
	
	if [ "$ANSWER" = "Y" ];then
		echo -n "Enter Folder Create Location: "
		read FLOCATION
		
		echo -n "$FLOCATION" "Is this path correct (Y/N): "
		read ANSWER
		
		if [ "$ANSWER" = "Y" ];then
			if [ -d $FLOCATION ];then
				echo -n "Give subfolders need to be created separate by (,) eg: bin,conf,lib"
				read SFNAMES
				
				if [ "$SFNAMES" = "" ];then
					mkdir -p $FLOCATION/$FNAME
				else
					mkdir -p $FLOCATION/$FNAME/{$SFNAMES}
				fi
				
				echo -n "Are you need to change folder permmision: (Y/N)"
				read CONFIRM
				if [ "CONFIRM" = "Y" ];then
					echo -n "Enter username for folder permmision: "
					read USER
					echo -n "Enter groupname for folder permmision: "
					read GROUP
					if id -u $USER >/dev/null 2>&1;then
						if [ -d $FLOCATION/$FNAME ];then
							cd $FLOCATION
							chown -R $USER:$GROUP $FNAME
							echo "Folder Creation Successfull with new premmision on $date"
						else
							echo "Folder is not Exsist : $FLOCATION/$FNAME"
							exit 1
						fi
					else
						echo "User dose not exist!"
						echo "################################################################"
						echo "#############                                 ##################"
						echo "############# Folder Permmition change FAILED ##################"
						echo "#############                                 ##################"
						echo "################################################################"
						exit 1
					fi			
				else
					echo "Folder Creation Successfull on $date"
				fi
			else
				echo "Folder is not Exsist : $FLOCATION"
				exit 1
			fi
		else
			exit 1
		fi
	else
		echo "Folder creation aborted"
	fi
fi
