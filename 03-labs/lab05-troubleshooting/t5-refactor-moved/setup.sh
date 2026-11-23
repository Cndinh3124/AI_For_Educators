#!/usr/bin/env bash
# Creates real local state, then performs the "refactor" that causes the incident.
set -euo pipefail
cd "$(dirname "$0")"
terraform init -input=false >/dev/null
terraform apply -input=false -auto-approve >/dev/null
sed -i.bak 's/"artifact_store"/"artifacts"/' main.tf && rm -f main.tf.bak
echo "State created and refactor applied. Now run: terraform plan"
