# 3. Ma trận liên kết Mục tiêu ↔ Hoạt động ↔ Đánh giá

Quy tắc: mỗi mục tiêu phải có **ít nhất 1 hoạt động luyện tập** và **ít nhất 1 đánh giá tổng kết** ở **cùng cấp Bloom**. Nếu đánh giá chỉ ở cấp thấp hơn mục tiêu thì coi là lệch (xem `04-assessment/05-validity-check.md`).

| LO | Bloom | Hoạt động học (buổi) | Đánh giá hình thành | Đánh giá tổng kết |
|---|---|---|---|---|
| LO1 Phân tích plan | Analyze | B1: worked example đọc plan JSON; B2: so sánh plan `count` và `for_each` | Hinge H1.1, H2.1; exit ticket B1 | Pre/Post Q1–Q3; capstone tiêu chí R1 |
| LO2 Thiết kế module | Create | B1 lab01 (worked → completion); B2 lab02 viết test | Autograde: `terraform test` | Capstone R1 |
| LO3 Đánh giá bộ test | Evaluate | B2: mutation test (tắt rotation, xem test có fail không) | Exit ticket B2 | Post Q5; capstone R2 |
| LO4 Viết policy | Create | B3 lab03: rule → unit test (fixture đối kháng ở nhánh mở rộng và capstone) | Hinge H3.1, H3.2; autograde `opa test` + conftest | Pre/Post Q4, Q6; capstone R3 |
| LO5 Đánh giá pipeline | Evaluate | B4: "red-team" workflow mẫu có 5 lỗi cài sẵn | Hinge H4.1 | Pre/Post Q7–Q9; capstone R4 |
| LO6 Xây pipeline | Create | B4 lab04 | Autograde `actionlint` + `zizmor` | Capstone R4 |
| LO7 Chẩn đoán sự cố | Analyze | B4 lab05 (3 ticket trên lớp + 3 ở nhà), độc lập hoàn toàn | Thời gian và độ chính xác theo từng ticket | Pre/Post Q10–Q12 |
| LO8 Bảo vệ đánh đổi | Evaluate | B1–B4: thảo luận tình huống cuối mỗi buổi | Exit ticket B3, B4 | Capstone R5 + vấn đáp |

## Kiểm tra độ phủ

| Kiểm tra | Kết quả |
|---|---|
| Mục tiêu không có hoạt động | 0 |
| Mục tiêu không có đánh giá tổng kết | 0 |
| Hoạt động không phục vụ mục tiêu nào | 0 (phần mở đầu retrieval phục vụ K1–K5) |
| Đánh giá thấp hơn cấp Bloom của mục tiêu | 0 sau khi sửa (bản v0: 5/8 mục tiêu chỉ được đo bằng trắc nghiệm, xem P-03) |
