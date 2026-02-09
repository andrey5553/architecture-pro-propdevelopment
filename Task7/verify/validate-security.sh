#!/bin/bash
cd ..
echo "Test insecure-manifests..."
for file in insecure-manifests/*.yaml; do
  echo "$file:"
  kubectl apply -f "$file" && \
    echo -e "Result: NOT Blocked as expected!!!\n" || \
    echo -e "Result: Blocked as expected.\n"
done

echo ""
echo "Test secure-manifests..."
for file in secure-manifests/*.yaml; do
  echo "$file:"
  kubectl apply -f "$file"
done

echo ""
echo "Done."
