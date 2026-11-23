# Lab05 — Troubleshooting (Buổi 4, không có scaffold)

Mỗi thư mục `t1`…`t6` là một ticket. Ghi vào `INCIDENT.md` theo mẫu:

| Triệu chứng | Giả thuyết tầng lỗi | Bằng chứng (lệnh + output) | Bản sửa | Guardrail phòng tái diễn |
|---|---|---|---|---|

```bash
export AWS_ACCESS_KEY_ID=mock AWS_SECRET_ACCESS_KEY=mock AWS_EC2_METADATA_DISABLED=true
cd t1-for-each && terraform init && terraform plan -refresh=false
# t5: chạy ./setup.sh trước (tạo state thật bằng terraform_data, rồi thực hiện "refactor")
# t6: plan -> show -json -> conftest với ../../lab03-policy/policy
```
