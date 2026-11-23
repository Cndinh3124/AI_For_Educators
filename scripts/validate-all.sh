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

fail() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; exit 1; }
# NOTE (finding F-17): every check is `cmd || fail`, never `cmd && pass` alone
# (set -e does not fire inside && lists). Policy paths are passed *relative*
# because conftest/opa treat ':' in a path as a separator.

section "1. terraform fmt"
terraform fmt -check -recursive "$LABS" || fail "fmt"; pass "fmt"

section "2. secure-bucket module: validate + terraform test"
( cd "$LABS/modules/secure-bucket" && terraform init -backend=false -input=false >/dev/null \
  && terraform validate >/dev/null && terraform test ) || fail "module tests"; pass "module tests"

section "3. lab01: offline plan -> plan JSON -> conftest"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cp -R "$LABS/modules" "$LABS/lab01-module-state" "$LABS/lab03-policy" "$TMP/"
( cd "$TMP/lab01-module-state" && cp offline_override.tf.example offline_override.tf \
  && terraform init -input=false >/dev/null && terraform plan -refresh=false -input=false -out=tfplan >/dev/null \
  && terraform show -json tfplan > plan.json \
  && conftest test --policy ../lab03-policy/policy --all-namespaces plan.json ) || fail "lab01 plan policy check"
pass "lab01 plan is policy-compliant"

section "4. policies: opa check/fmt/test + fixtures"
cd "$LABS/lab03-policy"
opa check --strict policy || fail "opa check"
opa fmt --fail --list policy >/dev/null || fail "opa fmt"; pass "opa check/fmt"
opa test policy || fail "opa unit tests"; pass "opa unit tests"
conftest test --policy policy --all-namespaces fixtures/plan-compliant.json || fail "compliant fixture"
pass "compliant fixture passes"
expect_denied() {  # passes only if conftest ran AND reported exactly the expected number of FAILs
  local out rc=0
  out="$(conftest test --policy policy --all-namespaces --no-color "fixtures/plan-$1.json" 2>&1)" || rc=$?
  [ "$rc" -eq 1 ] || fail "$1: expected exit 1 (denied), got $rc: $out"
  [ "$(grep -c '^FAIL' <<<"$out")" -eq "$2" ] || fail "$1: expected $2 FAIL lines: $out"
  pass "$1 fixture is denied ($2 violations)"
}
expect_denied noncompliant 7
expect_denied adversarial 1
cd "$ROOT"

section "5. tflint (aws ruleset) + checkov"
docker run --rm --mount "type=bind,source=$LABS,target=/data" -w /data -v tflint-plugins:/root/.tflint.d "$TFLINT_IMG" --init >/dev/null
for d in modules/secure-bucket lab01-module-state; do
  docker run --rm --mount "type=bind,source=$LABS,target=/data" -w /data -v tflint-plugins:/root/.tflint.d "$TFLINT_IMG" --chdir="$d" --config=/data/.tflint.hcl
done || fail "tflint"; pass "tflint"
docker run --rm --mount "type=bind,source=$LABS,target=/tf" "$CHECKOV_IMG" -d /tf/modules/secure-bucket --framework terraform --compact --quiet 2>/dev/null || fail "checkov"; pass "checkov"

section "6. workflows: actionlint + zizmor"
actionlint "$LABS/lab04-ci/.github/workflows/terraform.yml" "$ROOT/.github/workflows/validate.yml" || fail "actionlint"; pass "actionlint"
zizmor --no-progress --offline --persona=auditor "$LABS/lab04-ci/.github/workflows/terraform.yml" "$ROOT/.github/workflows/validate.yml" || fail "zizmor"; pass "zizmor (auditor)"

section "7. lab05: every seeded fault still fails"
for t in t1-for-each t2-unknown-count t3-cycle; do
  ( cd "$LABS/lab05-troubleshooting/$t" && terraform init -input=false >/dev/null 2>&1; \
    ! terraform plan -refresh=false -input=false >/dev/null 2>&1 ) || fail "$t should fail"; pass "$t fails as intended"
  rm -rf "$LABS/lab05-troubleshooting/$t/.terraform" "$LABS/lab05-troubleshooting/$t/.terraform.lock.hcl"
done
( cd "$LABS/lab05-troubleshooting/t4-version-conflict" && ! terraform init -input=false >/dev/null 2>&1 ) || fail "t4 should fail"; pass "t4 fails as intended"
rm -rf "$LABS/lab05-troubleshooting/t4-version-conflict/.terraform"

# cleanup
rm -rf "$LABS/modules/secure-bucket/.terraform" "$LABS/modules/secure-bucket/.terraform.lock.hcl"
printf '\nALL CHECKS PASSED\n'
