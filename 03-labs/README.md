# 03-labs — Lab thực hành (chạy được, đã kiểm chứng)

Tất cả lab chạy **offline** (không cần tài khoản AWS) và được kiểm tra lại bằng `../scripts/validate-all.sh`.

| Lab | Buổi | Nội dung | Scaffold | Kiểm tra tự động |
|---|---|---|---|---|
| [`modules/secure-bucket`](modules/secure-bucket) | 1–2 | Module S3 an toàn: SSE-KMS, chặn public, versioning, lifecycle, TLS-only, logging tùy chọn | Code mẫu | `terraform test` (7 run), TFLint, Checkov |
| [`lab01-module-state`](lab01-module-state) | 1 | Root module, partial S3 backend (`use_lockfile`), plan offline | Cao | validate + plan + conftest |
| [`lab02-testing`](lab02-testing) | 2 | `terraform test` + mock provider + mutation test | Vừa | `terraform test` |
| [`lab03-policy`](lab03-policy) | 3 | Rego v1 trên plan JSON: S3, tags, IAM, blast radius; unit test; fixture đối kháng | Thấp | `opa check --strict`, `opa test` (10), conftest × 3 fixture |
| [`lab04-ci`](lab04-ci) | 4 | GitHub Actions: OIDC, policy gate, approval, apply đúng plan | Rất thấp | `actionlint`, `zizmor --persona=auditor` |
| [`lab05-troubleshooting`](lab05-troubleshooting) | 4 | 6 sự cố cài sẵn | Không | Mỗi lỗi được xác minh là fail đúng kiểu; mỗi đáp án được xác minh là sửa được |

## Chạy nhanh
```bash
cd 03-labs/lab01-module-state
cp offline_override.tf.example offline_override.tf     # chỉ dùng trong lớp học
export AWS_ACCESS_KEY_ID=mock AWS_SECRET_ACCESS_KEY=mock AWS_EC2_METADATA_DISABLED=true
terraform init && terraform plan -refresh=false -out=tfplan
terraform show -json tfplan > plan.json
conftest test --policy ../lab03-policy/policy --all-namespaces plan.json
```

## Phiên bản đã kiểm chứng (23/11/2026)
| Thành phần | Phiên bản |
|---|---|
| Terraform | 1.16.4 |
| hashicorp/aws provider | 6.73.0 (ràng buộc `~> 6.0`) |
| OPA / Conftest | 1.22.4 / 0.71.1 |
| TFLint / ruleset-aws | 0.66.0 / 0.50.0 (image pin theo digest) |
| Checkov | 3.4.6 (image pin theo digest) |
| actionlint / zizmor | 1.7.12 / 1.33.1 |
| actions/checkout · setup-terraform · configure-aws-credentials | v7.0.1 · v4.0.1 · v6.3.0 (pin SHA) |

> **Ghi chú an toàn:** `offline_override.tf.example` tắt kiểm tra credentials để plan chạy được offline. Không bao giờ dùng file này với môi trường thật. File `*_override.tf` đã có trong `.gitignore`.
