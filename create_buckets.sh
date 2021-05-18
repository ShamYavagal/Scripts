#!/bin/bash  

###

if [ "$#" -ne 3 ]; then
    echo "USAGE: <script_name> <'environment' ex: dev,stage,uat,prod, prod-dr>, <'aws region name' ex: us-east1, eu-west1 etc for example> <your aws profile name>"
    exit 1
fi
  
bucket_list=("bucket1" "bucket2" "bucket3" "bucket4" "bucket5") # Bucket Names you would like to create

for each in "${bucket_list[@]}"; 
  do

  if [ "$2" == "eu-west-1" ]; 
    then
      cmd="aws --profile $3 s3api create-bucket --bucket ads-$1-$each --region $2 --create-bucket-configuration LocationConstraint=eu-west-1"
      $cmd

  else
      cmd="aws --profile $3 s3api create-bucket --bucket ads-$1-$each --region $2"
      $cmd

  fi

    if [ "$?" -ne 0 ]
      then  
        echo "-----------------------CREATION FAILED----------------------------------"
        echo ads-$1-$each
        echo "------------------------------------------------------------------------"
    fi

    aws --profile $3 s3api put-bucket-encryption --bucket ads-$1-$each --server-side-encryption-configuration \
'{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}' 
    aws --profile $3 s3api put-bucket-logging --bucket ads-$1-$each --bucket-logging-status \
'{"LoggingEnabled": {"TargetBucket": "'"ads-$1-log-bucket"'","TargetPrefix": "'"ads-$1-$each-bucket-logs"'","TargetGrants": [{"Grantee": {"Type": "AmazonCustomerByEmail","EmailAddress": "sniopsaws@cbs.com"},"Permission": "FULL_CONTROL"}]}}'
  done

backup_bucket_list=("prores-backup" "hdpmezz-backup" "promos-backup" "hdpps-backup" "backup-log-bucket")

if [ "$3" == "$2" ]; then
  for each in "${backup_bucket_list[@]}"; 
    do 
          aws --profile $3 s3api create-bucket --bucket ads-$1-$each --region $region --create-bucket-configuration LocationConstraint=eu-west-1
          aws --profile $3 s3api put-bucket-encryption --bucket ads-$1-$each --server-side-encryption-configuration \
'{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
          aws --profile $3 s3api put-bucket-acl --bucket ads-$1-backup-log-bucket --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery
          aws --profile $3 s3api put-bucket-logging --bucket ads-$1-$each --bucket-logging-status \
'{"LoggingEnabled": {"TargetBucket": "'"ads-$1-backup-log-bucket"'","TargetPrefix": "'"ads-$1-$each-bucket-logs"'","TargetGrants": [{"Grantee": {"Type": "AmazonCustomerByEmail","EmailAddress": "sniopsaws@cbs.com"},"Permission": "FULL_CONTROL"}]}}'
  done
fi