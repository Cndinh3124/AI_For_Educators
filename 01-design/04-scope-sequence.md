# 4. Scope & Sequence

**Định dạng:** 4 buổi × 120 phút + capstone (≈ 6–8 giờ tự làm trong 1 tuần, bảo vệ 15 phút/người).
**Nguyên tắc sắp xếp:** đi từ *đơn vị nhỏ nhất có thể kiểm chứng* (module) → *bằng chứng tự động* (test) → *luật tổ chức* (policy) → *quy trình* (pipeline). Mỗi buổi kéo kiến thức của buổi trước vào phần retrieval (spaced practice) và trộn dạng bài (interleaving) ở lab05.

| | Buổi 1 | Buổi 2 | Buổi 3 | Buổi 4 | Capstone |
|---|---|---|---|---|---|
| **Chủ đề** | State, plan & thiết kế module | Kiểm thử & refactor an toàn | Policy as Code với OPA/Rego | Pipeline, quản trị & sự cố | Thiết kế trọn vẹn |
| **Big idea** | U1, U2 | U2, U4 | U3, U4 | U1, U3, U5 | U5 |
| **LO chính** | LO1, LO2 | LO2, LO3 | LO4 | LO5, LO6, LO7 | LO8 (+ tất cả) |
| **Lab** | lab01 (worked example → completion) | lab02 (`terraform test`, mutation) | lab03 (rule + test; fixture đối kháng là mở rộng) | lab04 (workflow) + lab05 (3 ticket trên lớp, 3 ở nhà) | Repo riêng |
| **Mức scaffold** | Cao: code mẫu đầy đủ, học viên sửa | Vừa: khung test, học viên viết assert | Thấp: chỉ có spec + fixture | Gần như không: chỉ có ticket | Không có |
| **Retrieval mở đầu** | Phản hồi từ pre-test (làm online trước buổi) | K1, K4 từ B1 | K2 từ B2 + K1 | K3 từ B3 + K4 + U1 | |
| **Hinge** | H1.1, H1.2 | H2.1, H2.2 | H3.1, H3.2 | H4.1, H4.2 | |
| **Exit ticket** | Phân tích 1 plan | Một assert còn thiếu | Một ngoại lệ policy hợp lý | Xếp hạng 3 rủi ro pipeline | |
| **Bài về nhà** | Đọc trước plan JSON spec | Viết 1 test cho module của đội | Viết 1 rule cho đội | lab05 t2–t4 + bắt đầu capstone | Bảo vệ + post-test (dạng B) |

## Tiến trình mức độ phức tạp của lab (fading)

```
Lab01  [■■■■■■■■■■] code mẫu đầy đủ; học viên giải thích rồi sửa 2 chỗ
Lab02  [■■■■■■□□□□] có sẵn khung run/variables; học viên viết assert và expect_failures
Lab03  [■■■□□□□□□□] chỉ có spec + fixture + helper; học viên viết rule và test (fixture đối kháng: mở rộng)
Lab04  [■■□□□□□□□□] có danh sách yêu cầu và cổng lint; học viên tự lắp workflow
Lab05  [□□□□□□□□□□] chỉ có ticket sự cố; học viên tự chẩn đoán (3 trên lớp, 3 ở nhà)
```
