#!/bin/bash
cd ..
echo -e "Testing insecure manifests...\n"
kubectl apply -f insecure-manifests/ || \
  echo -e "\nBlocked as expected.\n\n"

echo -e "Testing secure manifests...\n"
kubectl apply -f secure-manifests/

echo -e "\nDone."
