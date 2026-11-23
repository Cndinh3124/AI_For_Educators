# Kiểm tra validity của hệ thống đánh giá

| Khía cạnh | Câu hỏi kiểm tra | Kết quả | Hành động |
|---|---|---|---|
| **Liên kết (alignment)** | Đánh giá có ở cùng cấp Bloom với mục tiêu không? | Bản v0: chỉ có "trắc nghiệm cuối khóa" cho cả 8 mục tiêu, trong đó 5 mục tiêu ở cấp Create/Evaluate không thể đo bằng trắc nghiệm | Thêm capstone + vấn đáp (Create/Evaluate); trắc nghiệm chỉ dùng cho Analyze/Evaluate dạng tình huống (P-03) |
| **Construct** | Câu hỏi có đo kỹ năng thay vì khả năng nhớ cú pháp không? | 12/12 câu dựa trên tình huống; 0 câu chỉ hỏi định nghĩa | — |
| **Độ chính xác nội dung** | Đáp án có đúng với phiên bản công cụ hiện hành không? | Phát hiện 2 lỗi trong bản nháp: A1 (RDS `identifier` thực ra **không** ForceNew trong provider 6.73.0) và B1 (`aws_elasticache_replication_group` không có argument `name`) | Đổi sang thuộc tính đã kiểm trong mã nguồn provider (F-16). Câu Rego A4, B4, H3.1 được kiểm bằng `opa eval` |
| **Tương đương giữa 2 dạng** | Dạng A và B có cùng blueprint và độ khó không? | Cùng LO, cùng cấp Bloom, cùng misconception làm nhiễu cho từng câu | Sau lần dạy đầu: so sánh p-value giữa các câu tương ứng; lệch > 0.2 thì hiệu chỉnh |
| **Độ tin cậy chấm** | Rubric có mô tả hành vi quan sát được không? | Mỗi ô rubric có tiêu chí kiểm chứng được (số lượng, công cụ, artifact) | Anchor + chấm chéo 20% |
| **Công bằng / thiên lệch** | Có lợi thế không liên quan đến năng lực không? | Rủi ro: người có tài khoản AWS có lợi thế | Mọi lab và capstone chạy được offline; không yêu cầu apply thật |
| **Ngôn ngữ** | Thuật ngữ tiếng Anh có gây cản trở không? | Giữ nguyên thuật ngữ kỹ thuật bằng tiếng Anh (chuẩn ngành) và giải thích bằng tiếng Việt | Bảng thuật ngữ trong buổi 1 |
| **Khả thi** | Có chấm xong được trong thời gian hợp lý không? | Autograde cho lab; capstone ≈ 20 phút/bài | — |
| **Gian lận / dùng AI** | Capstone có làm được hoàn toàn bằng AI không? | Có thể dùng AI để sinh code | Vấn đáp phản biện + bắt buộc nộp nhật ký dùng AI + yêu cầu bằng chứng mutation test trên chính repo của học viên |
