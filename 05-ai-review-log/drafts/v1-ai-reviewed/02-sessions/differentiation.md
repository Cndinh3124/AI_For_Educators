# Phân hóa

Phân nhóm dựa trên **pre-test** (theo từng LO, không theo tổng điểm) và quan sát hinge question trong buổi.

| Tín hiệu | Nhóm | Hỗ trợ |
|---|---|---|
| Pre-test ≤ 40% **hoặc** sai ≥ 2 hinge liên tiếp | **Cần scaffold thêm** | Xem bên dưới |
| 40–75% | Lộ trình chính | Lab như thiết kế |
| ≥ 75% **và** hoàn thành lab trước 2/3 thời gian | **Nhánh mở rộng** | Xem bên dưới |

## Scaffold bổ sung (người học chậm hơn)
| Buổi | Scaffold |
|---|---|
| S0 (trước B1) | Gói "HCL in 30 minutes" + bài tập `for_each` có đáp án |
| B1 | Bản lab01 có chú thích từng dòng; bảng tra "action → ký hiệu plan" (`+`, `-`, `~`, `-/+`) |
| B2 | Assert mẫu cho 1 `run`, học viên viết theo cho 2 `run` còn lại (completion problem) |
| B3 | Khung rule có chỗ trống (`deny contains msg if { some rc in input.resource_changes; ____ }`) + bảng tra `jq` cho plan JSON |
| B4 | Thang gợi ý 3 bậc cho mỗi ticket lab05: (1) "lỗi nằm ở tầng nào?"; (2) "đọc dòng `Error:` đầu tiên và tài liệu của argument đó"; (3) gợi ý gần như đáp án. Mỗi bậc gợi ý được dùng sẽ trừ một phần điểm thời gian, không trừ điểm hoàn thành |
| Chung | Ghép cặp với học viên nhóm mở rộng ở lab05 (người chậm hơn cầm bàn phím) |

## Nhánh mở rộng (người học nhanh)
| Buổi | Thử thách |
|---|---|
| B1 | Tách state theo blast radius: thiết kế 2 root module (`network/`, `app/`) nối nhau bằng `terraform_remote_state` hoặc data source. Viết ADR 1 trang về đánh đổi |
| B2 | Viết test **tích hợp** dùng `command = apply` với `override_resource` cho KMS; so sánh với mock provider |
| B3 | Rule chặn `NotAction` / `NotResource` trong IAM; dùng `every` và metadata `# METADATA` để sinh báo cáo; tích hợp ngoại lệ có hạn dùng qua `data.exceptions` |
| B4 | Thêm job drift detection theo lịch (`schedule:` + `terraform plan -detailed-exitcode`), báo lỗi khi exit code = 2; đánh giá đánh đổi giữa tần suất chạy, chi phí và độ nhiễu |
| Capstone | Thêm ký số và xác minh provenance của plan artifact (attestation), hoặc mã hóa artifact |
