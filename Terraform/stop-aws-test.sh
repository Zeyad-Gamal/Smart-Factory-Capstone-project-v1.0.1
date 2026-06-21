#!/bin/bash
set -e

PROJECT_DIR="$HOME/finalpr/final-project"
TF_DIR="$PROJECT_DIR/infra/terraform/environments/dev"
NAMESPACE="scada-dev"
REGION="us-east-1"

echo "======================================"
echo " STOP SOC SCADA AWS TEST"
echo "======================================"

echo "1) Try to delete SCADA app if Kubernetes is reachable"

cd "$PROJECT_DIR"

if kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
  echo "Kubernetes reachable. Cleaning SCADA app..."

  helm uninstall scada -n "$NAMESPACE" --ignore-not-found || true
  kubectl delete pvc mysql-pvc -n "$NAMESPACE" --ignore-not-found || true
  kubectl delete namespace "$NAMESPACE" --ignore-not-found || true

  echo "Waiting for namespace deletion..."
  for i in {1..30}; do
    if ! kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
      echo "Namespace deleted"
      break
    fi

    echo "Namespace still deleting... attempt $i"
    sleep 10
  done
else
  echo "Kubernetes is not reachable. Skipping app cleanup."
fi

echo "2) Terraform destroy"

cd "$TF_DIR"

terraform destroy -auto-approve || {
  echo "First terraform destroy failed. Retrying in 60 seconds..."
  sleep 60
  terraform destroy -auto-approve
}

echo "3) Check Terraform state"
terraform state list || true

echo "4) Check remaining AWS resources"

echo "EKS clusters:"
aws eks list-clusters --region "$REGION"

echo "Running/Stopped EC2:"
aws ec2 describe-instances \
  --region "$REGION" \
  --filters Name=instance-state-name,Values=running,stopped \
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" \
  --output table

echo "EBS volumes:"
aws ec2 describe-volumes --region "$REGION" --output table

echo "Elastic IPs:"
aws ec2 describe-addresses --region "$REGION" --output table

echo "Load Balancers:"
aws elbv2 describe-load-balancers --region "$REGION"

echo "5) Release unattached Elastic IPs if any"

EIPS=$(aws ec2 describe-addresses \
  --region "$REGION" \
  --query "Addresses[?AssociationId==null].AllocationId" \
  --output text)

if [ -n "$EIPS" ]; then
  for EIP in $EIPS; do
    echo "Releasing EIP: $EIP"
    aws ec2 release-address \
      --region "$REGION" \
      --allocation-id "$EIP" || true
  done
else
  echo "No unattached EIPs found"
fi

echo "6) Final check"

aws ec2 describe-instances \
  --region "$REGION" \
  --filters Name=instance-state-name,Values=running,stopped \
  --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" \
  --output table

aws ec2 describe-volumes --region "$REGION" --output table
aws ec2 describe-addresses --region "$REGION" --output table
aws elbv2 describe-load-balancers --region "$REGION"
aws eks list-clusters --region "$REGION"

echo "======================================"
echo " SOC SCADA AWS TEST STOPPED"
echo "======================================"