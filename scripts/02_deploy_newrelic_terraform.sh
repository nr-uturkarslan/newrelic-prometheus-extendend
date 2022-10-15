#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --destroy)
      flagDestroy="true"
      shift
      ;;
    --dry-run)
      flagDryRun="true"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

### Set variables

# Cluster name
clusterName="mydopecluster"

if [[ $flagDestroy != "true" ]]; then

  # Initialise Terraform
  terraform -chdir=../newrelic/terraform init

  # Plan Terraform
  terraform -chdir=../newrelic/terraform plan \
    -var NEW_RELIC_ACCOUNT_ID=$NEWRELIC_ACCOUNT_ID \
    -var NEW_RELIC_API_KEY=$NEWRELIC_API_KEY \
    -var NEW_RELIC_REGION="eu" \
    -var prometheus_server_name=$clusterName \
    -out "./tfplan"

  # Apply Terraform
  if [[ $flagDryRun != "true" ]]; then
    terraform -chdir=../newrelic/terraform apply tfplan
  fi
else

  # Destroy Terraform
  terraform -chdir=../newrelic/terraform destroy \
  -var NEW_RELIC_ACCOUNT_ID=$NEWRELIC_ACCOUNT_ID \
  -var NEW_RELIC_API_KEY=$NEWRELIC_API_KEY \
  -var NEW_RELIC_REGION="eu" \
  -var prometheus_server_name=$clusterName
fi
