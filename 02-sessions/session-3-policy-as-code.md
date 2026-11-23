# Buổi 3 — Policy as Code với OPA/Rego

**LO:** LO4 (Create) · **Big idea:** U3 "Guardrail ở đúng tầng", U4

| Phút | Hoạt động | Mô tả | Kiểm tra hiểu |
|---|---|---|---|
| 0–10 | **Retrieval** | K2 (khác nhau giữa `expect_failures` và `assert`), K1, câu interleaving: "Lỗi này do test, validation hay policy bắt?" | |
| 10–25 | **Mở đầu: Checkov pass, OPA vẫn chặn** | Chạy Checkov trên module (pass, có 4 skip kèm lý do), rồi chạy conftest trên plan của `t6-policy-gate` (bị chặn vì thiếu tag `Project` từ `default_tags`). Câu hỏi: vì sao scanner tĩnh không bắt được lỗi này? | Kỳ vọng: tag đến từ provider `default_tags`, chỉ lộ ra trong plan (`tags_all`) |
| 25–45 | **Worked example 3: viết rule `iam.rego`** | Giải thích cách nghĩ khi viết: (1) chọn input, (2) chuẩn hóa dữ liệu (`as_array` cho Statement là object hoặc array), (3) viết điều kiện vi phạm, (4) viết thông điệp có hướng dẫn sửa, (5) viết unit test cho cả ca pass và fail | |
| 45–50 | **Hinge H3.1** | Đọc một rule Rego, dự đoán kết quả | |
| 50–90 | **Lab03 (fading bước 3)** | **Lộ trình chính:** spec "4 cờ public access block phải bằng `true`" và "bucket prod phải có access logging" (được cấp sẵn helper `attached()`). Học viên viết rule + unit test, pass `plan-compliant.json` và chặn đủ vi phạm trong `plan-noncompliant.json`. **Mở rộng:** tự viết `attached()` để chặn `plan-adversarial.json` (2 bucket, 1 PAB). *Điều chỉnh H-04: fixture đối kháng quá khó cho người mới học Rego trong 40 phút; chuyển sang nhánh mở rộng và capstone (R3 mức 4)* | Autograde: `opa check --strict`, `opa test`, conftest với kết quả kỳ vọng |
| 90–95 | **Hinge H3.2** | deny hay warn? | |
| 95–110 | **Thảo luận: ngoại lệ policy** | "Đội Data cần bucket public để host dataset mở. Thiết kế quy trình ngoại lệ mà không phá guardrail." | Kỳ vọng: ngoại lệ được khai báo (tag/annotation + danh sách cho phép trong `data`), có hạn dùng, có người duyệt, có audit |
| 110–120 | **Exit ticket** | "Viết 1 ngoại lệ hợp lý cho rule blast-radius và cách bạn sẽ giới hạn nó." | |

## Câu chuyện thật từ quá trình soạn bài (dùng trong phần worked example)
Bản nháp AI của `has_sibling()` chỉ kiểm "cùng module có PAB". Với fixture 2 bucket + 1 PAB, rule **vẫn pass** (âm tính giả). Bản sửa đối chiếu `configuration.*.expressions.bucket.references` trong plan JSON. GV trình chiếu nguyên diff trong `05-ai-review-log/02-findings.md#f-08` để minh họa U4.
