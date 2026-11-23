# Buổi 1 — State, Plan & thiết kế module

**LO:** LO1 (Analyze), LO2 (Create, phần 1) · **Big idea:** U1 "Plan là hợp đồng", U2 "State là danh tính"
**Chuẩn bị:** Terraform ≥ 1.10, Docker; clone repo; **không cần tài khoản AWS** (dùng `offline_override.tf.example`).

| Phút | Hoạt động | Mô tả | Kiểm tra hiểu |
|---|---|---|---|
| Trước buổi | **Pre-test dạng A** (online, 20 phút, hạn chót 1 ngày trước buổi 1) | 12 câu, không tính điểm | GV phân nhóm trước khi vào lớp (xem `differentiation.md`). *Điều chỉnh H-03: không dùng 15 phút trên lớp cho pre-test* |
| 0–10 | **Mở đầu từ dữ liệu pre-test** | GV nêu 2 misconception phổ biến nhất của chính lớp này (ẩn danh) và hỏi: "Ai từng gặp chuyện này ở công việc?" | |
| 10–35 | **Worked example 1: đọc plan JSON** | GV giải thích to cách nghĩ (think-aloud) trên `fixtures/plan-compliant.json`: tìm `resource_changes`, đọc `actions`, phân biệt `after` với `after_unknown` | |
| 35–40 | **Hinge H1.1** | Một câu trắc nghiệm, cả lớp giơ thẻ A/B/C/D | ≥ 80% đúng thì đi tiếp, ngược lại GV giảng lại 5 phút bằng ví dụ khác |
| 40–85 | **Lab01 (fading bước 1)** | (a) chạy plan offline; (b) **giải thích** 8 resource được tạo và lý do của từng cái; (c) sửa 2 chỗ: thêm biến `force_destroy` có validation, thêm output `bucket_regional_domain_name` | Autograde: `terraform validate` + plan |
| 85–90 | **Hinge H1.2** | Phân biệt state và plan | |
| 90–108 | **Thảo luận tình huống** | "Một đồng nghiệp xóa `terraform.tfstate` trên máy vì nghĩ đó là cache. Chuyện gì xảy ra ở lần plan tiếp theo? Đội cần guardrail gì?" Thảo luận theo cặp rồi chia sẻ cả lớp | GV ghi các guardrail lên bảng: remote backend, versioning bucket state, `use_lockfile`, quyền IAM |
| 108–120 | **Exit ticket** | Xem bên dưới | |

## Worked example: backend có khóa (dùng S3 native lock)
```hcl
# backend.hcl (partial config, không commit giá trị thật)
bucket       = "REPLACE-ME-tfstate-bucket"
key          = "iac-course/dev/terraform.tfstate"
region       = "ap-southeast-1"
encrypt      = true
use_lockfile = true   # Terraform >= 1.10; dynamodb_table nay đã deprecated
```
Các điểm GV nói to khi giảng: (1) vì sao dùng partial config: một code, nhiều môi trường; (2) bucket state phải bật versioning để khôi phục được; (3) `use_lockfile` tạo đối tượng `.tflock` cạnh state; (4) M5: tài liệu và AI cũ vẫn hay đưa DynamoDB vào ví dụ.

## Lab01: các câu hỏi tự giải thích (self-explanation)
1. Vì sao `aws_s3_bucket_policy` cần `depends_on` vào public access block?
2. Nếu truyền `kms_key_arn` vào, plan thay đổi những gì? Hãy dự đoán trước, rồi chạy để kiểm chứng.
3. Vì sao các tag bắt buộc được merge **sau** `var.tags` (`merge(var.tags, local.mandatory_tags)`)?

## Exit ticket
> Plan báo: `# aws_s3_bucket.logs must be replaced` với `-/+`, kèm dòng `bucket = "a" -> "b" # forces replacement`.
> (1) Điều gì sẽ xảy ra với dữ liệu? (2) Nêu 2 cách để thay đổi tên mà không mất dữ liệu, kèm đánh đổi của mỗi cách.

*Đáp án tham khảo:* bucket cũ bị xóa (nếu rỗng hoặc có `force_destroy`), nếu không thì apply fail. Cách 1: tạo bucket mới, sao chép dữ liệu, chuyển consumer, rồi xóa bucket cũ (an toàn nhưng tốn công). Cách 2: giữ tên cũ, chỉ đổi tên logic bằng `moved {}` (rẻ nhưng tên vật lý vẫn như cũ). Lưu ý: `moved` **không** đổi được tên bucket trên AWS.
