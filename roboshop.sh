#!/bin/bash


AMIID="ami-09c813fb71547fc4f"
SG_ID="sg-0efb46bbc7c5d112f"
ZONE_ID="Z02155239UQ5JEVY7T4S"
DOMAIN_NAME="vamsimln.online"

for instance in $@
do
    InstanceID=$(aws ec2 run-instances --image-id $AMIID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
   
    if [ $instance != 'frontend' ]; then
        IP=$(aws ec2 describe-instances --instance-ids $InstanceID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"

    else
        IP=$(aws ec2 describe-instances --instance-ids $InstanceID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi

    echo "$instance: $IP"

     aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '
        {
            "Comment": "Upsert"
            ,"Changes": [{
            "Action"              : "CREATE"
            ,"ResourceRecordSet"  : {
                "Name"              : "'$RECORD_NAME'"
                ,"Type"             : "A"
                ,"TTL"              : 1
                ,"ResourceRecords"  : [{
                    "Value"         : "'" $IP "'"
                }]
            }
            }]
        }
        '
done 
