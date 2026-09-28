#!/bin/bash
##################################################################################################################################################
# Validation Section for the Docker script
##################################################################################################################################################
DOCKER="/usr/bin/docker"
DRYRUN=0

###### Validation Step ######
while [[ "$#" -gt 0 ]]; 
do
	flag=$1
	case $flag in
		--dry-run | -dry-run)
			DRYRUN=1
			;;
		-h | --h )
			echo "$0 --dry-run #It will be running in the dry mode"
			echo "$0 # Run in the Prod Mode"
			exit 0
			;;
		* )
		   	;;
	esac
	shift
done

##################################################################################################################################################
# Checking all the images which doesn't have proper ID in it.
##################################################################################################################################################
noneimages=$($DOCKER images -f "reference=*:latest" -q)  #$($DOCKER images | grep -w "<none>" | awk '{print $2}')
if [[ "${noneimages}" != "" ]]; then
	for dockerimage in ${noneimages}
	do
		echo ${dockerimage}
		if [[ $DRYRUN -eq 0 ]]; then
			${DOCKER} rmi -f ${dockerimage}
			if [[ $? -eq 0 ]]; then
				echo -e "\n Docker Images with the ImageID:- ${dockerimage} is deleted successfully"
			else
				echo -e "\n !! Error while deleting the docker image with ImageID ${dockerimage}"
			fi
		fi
	done
else
	echo -e "\n == No docker Images to be deleted"
fi

##################################################################################################################################################
# Checking all the stopped containers and removing it
##################################################################################################################################################
stopped_containers=$($DOCKER ps -a | grep -w "Exited" | awk '{print $1}')
if [[ ${stopped_containers} != "" ]]; then
	for containers in $stopped_containers
	do
		echo ${containers}
		if [[ $DRYRUN -eq 0 ]]; then
			${DOCKER} rm -f ${containers}
			if [[ $? -eq 0 ]]; then
				echo "The Stopped container with this Container ID:- ${stopped_containers} is deleted from your ubuntu system"
			else
				echo "There is no stopped container in your ubuntu system"
			fi
		fi
	done
else
	echo "There is nothing to remove from your system"
fi















