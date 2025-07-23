#!/bin/bash

NAMESPACE="etcd-stress"
COUNT=100000
SLEEP_INTERVAL=1

# Create namespace if it doesn't exist
kubectl get ns $NAMESPACE >/dev/null 2>&1 || kubectl create ns $NAMESPACE

echo "Creating $COUNT secrets in namespace $NAMESPACE..."

# Create secrets
for i in $(seq 1 $COUNT); do
  SECRET_NAME="stress-secret-$i"
  echo -n "data-$i" | base64 > /tmp/data.txt

  kubectl create secret generic $SECRET_NAME \
    --from-literal=data="initial-value-$i" \
    -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

  if (( $i % 1000 == 0 )); then
    echo "$i secrets created..."
  fi
done

echo "Initial secret creation complete."

