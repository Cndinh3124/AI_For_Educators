#!/usr/bin/env bash
# Re-runs every check this evidence repo claims. Offline-capable (dummy AWS creds).
# Requires: terraform >= 1.10, opa, conftest, actionlint (+shellcheck), zizmor, docker (tflint, checkov).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LABS="$ROOT/03-labs"
export AWS_ACCESS_KEY_ID=mock AWS_SECRET_ACCESS_KEY=mock AWS_EC2_METADATA_DISABLED=true
TFLINT_IMG="ghcr.io/terraform-linters/tflint@sha256:65b9944a9274c4989492c1d79998c2801664bf8a55fddb4bd3a9e6d73a006ddc"
CHECKOV_IMG="bridgecrew/checkov@sha256:b4b7e9d419ddb9ae7a257678ee39cb5d9e5569f604723297dd9cec7fd4571bff"
pass() { printf '  \033[32mPASS\033[0m %s\n' "$1"; }
section() { printf '\n== %s ==\n' "$1"; }

section "1. terraform fmt"
terraform fmt -check -recursive "$LABS" && pass "fmt"

section "2. secure-bucket module: validate + terraform test"
( cd "$LABS/modules/secure-bucket" && terraform init -backend=false -input=false >/dev/null \
  && terraform validate >/dev/null && terraform test ) && pass "module tests"

section "3. lab01: offline plan -> plan JSON -> conftest"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cp -R "$LABS/modules" "$LABS/lab01-module-state" "$TMP/"
( cd "$TMP/lab01-module-state" && cp offline_override.tf.example offline_override.tf \
  && terraform init -input=false >/dev/null && terraform plan -refresh=false -input=false -out=tfplan >/dev/null \
  && terraform show -json tfplan > plan.json \
  && conftest test --policy "$LABS/lab03-policy/policy" --all-namespaces plan.json ) && pass "lab01 plan is policy-compliant"

section "4. policies: opa check/fmt/test + fixtures"
opa check --strict "$LABS/lab03-policy/policy" && opa fmt --fail --list "$LABS/lab03-policy/policy" >/dev/null && pass "opa check/fmt"
opa test "$LABS/lab03-policy/policy" && pass "opa unit tests"
conftest test --policy "$LABS/lab03-policy/policy" --all-namespaces "$LABS/lab03-policy/fixtures/plan-compliant.json" && pass "compliant fixture passes"
for f in noncompliant adversarial; do
  if conftest test --policy "$LABS/lab03-policy/policy" --all-namespaces "$LABS/lab03-policy/fixtures/plan-$f.json" >/dev/null; then
    echo "  FAIL $f fixture should be denied"; exit 1; fi; pass "$f fixture is denied"
done

section "5. tflint (aws ruleset) + checkov"
docker run --rm --mount "type=bind,source=$LABS,target=/data" -w /data -v tflint-plugins:/root/.tflint.d "$TFLINT_IMG" --init >/dev/null
for d in modules/secure-bucket lab01-module-state; do
  docker run --rm --mount "type=bind,source=$LABS,target=/data" -w /data -v tflint-plugins:/root/.tflint.d "$TFLINT_IMG" --chdir="$d" --config=/data/.tflint.hcl
done && pass "tflint"
docker run --rm --mount "type=bind,source=$LABS,target=/tf" "$CHECKOV_IMG" -d /tf/modules/secure-bucket --framework terraform --compact --quiet && pass "checkov"

section "6. workflows: actionlint + zizmor"
actionlint "$LABS/lab04-ci/.github/workflows/terraform.yml" "$ROOT/.github/workflows/validate.yml" && pass "actionlint"
zizmor --no-progress --offline --persona=auditor "$LABS/lab04-ci/.github/workflows/terraform.yml" "$ROOT/.github/workflows/validate.yml" && pass "zizmor (auditor)"

section "7. lab05: every seeded fault still fails"
for t in t1-for-each t2-unknown-count t3-cycle; do
  ( cd "$LABS/lab05-troubleshooting/$t" && terraform init -input=false >/dev/null 2>&1; \
    ! terraform plan -refresh=false -input=false >/dev/null 2>&1 ) && pass "$t fails as intended"
  rm -rf "$LABS/lab05-troubleshooting/$t/.terraform" "$LABS/lab05-troubleshooting/$t/.terraform.lock.hcl"
done
( cd "$LABS/lab05-troubleshooting/t4-version-conflict" && ! terraform init -input=false >/dev/null 2>&1 ) && pass "t4 fails as intended"
rm -rf "$LABS/lab05-troubleshooting/t4-version-conflict/.terraform"

# cleanup
rm -rf "$LABS/modules/secure-bucket/.terraform" "$LABS/modules/secure-bucket/.terraform.lock.hcl"
printf '\nALL CHECKS PASSED\n'
