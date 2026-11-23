# Buổi 2 — Kiểm thử & refactor an toàn

**LO:** LO2 (Create), LO3 (Evaluate) · **Big idea:** U4 "Policy/test chỉ đáng tin bằng các ca nó đã bị thử phá"

| Phút | Hoạt động | Mô tả | Kiểm tra hiểu |
|---|---|---|---|
| 0–10 | **Retrieval** (không mở tài liệu) | 4 câu: K1 (đường dẫn `change.actions` trong plan JSON), K4 (`~> 6.0` nghĩa là gì?), U2 (đổi tên resource thì sao?), câu tự chọn từ exit ticket B1 | Tự chấm bằng đáp án, ghi lại câu sai |
| 10–30 | **Worked example 2: `terraform test` + mock provider** | GV dựng test `public_access_fully_blocked`, giải thích vì sao **test phải nằm trong module** (log F-07: AI viết sai thành `module.bucket.aws_kms_key...` và bị lỗi `Unsupported attribute`) | |
| 30–35 | **Hinge H2.1** | `count` và `for_each` khi xóa phần tử giữa list | |
| 35–75 | **Lab02 (fading bước 2)** | Có sẵn file `tests/secure_bucket.tftest.hcl` với 3 `run`, phần `assert` để trống. Học viên: (a) viết assert; (b) thêm `expect_failures` cho tên bucket sai; (c) **mutation test**: sửa `enable_key_rotation = false` và `restrict_public_buckets = false`, chạy test, ghi lại test nào fail; (d) nếu không test nào fail thì viết thêm assert | Autograde: `terraform test`, mutation phải làm ≥ 1 test fail |
| 75–80 | **Hinge H2.2** | Ràng buộc version giao nhau | |
| 80–100 | **Thảo luận tình huống: refactor có state** | Demo nhanh lab05-t5: đổi tên `artifact_store` → `artifacts`, plan báo 1 destroy. Cặp đôi tranh luận: `moved {}`, `terraform state mv` hay `import`, chọn cách nào và vì sao? | Kỳ vọng: `moved` là khai báo, review được trong PR và chạy được trên mọi workspace |
| 100–120 | **Exit ticket** | "Viết **một assert** mà bộ test hiện tại còn thiếu, và nêu sự cố production mà assert đó ngăn được." | |

## Lưu ý sư phạm
- Mutation test được đưa vào **trước** khi học viên tự tin vào test. Mục đích là tạo productive failure: học viên tự thấy "test xanh" chưa có nghĩa là "an toàn".
- Mock provider trả về giá trị giả cho các thuộc tính computed. Hãy nhấn mạnh rằng test bằng mock **không** kiểm được hành vi thật của API AWS. Cần tách *test hợp đồng module* với *test tích hợp* (chạy trên tài khoản sandbox, ngoài phạm vi khóa học).
