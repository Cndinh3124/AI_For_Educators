# Lab03 — Policy as Code (Buổi 3, scaffold thấp)

**Mục tiêu:** LO4 · **Thời gian:** 40 phút

## Spec: lộ trình chính
1. Mọi `aws_s3_bucket_public_access_block` phải có cả 4 cờ bằng `true`.
2. Bucket có `tags_all.Environment == "prod"` phải có `aws_s3_bucket_logging` (dùng helper `attached()` được cấp trong `starter/`).
3. Viết unit test (`*_test.rego`) cho ca pass và ca fail.
4. Kỳ vọng: `plan-compliant.json` pass, `plan-noncompliant.json` bị chặn đủ.

## Mở rộng (người học nhanh / capstone R3 mức 4)
5. Tự viết `attached()`: PAB/logging phải **tham chiếu đúng bucket** (qua `configuration.*.expressions.bucket.references`), để chặn được `plan-adversarial.json`.

## Fixture (plan JSON thật, sinh từ `terraform show -json`)
| File | Kỳ vọng |
|---|---|
| `fixtures/plan-compliant.json` | 0 vi phạm |
| `fixtures/plan-noncompliant.json` | 7 vi phạm (S3 ×4, tag ×1, IAM ×2) |
| `fixtures/plan-adversarial.json` | 1 vi phạm: `aws_s3_bucket.unprotected` (2 bucket, 1 PAB) |

```bash
opa check --strict policy && opa test policy -v
conftest test --policy policy --all-namespaces fixtures/plan-adversarial.json
```

Lời giải tham khảo: `policy/` (Rego v1, 4 package, 10 unit test). `starter/` có khung để bắt đầu. Thư mục cấu hình nguồn `fixtures/*-config/` cho phép sinh lại fixture.
