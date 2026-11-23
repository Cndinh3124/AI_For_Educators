# Lab02 — Kiểm thử module (Buổi 2, scaffold vừa)

**Mục tiêu:** LO2, LO3 · **Thời gian:** 40 phút

> Test phải đặt **trong thư mục module** (`modules/secure-bucket/tests/`). `terraform test` chỉ cho assert vào resource/output của **root module đang được test**. Nếu đặt test ở một root bọc module bên ngoài thì gặp lỗi `Unsupported attribute` (đây chính là lỗi của bản nháp AI, log F-07).

1. Copy `starter/secure_bucket.tftest.hcl` vào `../modules/secure-bucket/tests/`.
2. Điền các chỗ `# TODO`. Chạy `terraform init && terraform test` trong thư mục module.
3. **Mutation test:** sửa trong `main.tf`: `enable_key_rotation = false`, `restrict_public_buckets = false`. Chạy test và ghi lại test nào fail. Nếu không có test nào fail, bộ test của bạn chưa đủ.
4. Khôi phục `main.tf`. Viết thêm 1 `run` cho một rủi ro bạn tự xác định.

Lời giải tham khảo: `../modules/secure-bucket/tests/secure_bucket.tftest.hcl` (7 run; mutation làm 2 run fail, đã kiểm chứng).
