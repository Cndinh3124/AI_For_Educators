# Buổi 4 — Pipeline, quản trị & xử lý sự cố

**LO:** LO5, LO6 (Evaluate/Create), LO7 (Analyze) · **Big idea:** U1, U3, U5

| Phút | Hoạt động | Mô tả | Kiểm tra hiểu |
|---|---|---|---|
| 0–10 | **Retrieval** | K3 (cú pháp `deny contains msg if`), K4 (lock file đa nền tảng), U1 | |
| 10–30 | **Red-team một pipeline** | Nhóm 3 người nhận workflow "xấu": dùng access key dài hạn, `permissions` mặc định, action pin theo tag, apply chạy `terraform apply -auto-approve` không dùng plan đã lưu, không có policy gate. Mỗi nhóm tìm, **xếp hạng rủi ro**, rồi đối chiếu với bản tốt ở `03-labs/lab04-ci` | LO5. Mỗi nhóm trình bày 1 phút |
| 30–35 | **Hinge H4.1** | OIDC trust policy | |
| 35–60 | **Lab04 (fading bước 4)** | Học viên lắp workflow theo danh sách yêu cầu, chạy `actionlint` và `zizmor --persona=auditor` đến khi sạch | Autograde |
| 60–65 | **Hinge H4.2** | Stale plan | |
| 65–110 | **Lab05: troubleshooting (không có scaffold)** | 6 ticket (t1–t6), đặt thứ tự **xen kẽ** các loại lỗi. Làm theo cặp, ghi theo mẫu: *Triệu chứng → Giả thuyết tầng lỗi → Bằng chứng → Sửa → Guardrail phòng tái diễn* | LO7. GV ghi thời gian từng ticket |
| 110–120 | **Exit ticket + giao capstone** | "Xếp hạng 3 rủi ro lớn nhất còn lại trong pipeline của lab04 và vì sao." | |

## Danh sách yêu cầu Lab04 (đối chiếu `03-labs/lab04-ci/.github/workflows/terraform.yml`)
1. `permissions: {}` ở cấp workflow; mỗi job chỉ xin quyền tối thiểu.
2. Mọi `uses:` pin theo SHA 40 ký tự, kèm comment ghi tag.
3. `persist-credentials: false` khi checkout.
4. OIDC (`id-token: write`) có comment giải thích; plan role và apply role **tách riêng**.
5. Plan → `terraform show -json` → conftest gate → đẩy plan lên job summary.
6. Apply chỉ chạy trên `main`, qua `environment` có required reviewers, và apply **đúng file plan** đã gate.
7. Công cụ tải về (conftest) phải được kiểm tra bằng SHA-256.
8. Nêu rủi ro artifact plan chứa secret và cách giảm thiểu (log F-10).

## Lab05: thẻ ticket (học viên chỉ thấy phần này)
| Ticket | Triệu chứng người dùng báo |
|---|---|
| t1 | "CI fail ngay sau khi chuyển 1 bucket thành danh sách bucket." |
| t2 | "Môi trường mới plan fail, workspace dev cũ thì vẫn chạy." |
| t3 | "SG app và db cần cho phép lẫn nhau, plan báo lỗi." |
| t4 | "Nâng root lên AWS provider 6.x thì `init` fail." |
| t5 | "PR refactor đổi tên vô hại mà plan đòi destroy." (chạy `setup.sh` trước) |
| t6 | "Policy gate chặn PR vì thiếu tag, nhưng module có set tag mà!" |

Đáp án dành cho GV: `03-labs/lab05-troubleshooting/INSTRUCTOR-KEY.md` (mọi đáp án đã được chạy thật, xem `05-ai-review-log/validation-runs.log`).
