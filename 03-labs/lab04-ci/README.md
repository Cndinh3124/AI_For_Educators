# Lab04 — Pipeline Terraform trên GitHub Actions (Buổi 4)

**Mục tiêu:** LO5, LO6. Lời giải: `.github/workflows/terraform.yml`. Danh sách yêu cầu nằm trong `../../02-sessions/session-4-pipeline-governance.md`.

Bố cục repo mà workflow giả định (repo capstone của học viên):
```
infra/modules/<module>/        # mỗi module có tests/
infra/envs/dev/                # root module + backend.hcl (không chứa secret)
policy/                        # Rego + *_test.rego
.tflint.hcl
```

Cấu hình phía GitHub và AWS (ngoài code):
- Repository variables: `AWS_REGION`, `AWS_PLAN_ROLE_ARN`, `AWS_APPLY_ROLE_ARN`.
- Environment `dev` có required reviewers.
- IAM OIDC provider `token.actions.githubusercontent.com`. Trust policy của **plan role** giới hạn `sub` = `repo:<org>/<repo>:pull_request` và `repo:<org>/<repo>:ref:refs/heads/main`, quyền read-only + quyền ghi lock. Trust policy của **apply role** chỉ cho `repo:<org>/<repo>:environment:dev`.

Kiểm tra:
```bash
actionlint .github/workflows/terraform.yml
zizmor --offline --persona=auditor .github/workflows/terraform.yml
```
