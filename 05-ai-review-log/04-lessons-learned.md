# 4. Bài học về giới hạn của AI khi soạn nội dung kỹ thuật

## 4.1 AI sai theo những kiểu có thể dự đoán
| Kiểu lỗi | Ví dụ trong log | Vì sao AI dễ mắc | Biện pháp kiểm soát |
|---|---|---|---|
| **Kiến thức đóng băng theo thời điểm** | F-01 (version), F-16 (ForceNew) | Dữ liệu huấn luyện có điểm cắt; API của provider thay đổi theo từng bản minor | Neo vào registry, tag và mã nguồn **tại version cụ thể** trước khi viết |
| **Hợp lý nhưng sai ngữ nghĩa** | F-07 (phạm vi của `terraform test`), F-08 (khớp theo module) | Code "trông đúng", qua được cú pháp, nhưng hiểu sai mô hình thực thi | Chạy thật và **viết fixture đối kháng**; không dừng ở "test xanh" |
| **Bỏ sót mối nguy cấp hệ thống** | F-09, F-10, F-12 | Mỗi file riêng lẻ đều đúng; rủi ro chỉ lộ ra khi nhìn cả luồng (plan → artifact → approval → apply) | Rà soát theo mô hình mối đe dọa của cả pipeline, không chỉ lint từng file |
| **Giả định về môi trường** | F-02, F-11 | AI ngầm giả định môi trường giống máy đang chạy | Chạy trên môi trường giống học viên (offline, Linux runner) |
| **Ghi chép "theo trí nhớ"** | F-15 | AI tái tạo thông báo lỗi thay vì trích output thật | Mọi output trong tài liệu dạy phải được dán từ lần chạy thật |
| **Sư phạm hình thức** | P-01…P-04 | Động từ "hiểu/biết" và trắc nghiệm là mẫu phổ biến nhất trong dữ liệu | Checklist ABCD + ma trận Bloom ↔ đánh giá bắt buộc |

## 4.2 Công cụ cũng có giới hạn
- **zizmor không bắt được F-12** (`curl | bash` từ tag) và **Checkov pass không có nghĩa là tuân thủ quy định tổ chức** (t6). Công cụ là lưới an toàn, không thay được phán đoán chuyên môn.
- Một số finding của Checkov không áp dụng cho ngữ cảnh (F-06). Chấp nhận hay bỏ qua finding là quyết định của con người, và **phải có lý do ghi trong code**.

## 4.3 Quy trình rút ra (áp dụng cho lần sau)
1. **Neo nguồn trước khi viết.** Xác định version và nguồn, đưa vào prompt.
2. **Viết tiêu chí chấp nhận máy kiểm được** cho mỗi artifact *trước khi* AI viết.
3. **Lưu bản v0 nguyên văn.** Không có bản v0 thì không đo được mức độ đã sửa.
4. **Ba lớp kiểm tra:** công cụ tĩnh → chạy thật → đối kháng/mutation.
5. **Rà soát theo luồng**, không chỉ theo file.
6. **Đánh dấu nguồn phát hiện.** Tự rà soát của AI cần người xác nhận.
7. **Người ký duyệt** chịu trách nhiệm cuối cùng về nội dung được dạy.

## 4.4 Chỗ AI thực sự tạo giá trị
- Tạo nhanh bộ khung nhất quán (module, test, policy, workflow) để người hướng dẫn tập trung vào **thiết kế đánh đổi** và **misconception**.
- Sinh fixture và tình huống lỗi (lab05) cùng phương án nhiễu theo misconception: những phần tốn công nhất khi soạn tay.
- Chính các lỗi của AI trở thành **tư liệu dạy học**: F-07, F-08, F-16 được dùng trực tiếp trong buổi 2, buổi 3 và trong anchor của rubric.
