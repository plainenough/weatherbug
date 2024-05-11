# weatherbug



## Pre-installation
- Create iam user 'devops' in aws account and generation access key and secret. 
- Create bucket for terraform files to be published. 
- Create keypair 'eks-custom-key' in the correct region.
- Initialize Dynodb 
    Example using AWS CLI:

    
```bash
    aws dynamodb create-table --table-name terraform-state-lock \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --billing-mode PAY_PER_REQUEST \
      --region us-east-2
```