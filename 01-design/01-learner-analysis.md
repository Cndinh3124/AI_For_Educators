# 1. Phân tích người học & khung năng lực

## 1.1 Chân dung người học

| Thuộc tính | Mô tả |
|---|---|
| Vai trò | DevOps / Platform / Cloud Engineer, 1–3 năm kinh nghiệm |
| Đã vững | Git (branch, PR, rebase), Docker, Linux shell, YAML, đã tự `terraform apply` vài lần trên môi trường cá nhân/dev |
| Đã gặp nhưng chưa vững | Remote state, module, biến môi trường, GitHub Actions cơ bản |
| Chưa có | Kiểm thử hạ tầng, Policy as Code, thiết kế pipeline có cổng phê duyệt, xử lý refactor có state |
| Động lực | Muốn chuyển từ "người chạy lệnh" sang "người thiết kế guardrail" mà đội có thể tin cậy |
| Ràng buộc | Học ngoài giờ, 2 giờ/buổi; nhiều người **không có tài khoản AWS riêng**, nên lab phải chạy được offline |

## 1.2 Kiến thức đầu vào (kiểm bằng pre-test, xem `04-assessment/01-pre-post-test.md`)

| Mã | Điều kiện tiên quyết | Nếu thiếu thì làm gì |
|---|---|---|
| P1 | Đọc/viết HCL: resource, variable, output, `for_each` | Gói ôn tập "HCL in 30 minutes" (scaffold S0) trước buổi 1 |
| P2 | Hiểu vòng đời `init → plan → apply` | Worked example có chú thích trong buổi 1 |
| P3 | Viết workflow GitHub Actions 1 job | Mẫu workflow tối giản trong `03-labs/lab04-ci` |
| P4 | Đọc JSON, dùng `jq` cơ bản | Cheat-sheet `jq` cho plan JSON (buổi 3) |

## 1.3 Lỗ hổng thường gặp (rút từ review PR hạ tầng thực tế và các issue công khai)

1. Coi `plan` như ảnh chụp tĩnh mà không hiểu nó phụ thuộc vào **state + refresh + provider version**.
2. Không có **ranh giới module**: module nhận 30 biến, không có `validation`, không có output rõ ràng.
3. Không kiểm thử: chỉ "apply thử trên dev rồi xem".
4. Chỉ biết quét tĩnh (Checkov/Trivy). Không biết viết **luật riêng của tổ chức** trên plan JSON.
5. Pipeline dùng **access key dài hạn** trong secrets thay vì OIDC. Không có cổng phê duyệt, và apply một plan khác với plan đã duyệt.

## 1.4 Misconception phổ biến → cách xử lý trong khóa

| # | Misconception | Vì sao nguy hiểm | Hoạt động "phá" misconception |
|---|---|---|---|
| M1 | "`terraform validate` pass nghĩa là cấu hình đúng trên cloud" | validate chỉ kiểm cú pháp và kiểu dữ liệu, không gọi API | Buổi 1: config validate pass nhưng plan fail vì credentials (log F-02 của chính khóa học) |
| M2 | "State chỉ là cache, xóa đi không sao / commit lên Git cũng được" | State là nguồn sự thật ánh xạ resource ↔ ID và chứa secret dạng plaintext | Buổi 1: mở `terraform.tfstate` của lab t5 và tìm giá trị nhạy cảm |
| M3 | "Đổi tên resource chỉ là refactor vô hại" | Terraform hiểu đó là destroy + create, gây mất dữ liệu với resource có trạng thái | Lab05-t5: state thật, plan báo `1 to destroy`; sửa bằng `moved {}` |
| M4 | "`count` và `for_each` dùng thay nhau được" | `count` theo index: xóa phần tử giữa list sẽ dịch chuyển và tạo lại các resource phía sau | Buổi 2: so sánh plan khi xóa phần tử thứ 2 |
| M5 | "Cần DynamoDB để khóa state S3" | Từ Terraform 1.10 có `use_lockfile = true` (lock bằng S3 native). Bảng DynamoDB nay là cơ chế cũ, đã bị đánh dấu deprecated | Buổi 1: worked example backend dùng `use_lockfile` |
| M6 | "Secret đặt trong `terraform.tfvars` và `.gitignore` thì an toàn" | Giá trị vẫn nằm trong state và **trong file plan** (log F-10) | Buổi 4: tìm secret trong artifact plan |
| M7 | "Policy as Code = chạy Checkov" | Scanner tĩnh có luật chung. Luật **của tổ chức** (tag, blast radius, prod logging) cần Rego trên plan | Buổi 3: Checkov pass nhưng OPA vẫn chặn |
| M8 | "Policy có test pass là policy đúng" | Test chỉ chứng minh những ca đã nghĩ tới. Cần fixture đối kháng | Buổi 3: fixture `plan-adversarial.json` làm lộ lỗi âm tính giả (log F-08) |
| M9 | "Approve PR là đã duyệt thay đổi hạ tầng" | Người duyệt thường không nhìn thấy plan, hoặc apply chạy một plan khác | Buổi 4: plan → job summary → environment approval → apply **đúng file plan đó** |
| M10 | "`~> 6.0` nghĩa là mọi bản từ 6.0 trở lên" | `~> 6.0` = `>= 6.0, < 7.0`. Ràng buộc chồng nhau giữa các module có thể không có nghiệm | Lab05-t4 |

## 1.5 Khung năng lực (4 mức, dùng xuyên suốt rubric)

| Năng lực | Mới bắt đầu (1) | Đang phát triển (2) | Thành thạo (3) | Xuất sắc (4) |
|---|---|---|---|---|
| C1. Thiết kế module & state | Viết resource trong 1 file | Tách module, có biến/output | Interface có validation, backend có lock, hiểu tác động state | Thiết kế ranh giới module/state theo blast radius và quyền sở hữu |
| C2. Kiểm thử hạ tầng | Chỉ `validate` | Có `terraform test` cho happy path | Test cả ca lỗi (`expect_failures`), dùng mock provider | Chứng minh test bắt được lỗi (mutation test) |
| C3. Policy as Code | Chạy scanner có sẵn | Viết rule Rego đơn giản | Rule + unit test + fixture thật | Fixture đối kháng, phân tầng deny/warn, có lý do cho ngoại lệ |
| C4. Pipeline & quản trị | Workflow chạy `apply` | Tách plan/apply | OIDC, policy gate, apply đúng plan đã duyệt | Cân nhắc lộ secret qua artifact, xử lý concurrency/stale plan, supply chain |
| C5. Chẩn đoán sự cố | Thử–sai | Đọc thông báo lỗi | Phân loại lỗi (cú pháp / đồ thị / provider / state / policy) và sửa | Sửa tận gốc và bổ sung guardrail để lỗi không tái diễn |
