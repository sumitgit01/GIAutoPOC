#!/bin/bash
#to automate gold image
#prerequsites: AWS CLI tool should be installed
a=$(aws ec2 create-image --instance-id i-0215cc43763785888 --name "EC2-ASP-time" --no-reboot --output json 2>&1)
echo "value of a is" $a
if [[ $a == *"InvalidAMIName.Duplicate"* ]]; then
    echo "inside if"
    image_id=$(awk -F 'ami-' '{print $2}' <<< $a)
    echo "image id is" $image_id
    aws ec2 deregister-image --image-id "ami-$image_id" --output json 
    b=$(aws ec2 create-image --instance-id i-0215cc43763785888 --name "EC2-ASP-time" --no-reboot --output json | jq -r .ImageId)
    sed -i -e "s#%AMI_ID%#$b#g" auto-scale.yaml
else
c=$(echo $a | jq -r .ImageId)
sed -i -e "s#%AMI_ID%#$c#g" auto-scale.yaml
fi

aws cloudformation deploy --template-file auto-scale.yaml --stack-name velo-asg
