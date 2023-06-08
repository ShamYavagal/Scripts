#!/bin/bash

echo -e "\nNOTE: This script for now only works if you have AWS_PROFILE configured under your ~/.aws/credentials file\n THIS SCRIPT ONLY WORKS ON MAC WITH BASH VERSION 5.+"
echo -e "To install session-manager-plugi on mac run [brew install session-manager-plugi]"

if [ $# != 2 ]; then
  echo "USAGE: ./<script> <AWS_PROFILE> <REGION>"
  exit 0
fi

grep "\[${1}\]" ~/.aws/credentials  >/dev/null 2>&1 && profile_status="$?" || profile_status="$?"

if [[ "${profile_status}" != 0 ]]; then
    echo -e "The profile name you provided does not match with any value within your aws credentials file..Exiting!\n"
    exit 1
fi

command -v session-manager-plugin >/dev/null 2>&1 && install_status="$?" || install_status="$?"

if [[ "${install_status}" = 0 ]]; then
    echo -e "\nAWS session-manager-plugin found on your machine"
else
    echo "Looks like AWS session-manager-plugin has not been installed on your machine, this script will not work without the same!..Exiting!"
    exit 1
fi


clusters=$(aws --profile $1 ecs list-clusters --region $2 --query "clusterArns" --output text)

if [[ -z $clusters ]]; then
  echo "No ECS Clusters found."
  exit 1
fi

declare -A cluster_object

echo -e "\nAvailable ECS clusters:"
count=1
for cluster in $clusters; do
  echo $count. $(echo $cluster | awk -F '/' '{print $2}')
  cluster_object[$count]=$(echo $cluster | awk -F '/' '{print $2}')
  ((count++))
done

echo -e "\nEnter the number of the ECS Cluster you want to access:"
read ecs_cluster

if ! [[ $ecs_cluster =~ ^[0-9]+$ ]] || [[ $ecs_cluster -lt 1 || $ecs_cluster -gt $count ]]; then
  echo "Invalid selection."
  exit 1
fi

cluster_name=${cluster_object[$ecs_cluster]}

#echo $cluster_name

services=$(aws --profile $1 --region $2 ecs list-services --cluster $cluster_name --query "serviceArns[]" --output text)

if [[ -z $services ]]; then
  echo "No ECS services found."
  exit 1
fi

declare -A service_object

echo -e "\nAvailable ECS services:"
count=1
for service in $services; do
  echo $count. $(echo $service | awk -F '/' '{print $NF}')
  #echo $count. $service
  service_object[$count]=$service
  ((count++))
done

echo -e "\nEnter the number of the service you want to access:"
read selection

if ! [[ $selection =~ ^[0-9]+$ ]] || [[ $selection -lt 1 || $selection -gt $count ]]; then
  echo "Invalid selection."
  exit 1
fi

service_arn=${service_object[$selection]}

#echo $service_arn

#tasks=$(aws --profile $1 --region $2 ecs list-tasks --cluster $cluster_name --service-name "$service_arn" --query "taskArns[]" --output json)
tasks=$(aws --profile $1 --region $2 ecs list-tasks --cluster $cluster_name --service-name "$service_arn" --query "taskArns[]" --output text)

if [[ -z $tasks ]]; then
  echo "No tasks found for the selected service."
  exit 1
fi

#echo $tasks

#task_arn=$(echo $tasks | jq .[0] | tr -d \")
task_arn=$(echo $tasks | awk '{print $1}') 

#echo $task_arn

task=$(echo $task_arn | awk -F '/' '{print $3}')

#echo $task

container_instance_arn=$(aws --profile $1 --region $2 ecs describe-tasks --cluster $cluster_name --tasks $task_arn --query "tasks[0].containerInstanceArn" --output text)

#container_name=$(aws --profile $1 --region $2 ecs describe-tasks --cluster $cluster_name --tasks "$task_arn" --query "tasks[0].containers[0].name" --output text)

container_list=$(aws --profile $1 --region $2 ecs describe-tasks --cluster $cluster_name --tasks "$task_arn" --query "tasks[].containers[].name" --output text)

declare -A container_object

echo -e "\nAvailable Containers:"
count=1
for container_name in $container_list; do
  echo $count. $container_name
  container_object[$count]=$container_name
  ((count++))
done

echo -e "\nEnter the number of the continer you want to access:"
read containerName

if ! [[ $containerName =~ ^[0-9]+$ ]] || [[ $containerName -lt 1 || $containerName -gt $count ]]; then
  echo "Invalid selection."
  exit 1
fi

container_name=${container_object[$containerName]}

#echo $container_name

aws --profile $1 ecs execute-command --region $2 --cluster $cluster_name --task $task --container $container_name --command "/bin/sh" --interactive

#container_instance_id=$(aws --profile $1 --region $2 ecs describe-container-instances --cluster $cluster_name  --container-instances "$container_instance_arn" --query "containerInstances[0].ec2InstanceId" --output text)

#echo $container_instance_id

#aws --profile $1 --region $2 ecs execute-command --cluster $cluster_name --task "$task_arn" --container "$container_name" --command "/bin/sh" --interactive --tty --instance "$container_instance_id" --region us-east-1 --container-instance "$container_instance_arn"
