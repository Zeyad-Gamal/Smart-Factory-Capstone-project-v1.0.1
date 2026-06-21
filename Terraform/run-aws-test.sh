#!/bin/bash
set -e

PROJECT_DIR="$HOME/finalpr/final-project"
TF_DIR="$PROJECT_DIR/infra/terraform/environments/dev"
NAMESPACE="scada-dev"
CLUSTER_NAME="soc-scada-dev-eks"
REGION="us-east-1"

echo "======================================"
echo " START SOC SCADA AWS TEST"
echo "======================================"

echo "0) Get current public IP and update terraform.tfvars"

CURRENT_IP=$(curl -s ifconfig.me)

if [ -z "$CURRENT_IP" ]; then
  echo "ERROR: Could not detect public IP"
  exit 1
fi

echo "Current Public IP: $CURRENT_IP"

cd "$TF_DIR"

if grep -q '^allowed_admin_cidr' terraform.tfvars; then
  sed -i "s|^allowed_admin_cidr.*|allowed_admin_cidr = \"$CURRENT_IP/32\"|" terraform.tfvars
else
  echo "allowed_admin_cidr = \"$CURRENT_IP/32\"" >> terraform.tfvars
fi

echo "allowed_admin_cidr updated to $CURRENT_IP/32"

echo "1) Terraform init"
terraform init

echo "2) Apply core infrastructure: VPC, Security Groups, EC2, EKS"
terraform apply -auto-approve \
  -target=module.vpc \
  -target=module.security_groups \
  -target=module.ec2_management \
  -target=module.eks

echo "3) Update kubeconfig"
aws eks update-kubeconfig \
  --region "$REGION" \
  --name "$CLUSTER_NAME"

echo "4) Wait for EKS cluster ACTIVE"

for i in {1..60}; do
  STATUS=$(aws eks describe-cluster \
    --region "$REGION" \
    --name "$CLUSTER_NAME" \
    --query "cluster.status" \
    --output text 2>/dev/null || true)

  echo "EKS status: $STATUS"

  if [ "$STATUS" = "ACTIVE" ]; then
    break
  fi

  sleep 20
done

echo "5) Wait for EKS API to be reachable"

for i in {1..60}; do
  if kubectl get nodes >/dev/null 2>&1; then
    echo "EKS API is reachable"
    break
  fi

  echo "Waiting for EKS API... attempt $i"
  sleep 20
done

if ! kubectl get nodes >/dev/null 2>&1; then
  echo "ERROR: EKS API is still not reachable"
  echo "Check allowed_admin_cidr and cluster endpoint access"
  exit 1
fi

echo "6) Wait for nodes Ready"
kubectl wait --for=condition=Ready nodes --all --timeout=15m
kubectl get nodes

echo "7) Apply addons: EBS CSI, Metrics Server, NGINX Ingress"
cd "$TF_DIR"
terraform apply -auto-approve

echo "8) Wait for ingress-nginx controller"

for i in {1..60}; do
  if kubectl get pod -n ingress-nginx -l app.kubernetes.io/component=controller >/dev/null 2>&1; then
    break
  fi

  echo "Waiting for ingress-nginx namespace/pods... attempt $i"
  sleep 10
done

kubectl wait \
  --namespace ingress-nginx \
  --for=condition=Ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=10m

echo "9) Get LoadBalancer DNS"

LB_DNS=""

for i in {1..60}; do
  LB_DNS=$(kubectl get svc ingress-nginx-controller \
    -n ingress-nginx \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)

  if [ -n "$LB_DNS" ]; then
    break
  fi

  echo "Waiting for LoadBalancer DNS... attempt $i"
  sleep 10
done

if [ -z "$LB_DNS" ]; then
  echo "ERROR: LoadBalancer DNS not found"
  exit 1
fi

echo "LoadBalancer DNS: $LB_DNS"

echo "10) Deploy SCADA app"
cd "$PROJECT_DIR"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install scada ./scada-helm \
  -n "$NAMESPACE" \
  -f scada-helm/values-dev.yaml \
  --set ingress.host="$LB_DNS" \
  --timeout 10m

echo "11) Wait for SCADA pods"

kubectl wait --for=condition=Ready pod -l app=backend -n "$NAMESPACE" --timeout=10m
kubectl wait --for=condition=Ready pod -l app=frontend -n "$NAMESPACE" --timeout=10m
kubectl wait --for=condition=Ready pod -l app=mysql -n "$NAMESPACE" --timeout=10m || true

echo "12) Show status"
kubectl get pods -n "$NAMESPACE"
kubectl get pvc -n "$NAMESPACE"
kubectl get ingress -n "$NAMESPACE"
kubectl get hpa -n "$NAMESPACE"

echo "13) Test API"

for i in {1..30}; do
  if curl -s -o /tmp/scada-api-test.txt -w "%{http_code}" "http://$LB_DNS/api/machines" | grep -q "200"; then
    echo "API is working"
    cat /tmp/scada-api-test.txt
    break
  fi

  echo "Waiting for API... attempt $i"
  sleep 10
done

echo ""
echo "14) Test Frontend"
curl -I "http://$LB_DNS/"

echo ""
echo "======================================"
echo " SOC SCADA AWS TEST READY"
echo "======================================"
echo "Frontend: http://$LB_DNS/"
echo "API:      http://$LB_DNS/api/machines"
echo ""
echo "IMPORTANT: AWS resources are running."
echo "Run ./stop-aws-test.sh when finished."