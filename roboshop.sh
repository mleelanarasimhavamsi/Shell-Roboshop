#!/bin/bash


AMIID="ami-09c813fb71547fc4f"
SG_ID="sg-0efb46bbc7c5d112f"

for instance in $@
do
    InstanceID=$(aws ec2 run-instances --image-id $AMIID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
   
    if [ $instance != 'frontend' ]; then
        IP=$(aws ec2 describe-instances --instance-ids $InstanceID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $InstanceID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi

    echo "$instance: $IP"
done 
