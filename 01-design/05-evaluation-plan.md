# 5. Kế hoạch đo hiệu quả khóa học

Khung tham chiếu: 4 cấp của Kirkpatrick, gọn lại cho quy mô một lớp 12–20 người.

## 5.1 Chỉ số

| Cấp | Chỉ số | Cách đo | Ngưỡng "đạt" | Thời điểm |
|---|---|---|---|---|
| Phản ứng | Mức hữu ích cảm nhận; độ khó phù hợp | Khảo sát 5 câu Likert + 2 câu mở (cuối B2, B4) | Trung bình ≥ 4.0/5; ≤ 15% thấy "quá khó" | B2, B4 |
| Học tập | **Normalized gain** pre → post: g = (post − pre)/(100 − pre) | Pre (dạng A) / Post (dạng B), cùng blueprint 12 câu | Trung bình g ≥ 0.4 (mức "medium gain" theo Hake 1998) | B1, sau capstone |
| Học tập | Tỉ lệ hoàn thành lab có autograde | Số lab pass `validate-all.sh` trên tổng số lab | ≥ 85% hoàn thành lab01–04; lab05 ≥ 2/3 ticket trên lớp | Mỗi buổi |
| Học tập | Chất lượng capstone | Rubric 4 mức × 5 tiêu chí | ≥ 80% học viên đạt mức 3 trở lên ở R1–R4 | Bảo vệ |
| Hành vi | Áp dụng vào công việc | Sau 30 ngày: học viên nộp link PR (đã ẩn danh) có test/policy/pipeline mới | ≥ 50% học viên nộp ≥ 1 PR | +30 ngày |
| Kết quả | Chất lượng thay đổi hạ tầng | (Nếu đội cho phép) tỉ lệ PR hạ tầng bị revert/hotfix, trước và sau | Giảm (theo dõi, không đặt mục tiêu cứng) | +90 ngày |

## 5.2 Phân tích theo từng câu hỏi và từng mục tiêu
- Tính gain **theo LO**, không chỉ theo tổng điểm. Một LO có gain < 0.3 sẽ được đưa vào danh sách cải tiến.
- **Giới hạn độ tin cậy (H-06):** mỗi LO chỉ có 3 câu, nên gain theo LO **chỉ mang tính tham khảo**, dùng để phát hiện xu hướng chứ không để kết luận về từng học viên. Kết luận về LO phải đối chiếu thêm với điểm rubric capstone và tỉ lệ hoàn thành lab tương ứng. Lần dạy thứ hai: mở rộng ngân hàng câu lên ≥ 5 câu/LO.
- Phân tích độ khó (p-value) và độ phân biệt (điểm biserial) của từng câu pre/post. Câu có p > 0.9 ở pre-test thì loại hoặc làm khó hơn; câu có độ phân biệt < 0.2 thì viết lại.
- Theo dõi thời gian giải từng ticket lab05 để hiệu chỉnh độ khó.

## 5.3 Vòng cải tiến
1. Trong vòng 1 tuần sau khi khóa kết thúc: tổng hợp số liệu, viết bản retrospective 1 trang (giữ / bỏ / thử mới).
2. Nếu đa số trả lời sai một hinge question: thêm worked example cho đúng misconception đó ở lần dạy sau.
3. Cập nhật version: chạy lại `scripts/validate-all.sh` mỗi quý. Khi provider, action hoặc OPA lên major version thì rà lại toàn bộ AI Review Log (log F-01 cho thấy kiến thức về version lỗi thời rất nhanh).
4. Nhật ký thay đổi khóa học được lưu trong `CHANGELOG` của repo.

> Chưa có số liệu lớp thật: khóa học chưa được dạy. Bảng trên là **kế hoạch đo**, không phải kết quả.
