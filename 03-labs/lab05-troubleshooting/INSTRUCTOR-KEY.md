# Đáp án cho GV — Lab05 (KHÔNG phát cho học viên)

Mọi lỗi và mọi bản sửa dưới đây đã được **chạy thật** ngày 23/11/2026 (Terraform 1.16.4, AWS provider 6.73.0). Output nằm trong `05-ai-review-log/validation-runs.log`.

| Ticket | Lỗi quan sát được | Tầng | Nguyên nhân gốc | Bản sửa (đã kiểm chứng) | Guardrail |
|---|---|---|---|---|---|
| t1 | `Error: Invalid for_each argument` (`var.bucket_names is a list of string`) | Ngôn ngữ | `for_each` chỉ nhận map hoặc set | `for_each = toset(var.bucket_names)` → `Plan: 2 to add` | Khai báo biến kiểu `set(string)`; test với 2 phần tử |
| t2 | `Error: Invalid count argument` | Đồ thị phụ thuộc | `count` phụ thuộc giá trị chỉ biết sau apply (`aws_kms_key.logs.arn`); workspace cũ chạy được vì ARN đã có trong state | `count = var.enable_app_logs ? 1 : 0` (biến bool) → `Plan: 2 to add` | Quy ước: `count`/`for_each` chỉ dựa trên biến hoặc giá trị biết ở plan; test trên state rỗng (mock provider) |
| t3 | `Error: Cycle:` (liệt kê `aws_security_group.db`, `aws_security_group.app`) | Đồ thị phụ thuộc | Rule inline của 2 SG tham chiếu lẫn nhau | Tách thành `aws_vpc_security_group_ingress_rule` / `aws_vpc_security_group_egress_rule` → `Plan: 4 to add` | Quy ước module: không dùng rule inline |
| t4 | `no available releases match the given constraints ~> 5.0, ~> 6.0` | Provider/version | Hai ràng buộc không giao nhau | Module con: `">= 5.0, < 7.0"` (module chỉ khai **cận dưới**, root mới pin) → init cài 6.73.0 | Renovate cho module; CI chạy `init` ma trận version |
| t5 | `terraform_data.artifact_store will be destroyed` / `artifacts will be created` | State | Đổi địa chỉ = đổi danh tính | Thêm `moved { from = terraform_data.artifact_store, to = terraform_data.artifacts }` → `has moved to`, `Plan: 0 to add, 0 to change, 0 to destroy` | Rule blast-radius (`deny` khi delete resource có trạng thái) chặn PR loại này |
| t6 | conftest: `missing required tags {"Project"}` ở `aws_kms_key.this[0]`, `aws_s3_bucket.this` | Policy | Tag `Project` đến từ `default_tags` của provider; root này thiếu `default_tags` | Thêm `default_tags { tags = { Project = "..." } }` → conftest 9/9 pass | Module tự thêm `Project` qua biến bắt buộc, hoặc policy kiểm `tags_all` (đang làm) |

**Lưu ý chấm:** điểm của ticket dựa trên cột *Guardrail* nhiều hơn cột *Bản sửa* (LO7 yêu cầu đề xuất phòng tái diễn).
