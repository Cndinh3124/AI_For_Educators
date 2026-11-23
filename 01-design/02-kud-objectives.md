# 2. Mục tiêu học tập theo Backward Design

Thiết kế theo 3 giai đoạn của Wiggins & McTighe: **(1) kết quả mong muốn → (2) bằng chứng chấp nhận được → (3) kế hoạch học tập**. Tài liệu này là giai đoạn 1. Giai đoạn 2 nằm ở `04-assessment/`, giai đoạn 3 ở `02-sessions/`.

## 2.1 Mục tiêu chuyển giao (transfer goal)

> Học viên có thể tự **thiết kế, kiểm thử và bảo vệ** một quy trình IaC có guardrail tự động cho một service mới, sao cho đồng đội có thể merge thay đổi hạ tầng một cách an toàn mà không cần một "người gác cổng" chạy lệnh thủ công.

## 2.2 Biểu đồ KUD

### Know (kiến thức cần nhớ chính xác)
- K1. Cấu trúc plan JSON: `resource_changes[].change.actions`, `before/after`, `configuration`.
- K2. Cú pháp `terraform test`: `run`, `command = plan`, `assert`, `expect_failures`, `mock_provider`.
- K3. Cú pháp Rego v1: `deny contains msg if { ... }`, `some x in`, `every`, `with input as`.
- K4. Cơ chế khóa state S3 `use_lockfile`; ý nghĩa `.terraform.lock.hcl`; ràng buộc `~>`.
- K5. Luồng OIDC GitHub → AWS STS, và các trường `sub`/`aud` dùng trong trust policy.

### Understand (hiểu bản chất, các "big idea")
- U1. **Plan là hợp đồng**: thứ được duyệt phải chính là thứ được apply. Mọi khoảng hở giữa hai bước đó là rủi ro.
- U2. **State là nguồn sự thật** về danh tính resource. Thay đổi địa chỉ là thay đổi danh tính.
- U3. **Guardrail tốt ở đúng tầng**: validation trong module chặn input sai, test chặn regress, policy chặn vi phạm của tổ chức, approval chặn rủi ro còn lại. Không tầng nào thay được tầng khác.
- U4. **Một policy chỉ đáng tin bằng các ca nó đã từng bị thử phá**.
- U5. Mọi quyết định bảo mật đều có **chi phí** (tiền, tốc độ giao hàng, độ phức tạp). Kỹ sư giỏi nói rõ được đánh đổi.

### Do (kỹ năng thể hiện được)
- D1. Thiết kế module có interface được kiểm soát (validation, default an toàn).
- D2. Viết test có chủ đích, kể cả ca lỗi, và chứng minh test bắt được regress.
- D3. Viết, kiểm thử và gỡ lỗi policy Rego trên plan thật.
- D4. Lắp pipeline plan → policy gate → approval → apply với OIDC.
- D5. Chẩn đoán và sửa sự cố IaC, kèm guardrail phòng tái diễn.
- D6. Bảo vệ quyết định thiết kế bằng lập luận đánh đổi.

## 2.3 Mục tiêu học tập (đo lường được, có điều kiện và tiêu chí)

Mỗi mục tiêu viết theo cấu trúc ABCD (Audience–Behavior–Condition–Degree). Cấp Bloom (bản sửa đổi, Anderson & Krathwohl 2001) ghi ở cột phải.

| Mã | Mục tiêu | Bloom | KUD |
|---|---|---|---|
| LO1 | Với một plan JSON có từ 5 thay đổi trở lên, học viên **phân tích** và chỉ ra đúng các thay đổi gây destroy/replace và nguyên nhân (đổi địa chỉ, thuộc tính ForceNew, `count` dịch index), đúng ≥ 4/5 trường hợp. | Analyze | K1, U1, U2 |
| LO2 | Học viên **thiết kế** một module có ≥ 2 validation rule và default an toàn, sao cho `terraform test` chứng minh được cả ca hợp lệ lẫn ca bị từ chối. | Create | K2, D1 |
| LO3 | Cho một bộ test, học viên **đánh giá** độ tin cậy của nó bằng mutation test. Học viên chỉ ra ít nhất 1 thay đổi nguy hiểm mà bộ test không phát hiện được, rồi bổ sung assert để phát hiện nó. | Evaluate | D2, U4 |
| LO4 | Học viên **viết** policy Rego v1 cho ≥ 3 quy định của tổ chức, kèm unit test và ít nhất 1 fixture đối kháng. `opa check --strict` phải pass và fixture vi phạm phải bị chặn. | Create | K3, D3, U4 |
| LO5 | Với một pipeline mẫu, học viên **đánh giá** và chỉ ra ít nhất 3 điểm yếu về bảo mật hoặc độ tin cậy (ví dụ: credential dài hạn, apply plan khác plan đã duyệt, artifact lộ secret), xếp hạng theo rủi ro và đề xuất cách sửa. | Evaluate | K5, U1, D4 |
| LO6 | Học viên **xây dựng** một workflow GitHub Actions có OIDC, policy gate và apply từ đúng plan đã duyệt. Workflow phải pass `actionlint` và `zizmor`, và các action phải được pin theo SHA. | Create | D4 |
| LO7 | Với một sự cố IaC chưa từng gặp, học viên **chẩn đoán** được tầng gây lỗi (cú pháp, đồ thị phụ thuộc, provider, state, policy) và sửa trong ≤ 15 phút. Học viên cũng đề xuất 1 guardrail để lỗi không tái diễn. | Analyze | D5 |
| LO8 | Học viên **bảo vệ** thiết kế capstone trước hội đồng, nêu ≥ 3 đánh đổi định lượng được (chi phí KMS/CRR, thời gian pipeline, rủi ro còn lại) và trả lời được câu hỏi phản biện. | Evaluate | U3, U5, D6 |

> Phân bố: 0 mục tiêu ở Remember/Understand (phần đó nằm trong K và được kiểm bằng retrieval practice), 2 Analyze, 3 Evaluate, 3 Create, đúng với yêu cầu khóa nâng cao.

## 2.4 Bằng chứng chấp nhận được (giai đoạn 2, tóm tắt)

| Loại | Công cụ | Đo mục tiêu |
|---|---|---|
| Chẩn đoán | Pre-test (dạng A) | Đường cơ sở LO1, LO5, LO7 |
| Hình thành | Retrieval opener, hinge question, exit ticket, lab có autograde (`validate-all.sh`) | Tất cả |
| Tổng kết | Post-test (dạng B, cùng blueprint với dạng A), capstone + rubric 4 mức, phần bảo vệ miệng | LO1–LO8 |

Bản nháp v0 của tài liệu này do AI tạo và đã được sửa đáng kể. Xem `05-ai-review-log/02-findings.md`, mục P-01..P-04.
