# Rubric capstone (tham chiếu tiêu chí, 4 mức)

Điểm = Σ (mức × trọng số). Tối đa 4.0. **Đạt** khi ≥ 2.75 và không tiêu chí nào ở mức 1.

| Tiêu chí (trọng số) | 1 — Chưa đạt | 2 — Đang phát triển | 3 — Thành thạo | 4 — Xuất sắc |
|---|---|---|---|---|
| **R1. Module & state** (20%) · LO1, LO2 | Resource viết thẳng trong root; không có backend lock; có giá trị cứng theo môi trường | Có module và biến, nhưng thiếu validation; backend có nhưng thiếu lock hoặc versioning | Interface có ≥ 2 validation, default an toàn; backend `use_lockfile`; lock file đa nền tảng; dev/prod dùng chung module | Thêm: ranh giới state được lập luận theo blast radius; có `moved` hoặc kế hoạch refactor; output tối thiểu và có mô tả |
| **R2. Kiểm thử** (20%) · LO2, LO3 | Không có test, hoặc test không chạy được | Test chỉ có happy path | Có ca bị từ chối (`expect_failures`); mock provider; mutation test cho thấy test bắt được ≥ 1 mutation | Mutation có hệ thống (≥ 3), lỗ hổng tìm được đã được vá; nêu rõ những gì test bằng mock **không** chứng minh được |
| **R3. Policy as Code** (20%) · LO4 | Không có policy, hoặc chỉ chạy scanner có sẵn | Có ≥ 1 rule Rego nhưng không có test hoặc chạy trên dữ liệu giả không thực tế | ≥ 3 rule Rego v1 + unit test + chạy trên plan JSON thật; thông điệp lỗi chỉ cách sửa | Có fixture đối kháng làm lộ và sửa một lỗ hổng thật; phân tầng deny/warn có lý do; có cơ chế ngoại lệ được kiểm soát |
| **R4. Pipeline & bảo mật chuỗi cung ứng** (20%) · LO5, LO6 | Apply trực tiếp trong CI bằng access key dài hạn | Tách plan/apply nhưng còn ≥ 2 trong số: credential dài hạn, action pin theo tag, `permissions` mặc định, không có gate | OIDC, quyền tối thiểu, pin SHA, policy gate, approval, apply đúng plan đã duyệt; lint sạch | Thêm: xử lý stale plan và concurrency, giảm thiểu rủi ro artifact chứa secret, checksum cho công cụ tải về, có drift detection |
| **R5. Lập luận đánh đổi & bảo vệ** (20%) · LO8 | Không nêu được đánh đổi | Nêu đánh đổi định tính, chung chung | ≥ 3 đánh đổi có số liệu (chi phí, thời gian, rủi ro còn lại); trả lời được phần lớn câu phản biện | Chủ động nêu rủi ro còn tồn đọng và điều kiện khiến quyết định cần xem lại; dùng bằng chứng từ chính repo (output test/policy) khi trả lời |

## Hướng dẫn chấm để đảm bảo độ tin cậy
- Mỗi mức có **ví dụ mẫu (anchor)** lấy từ repo này. Ví dụ: R3 mức 4 tương ứng với finding F-08 (fixture đối kháng làm lộ lỗi âm tính giả).
- Chấm chéo 20% bài, chọn ngẫu nhiên. Nếu hai người chấm lệch nhau > 1 mức ở bất kỳ tiêu chí nào thì hội chấm cùng xem lại và hiệu chỉnh.
- Điểm R4 được hỗ trợ bằng bằng chứng tự động (`actionlint`, `zizmor`) nhưng **không thay thế** phán đoán của người chấm. Lint sạch chỉ là điều kiện cần.
