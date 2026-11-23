# 05 — AI Usage & Review Log

Đây là phần cốt lõi của evidence. Phần này ghi lại **cách AI được dùng** để soạn khóa học và **cách output của AI được kiểm soát chất lượng** trước khi đưa vào tài liệu dạy.

## Bối cảnh dùng AI (công khai minh bạch)
| Mục | Chi tiết |
|---|---|
| Công cụ AI | Trợ lý AI dạng coding agent (mô hình ngôn ngữ lớn): tự soạn file, chạy lệnh và công cụ kiểm tra |
| Ngày | 23/11/2026, một phiên làm việc |
| Người chịu trách nhiệm | Nguyễn Công Định: đặt brief, chọn chủ đề, chọn phương án ghi log, **rà soát và ký duyệt cuối** (`05-human-signoff.md`) |
| Phạm vi AI tạo | Bản nháp của toàn bộ code lab, policy, workflow, tài liệu thiết kế, câu hỏi đánh giá |
| Nguyên tắc | Không có output AI nào được coi là đúng chỉ vì AI viết ra. Mỗi khẳng định kỹ thuật phải qua ít nhất một trong các bước: **(a)** công cụ kiểm tra tự động, **(b)** đối chiếu nguồn gốc chính thức theo version cụ thể, **(c)** thử nghiệm đối kháng/mutation |

## Cấu trúc
| File | Nội dung |
|---|---|
| [`01-prompts-and-sources.md`](01-prompts-and-sources.md) | Prompt chính, gói nguồn (source packet) đã dùng để "neo" AI, template prompt tái sử dụng |
| [`02-findings.md`](02-findings.md) | 21 phát hiện trong output AI + 7 điều chỉnh vòng rà soát giảng viên (H-xx): output ban đầu → lỗi → bản sửa → lý do (kèm diff) |
| [`03-summary-stats.md`](03-summary-stats.md) | Tỉ lệ giữ / sửa / bỏ (tính bằng diff thật) + thống kê theo mức độ nghiêm trọng |
| [`04-lessons-learned.md`](04-lessons-learned.md) | Giới hạn của AI khi soạn nội dung kỹ thuật và quy trình kiểm soát rút ra |
| [`05-human-signoff.md`](05-human-signoff.md) | Checklist rà soát của người chịu trách nhiệm |
| `drafts/` | **Bản nháp v0 nguyên văn** của AI, giữ để đối chiếu |
| `validation-runs.log` | Output thô của mọi lần chạy công cụ trong phiên (kể cả các lần fail) |
| `final-validation.txt` | Output của `scripts/validate-all.sh` trên bản cuối |
| `diffstats.txt`, `diffstats-review-stage.txt` | Output thô của script tính diff (v0→v1, v1→v2) |

## Phân biệt nguồn phát hiện lỗi (để đánh giá đúng độ tin cậy)
- **Tool / Source / Adversarial** (F-01…F-08, F-13, F-15, F-16): lỗi do công cụ độc lập (terraform, conftest, Checkov, zizmor, …) hoặc mã nguồn chính thức phát hiện. Bằng chứng khách quan nằm trong `validation-runs.log`.
- **AI self-review** (F-09…F-12, P-01…P-04): do AI tự rà soát bản nháp theo checklist chuyên môn. Loại này **cần người xác nhận** nên được đánh dấu trong `05-human-signoff.md`.
- **Process** (F-14): lỗi thao tác của chính agent khi chạy lệnh. Được ghi lại để cho thấy vì sao cần giám sát agent.
