# Lab01 — Module & State (Buổi 1, scaffold cao)

**Mục tiêu:** LO1, LO2 · **Thời gian:** 40 phút

1. Đọc `main.tf` và `../modules/secure-bucket/*.tf`.
2. Chạy plan offline (xem `../README.md`). Kỳ vọng: `Plan: 8 to add`.
3. **Giải thích** (viết vào `ANSWERS.md`): mỗi resource trong 8 resource bảo vệ khỏi rủi ro nào?
4. **Sửa 1:** thêm biến `force_destroy` (bool, mặc định `false`) vào module, kèm validation không cho `true` khi `environment == "prod"`.
5. **Sửa 2:** thêm output `bucket_regional_domain_name`.
6. Chạy lại `terraform validate`, plan và conftest. Cả ba phải pass.

**Backend:** `backend.hcl.example` dùng `use_lockfile = true` (Terraform ≥ 1.10). `.terraform.lock.hcl` đã được tạo checksum cho linux_amd64, darwin_arm64, darwin_amd64, windows_amd64 để runner CI xác minh được provider (log F-11).
