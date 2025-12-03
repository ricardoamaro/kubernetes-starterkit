#!/bin/bash
set -e  # Exit on any error

echo "***********************************************************"
echo "Welcome to Calculator Service build and deploy scripting!"
echo "***********************************************************"

echo "*****************************************************"
echo "Starting Vuecalc service production build"
echo "*****************************************************"
cd vuecalc
sh build.sh || { echo "ERROR: Vuecalc build failed"; exit 1; }

echo "*****************************************************"
echo "Starting Expressed service production build"
echo "*****************************************************"
cd ../expressed
sh build.sh || { echo "ERROR: Expressed build failed"; exit 1; }

echo "*****************************************************"
echo "Starting Happy service production build"
echo "*****************************************************"
cd ../happy
sh build.sh || { echo "ERROR: Happy build failed"; exit 1; }

echo "*****************************************************"
echo "Starting Bootstorage service production build"
echo "*****************************************************"
cd ../bootstorage
sh build.sh || { echo "ERROR: Bootstorage build failed"; exit 1; }

echo "*****************************************************"
echo "Checking for k3d cluster and importing images"
echo "*****************************************************"
cd ..
if command -v k3d &> /dev/null; then
    CLUSTER_NAME=$(kubectl config current-context | sed 's/k3d-//')
    if [[ $CLUSTER_NAME == k3d-* ]] || k3d cluster list 2>/dev/null | grep -q "$CLUSTER_NAME"; then
        echo "Detected k3d cluster: $CLUSTER_NAME"
        echo "Importing Docker images into k3d cluster..."
        k3d image import expressed:latest happy:latest bootstorage:latest vuecalc:latest -c "$CLUSTER_NAME" || {
            echo "WARNING: Image import failed. Trying without cluster name..."
            k3d image import expressed:latest happy:latest bootstorage:latest vuecalc:latest || {
                echo "WARNING: Could not import images to k3d. You may need to run:"
                echo "k3d image import expressed:latest happy:latest bootstorage:latest vuecalc:latest -c <cluster-name>"
            }
        }
    fi
fi

echo "*****************************************************"
echo "Starting deployment on kubernetes cluster"
echo "*****************************************************"
kubectl apply -f k8s/

echo "*****************************************************"
echo "Waiting for pods to be ready (this may take 1-2 minutes)..."
echo "*****************************************************"
kubectl wait --for=condition=ready pod -l run=express-svc --timeout=120s 2>/dev/null || echo "express-svc pod not ready yet"
kubectl wait --for=condition=ready pod -l run=happy-svc --timeout=120s 2>/dev/null || echo "happy-svc pod not ready yet"
kubectl wait --for=condition=ready pod -l run=bootstorage-svc --timeout=120s 2>/dev/null || echo "bootstorage-svc pod not ready yet"
kubectl wait --for=condition=ready pod -l run=vuecalc-svc --timeout=120s 2>/dev/null || echo "vuecalc-svc pod not ready yet"

echo "*****************************************************"
echo "Deployment completed successfully!"
echo "*****************************************************"
echo ""
echo "To access the application:"
echo "1. Port forward: kubectl port-forward svc/ambassador 8080:80"
echo "2. Open browser: http://localhost:8080"
echo ""
echo "Or check NodePort:"
echo "kubectl get svc ambassador"
echo "*****************************************************"