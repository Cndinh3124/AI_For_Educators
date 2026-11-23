# Pre-test / Post-test (2 dạng song song, cùng blueprint)

- **Dạng A** dùng làm pre-test (làm online trước buổi 1), **dạng B** dùng làm post-test (sau capstone). Hai dạng đo cùng kỹ năng, cùng độ khó dự kiến, nhưng khác bề mặt (tài nguyên, tên, chi tiết), để tránh việc học viên nhớ đáp án.
- 12 câu × 1 điểm, 20 phút, không mở tài liệu. Mọi câu đều dựa trên tình huống (scenario-based). Mỗi phương án nhiễu tương ứng với một misconception trong `01-design/01-learner-analysis.md` §1.4.

## Blueprint

| Câu | LO | Bloom | Kỹ năng đo | Misconception làm nhiễu |
|---|---|---|---|---|
| 1 | LO1 | Analyze | Nhận diện replace trong plan | M3 |
| 2 | LO1 | Analyze | Hệ quả của `count` khi xóa phần tử | M4 |
| 3 | LO1 | Analyze | `validate` khác `plan` ở điểm nào | M1 |
| 4 | LO4 | Analyze | Đọc một rule Rego và dự đoán kết quả | M7 |
| 5 | LO3 | Evaluate | Đánh giá độ đủ của bộ test | M8 |
| 6 | LO4 | Evaluate | Nhận ra âm tính giả trong policy | M8 |
| 7 | LO5 | Evaluate | Rủi ro credential trong CI | — |
| 8 | LO5 | Evaluate | Khoảng hở giữa plan đã duyệt và apply | M9 |
| 9 | LO5 | Evaluate | Secret trong state/plan | M2, M6 |
| 10 | LO7 | Analyze | Chẩn đoán lỗi `count` unknown | — |
| 11 | LO7 | Analyze | Chẩn đoán ràng buộc version | M10 |
| 12 | LO7 | Analyze | Chẩn đoán refactor có state | M3 |

---

## Dạng A (pre-test)

**A1.** Plan hiển thị:
```
# aws_dynamodb_table.orders must be replaced
-/+ resource "aws_dynamodb_table" "orders" {
      ~ name = "orders" -> "orders-v2" # forces replacement
```
Điều gì xảy ra khi apply?
- A. Bảng được đổi tên tại chỗ, dữ liệu giữ nguyên
- B. **Bảng cũ bị xóa và một bảng mới (rỗng) được tạo, trừ khi `deletion_protection_enabled` chặn lại (khi đó apply fail)** ✔
- C. Terraform chỉ cập nhật state, không gọi API
- D. Apply bị từ chối ngay ở bước plan vì `name` là thuộc tính bất biến

**A2.** `aws_iam_user.u` dùng `count = length(var.users)` với `users = ["an", "binh", "chi"]`. Xóa `"binh"` khỏi list. Plan sẽ:
- A. Chỉ xóa user `binh`
- B. **Đổi tên/thay thế `u[1]` thành `chi` và xóa `u[2]`** ✔
- C. Không thay đổi gì vì tên user là duy nhất
- D. Báo lỗi vì list thay đổi độ dài

**A3.** `terraform validate` pass nhưng `terraform plan` fail với `InvalidClientTokenId`. Kết luận đúng nhất:
- A. Cấu hình có lỗi cú pháp mà validate bỏ sót
- B. **validate không gọi API; lỗi nằm ở credentials/kết nối provider** ✔
- C. Provider version không tương thích
- D. State bị hỏng

**A4.** Cho rule:
```rego
deny contains msg if {
  some rc in input.resource_changes
  rc.type == "aws_s3_bucket"
  not rc.change.after.tags_all.Owner
  msg := rc.address
}
```
Với một bucket có `tags_all = {"Owner": ""}`, rule sẽ:
- A. Chặn, vì chuỗi rỗng là falsy
- B. **Không chặn, vì `tags_all.Owner` tồn tại (chuỗi rỗng vẫn là giá trị được định nghĩa)** ✔
- C. Báo lỗi runtime
- D. Chặn, vì `not` áp dụng cho mọi giá trị rỗng

**A5.** Bộ test của module có 6 `run`, tất cả đều pass. Khi đổi `block_public_policy = false` trong module, cả 6 vẫn pass. Kết luận:
- A. Module an toàn vì test đều pass
- B. Mock provider có lỗi
- C. **Bộ test không kiểm soát thuộc tính này; cần thêm assert (mutation test đã lộ ra lỗ hổng)** ✔
- D. Cần chuyển sang `command = apply`

**A6.** Một rule yêu cầu "module chứa bucket phải có ít nhất một `aws_s3_bucket_versioning`". Trường hợp nào là **âm tính giả**?
- A. Module có 1 bucket và 1 versioning tham chiếu đến nó
- B. **Module có 2 bucket nhưng chỉ có 1 versioning tham chiếu đến bucket thứ nhất** ✔
- C. Module không có bucket nào
- D. Bucket được tạo bằng `for_each`

**A7.** Workflow CI lưu `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` của một IAM user trong GitHub Secrets. Rủi ro **lớn nhất** so với OIDC:
- A. Workflow chạy chậm hơn
- B. **Credential dài hạn, nếu lộ thì bị khai thác cho đến khi bị thu hồi thủ công, và không giới hạn được theo repo/branch** ✔
- C. GitHub không hỗ trợ secrets cho AWS
- D. Không dùng được với Terraform

**A8.** Pipeline: job `plan` chạy trên PR; sau khi merge, job `apply` chạy `terraform apply -auto-approve` (không dùng plan đã lưu). Khoảng hở nào nguy hiểm nhất?
- A. Apply chạy chậm
- B. **Thứ được apply có thể khác thứ đã được duyệt (main đã thay đổi, hoặc có drift)** ✔
- C. Plan không được lưu thì không có log
- D. `-auto-approve` không hợp lệ trong CI

**A9.** Biến `db_password` được đánh dấu `sensitive = true` và lấy từ `TF_VAR_db_password`. Phát biểu đúng:
- A. Giá trị không bao giờ được lưu ở đâu
- B. **Giá trị bị ẩn trong output CLI nhưng vẫn nằm dạng plaintext trong state và trong file plan** ✔
- C. Giá trị được mã hóa trong state bằng KMS mặc định
- D. Chỉ nằm trong `.terraform/`

**A10.** Môi trường mới, plan báo `Invalid count argument` ở `count = aws_kms_key.k.arn != "" ? 1 : 0`. Môi trường cũ không lỗi. Nguyên nhân:
- A. ARN có định dạng sai
- B. **Giá trị `count` phụ thuộc thuộc tính chỉ biết sau apply; môi trường cũ đã có ARN trong state** ✔
- C. Provider ở môi trường mới cũ hơn
- D. `count` không hỗ trợ toán tử ba ngôi

**A11.** `init` báo `no available releases match the given constraints ~> 5.0, ~> 6.0`. Cách sửa phù hợp nhất:
- A. Xóa `.terraform.lock.hcl`
- B. Hạ root xuống `~> 5.0`
- C. **Module con khai cận dưới rộng hơn (ví dụ `>= 5.0, < 7.0`); root mới là nơi pin phiên bản** ✔
- D. Chạy `terraform init -upgrade`

**A12.** PR đổi `resource "aws_s3_bucket" "logs"` thành `"audit_logs"` (không đổi `bucket`). Plan báo 1 destroy, 1 create. Bản sửa đúng:
- A. Chạy `terraform apply`. Tên bucket không đổi nên AWS sẽ giữ nguyên
- B. **Thêm `moved { from = aws_s3_bucket.logs, to = aws_s3_bucket.audit_logs }`** ✔
- C. Thêm `lifecycle { prevent_destroy = true }` là đủ
- D. Dùng `-target` để chỉ tạo bucket mới

---

## Dạng B (post-test)

**B1.** Plan: `~ replication_group_id = "app-cache" -> "app-cache-2" # forces replacement` trên `aws_elasticache_replication_group.cache`. Hệ quả: **cluster cũ bị hủy và cluster mới được tạo, dữ liệu cache mất** ✔ / đổi tên tại chỗ / chỉ cập nhật state / apply bị từ chối.

**B2.** `aws_route53_record.r` dùng `count` với `["api", "web", "admin"]`. Xóa `"api"`. Plan: **các record ở index 0 và 1 bị thay thế hoặc cập nhật để dịch chuyển, index 2 bị xóa** ✔ / chỉ xóa `api` / không đổi / lỗi.

**B3.** `validate` pass, `plan` fail với `error configuring S3 Backend: no valid credential sources`. Kết luận: **validate không kiểm backend/credentials** ✔ / validate bỏ sót lỗi cú pháp / version provider / state hỏng.

**B4.** Rule có `not rc.change.after.versioning_configuration[0].status == "Enabled"`. Với resource mà `after` **không có** `versioning_configuration`: **rule chặn (biểu thức undefined → `not` thành true)** ✔ / không chặn / lỗi runtime / chỉ cảnh báo.

**B5.** Bộ test vẫn pass khi đổi `sse_algorithm = "AES256"`. Kết luận: **bộ test không kiểm soát thuộc tính này, cần thêm assert** ✔ / module an toàn / lỗi mock / cần apply.

**B6.** Rule "trong module phải có ít nhất một `aws_s3_bucket_public_access_block`". Âm tính giả: **module có 3 bucket và 1 PAB** ✔ / 1 bucket và 1 PAB / không có bucket / bucket dùng `count`.

**B7.** CI dùng access key của IAM user có `AdministratorAccess`. Rủi ro lớn nhất so với OIDC: **credential dài hạn với quyền quá rộng, không giới hạn được theo repo/branch/environment** ✔ / chậm / không hỗ trợ / không dùng được với Terraform.

**B8.** Apply job chạy `terraform plan && terraform apply -auto-approve` trên main sau khi PR được approve. Khoảng hở: **plan được apply chưa từng được người hoặc policy gate duyệt** ✔ / chậm / thiếu log / cú pháp sai.

**B9.** Output `api_key` được đánh dấu `sensitive = true`. Phát biểu đúng: **ẩn trên CLI nhưng vẫn là plaintext trong state** ✔ / không được lưu / được mã hóa trong state / chỉ nằm trong `.terraform/`.

**B10.** `for_each = { for s in aws_subnet.private : s.id => s }` báo `Invalid for_each argument` ở môi trường mới. Nguyên nhân: **key của map là giá trị chỉ biết sau apply (`id`)** ✔ / subnet sai / provider cũ / `for_each` không nhận map.

**B11.** Module A cần `~> 5.40`, module B cần `>= 6.0`. Init fail. Cách sửa phù hợp nhất: **nới ràng buộc của module A (cận dưới rộng hơn), root pin một phiên bản** ✔ / xóa lock file / hạ root / `init -upgrade`.

**B12.** Chuyển `aws_kms_key.this` vào trong `module "crypto"`. Plan báo destroy key cũ. Bản sửa: **`moved { from = aws_kms_key.this, to = module.crypto.aws_kms_key.this }`** ✔ / apply luôn / `prevent_destroy` là đủ / dùng `-target`.

> Dạng B được viết ngắn gọn ở đây. Bản phát cho học viên dùng đúng định dạng 4 phương án như dạng A, đảo thứ tự đáp án.

## Chấm điểm và báo cáo
- Báo cáo điểm **theo LO** (LO1: câu 1–3, LO3/LO4: câu 4–6, LO5: câu 7–9, LO7: câu 10–12).
- Normalized gain theo từng LO: g = (post − pre) / (3 − pre) cho mỗi nhóm 3 câu. Chỉ mang tính tham khảo vì mỗi LO chỉ có 3 câu (xem H-06).
