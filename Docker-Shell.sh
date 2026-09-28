#!/bin/bash
##################################################################################################################################################
echo "Validation Section for the Docker script"
##################################################################################################################################################
DOCKER="/usr/bin/docker"
DRYRUN=0

###### Validation Step ######
while [[ "$#" -gt 0 ]]; 
do
	first_arguement=$1
	if [[ ${first_arguement} == "--h" || ${first_arguement} == "-h" ]]; then
		echo "$0 --dry-run #It will be running in the dry mode only"
		echo "$0 # It will be running in the execution mode only"
	elif [[ ${first_arguement} == "--dry-run" || ${first_arguement} == "-dry-run" ]]; then
		DRYRUN=1
	else
		echo "Invalid option is selected and hence script will not be executed"
		exit 1
	fi
	shift
done

##################################################################################################################################################
echo "Checking all the images which doesn't have proper ID in it"
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
echo "Checking all the stopped containers and removing it"
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

##################################################################################################################################################
echo "Checking and deleting all the docker images which are older than 2 months should be deleted"
##################################################################################################################################################
old_images=$($DOCKER images --format "{{.ID}} {{.CreatedSince}}" | grep -E "([5-9]|[1-9][0-9]) weeks|months|years" | awk '{print $1}')
if [[ ${old_images} != '' ]]; then
	for images in ${old_images}
	do
		echo $images
		if [[ $DRYRUN -eq 0 ]]; then
			$DOCKER rmi -f $old_images
			if [[ $? -eq 0 ]]; then
				echo "The image is deleted successfully"
			else
				echo "The image was not deleted due to the error"
			fi
		fi
	done
else
	echo "====No older image is found"
fi

##################################################################################################################################################
echo "Checking and deleting the dangling images"
##################################################################################################################################################
dangalingImages=$($DOCKER images -qf dangling=true)
if [ "$dangalingImages" != "" ]; then
        for dImages in ${dangalingImages}
        do
               echo $dImages
                if [ $DRYRUN -eq 0 ]; then
                   ${DOCKER} rmi -f ${dImages} 
                    if [ $? -eq 0 ]; then
                        echo "\n -  Docker image with ImageId: ${dImages} Delted Successfully \n" 
                    else
                        echo "\n !! Error while deleting Docker image with ImageId: ${dImages} !! \n" 
                     fi
                fi
        done
else
        echo  "\n == No Docker dangaling Images to delete == \n"
fi

##################################################################################################################################################
echo "Checking and deleting the dangling volumes in the ubuntu system"
##################################################################################################################################################
dangling_volumes=$($DOCKER volume ls -qf dangling=true)
if [[ ${dangling_volumes} != "" ]]; then
	for i in $dangling_volumes
	do
		echo ${i}
		if [[ $DRYRUN -eq 0 ]]; then
			$DOCKER volume rm ${i}
			if [[ $? -eq 0 ]]; then
				echo "The Dangling Volume ${i} is deleted"
			else
				echo "The Dangling Volume cannot be deleted ${i}"
			fi
		fi
	done
else
	echo "=====No dangling volumes found"
fi