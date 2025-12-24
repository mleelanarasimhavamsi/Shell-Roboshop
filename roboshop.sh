#!/bin/bash


AMIID="09c813fb71547fc4f"
SG_ID="sg-0efb46bbc7c5d112f"

for instance in $@
do
    InstanceID=$(aws ec2 run-instances --image-id $AMIID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query "Instances[0].InstanceId" --output text)
   
    if [ $instance != 'frontend'; then]
        aws ec2 describe-instances --instance-ids YOUR_INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text
    else
        aws ec2 describe-instances --instance-ids YOUR_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text
done 
