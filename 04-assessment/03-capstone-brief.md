# Capstone — "Guardrail cho một service mới"

**Thời gian:** 1 tuần (≈ 6–8 giờ) + bảo vệ 15 phút (8 phút trình bày, 7 phút phản biện)
**LO:** tất cả, trọng tâm LO8

## Tình huống
Đội sản phẩm cần hạ tầng cho **"doc-intake"**, một service mẫu công khai nhận tài liệu PDF qua presigned URL, lưu trữ, và cho một job xử lý đọc ra. Yêu cầu phi chức năng:
- Tài liệu có thể chứa dữ liệu cá nhân → mã hóa, không public, có audit.
- Môi trường `dev` và `prod`; prod phải giữ dữ liệu ≥ 1 năm.
- Đội chỉ có 2 kỹ sư nên pipeline phải tự chặn sai lầm, không dựa vào một "người gác cổng".

> Service là hư cấu và không dùng bất kỳ thông tin nội bộ nào. Học viên tự chọn region và đặt tên.

## Sản phẩm phải nộp (repo Git)
1. **IaC:** module dùng lại được (có thể mở rộng `secure-bucket`) + root `dev` và `prod`; backend có lock.
2. **Kiểm thử:** `terraform test` có ca hợp lệ và ca bị từ chối; **báo cáo mutation test** (≥ 2 mutation, chỉ ra test nào bắt được).
3. **Policy:** ≥ 3 rule Rego v1 của "tổ chức" (ít nhất 1 rule học viên tự đề xuất), unit test, ≥ 1 fixture đối kháng.
4. **Pipeline:** workflow GitHub Actions theo danh sách yêu cầu của lab04; pass `actionlint` và `zizmor --persona=auditor`.
5. **ADR (≤ 2 trang):** ≥ 3 quyết định có đánh đổi **định lượng**. Gợi ý:
   - SSE-KMS với CMK riêng hay SSE-S3? (Theo bảng giá AWS công khai, kiểm lại khi nộp: CMK ≈ 1 USD/tháng + phí theo request; S3 Bucket Key giảm mạnh số request KMS.)
   - Cross-region replication cho prod: chi phí lưu trữ ×2 + phí truyền dữ liệu so với RPO/RTO yêu cầu.
   - Truyền plan qua artifact hay plan lại trong job apply: rủi ro lộ dữ liệu so với rủi ro "apply khác thứ đã duyệt".
   - Policy `deny` hay `warn` cho từng rule: chi phí dương tính giả so với rủi ro bỏ lọt.
6. **Nhật ký dùng AI (bắt buộc nếu có dùng AI):** prompt chính, nguồn đã cung cấp cho AI, những gì đã sửa và vì sao, theo mẫu `05-ai-review-log/`.

## Bảo vệ
- Trình bày: kiến trúc → 3 quyết định → demo PR vi phạm bị policy chặn.
- Câu hỏi phản biện mẫu: "Nếu ngày mai đội Data cần đọc bucket này từ một tài khoản khác thì guardrail nào phải thay đổi?", "Chỉ ra một rủi ro mà pipeline của bạn **chưa** chặn."
