# Hinge questions (giữa buổi)

Cách dùng: cả lớp trả lời **cùng lúc** (thẻ A/B/C/D hoặc poll) trong ≤ 2 phút. GV nhìn kết quả trong 30 giây rồi quyết định:
- ≥ 80% đúng: đi tiếp.
- 50–80%: cho thảo luận cặp 2 phút, rồi hỏi lại.
- < 50%: giảng lại bằng một ví dụ khác.

Mỗi phương án nhiễu được thiết kế để **chẩn đoán đúng một misconception**. Cột cuối cho GV biết học viên chọn sai phương án nào thì đang hiểu sai điều gì.

| ID | Câu hỏi | Đáp án | Chẩn đoán phương án nhiễu |
|---|---|---|---|
| **H1.1** | Trong plan JSON, resource sắp bị *replace* có `change.actions` là gì? A. `["update"]` B. `["delete","create"]` hoặc `["create","delete"]` C. `["replace"]` D. `["no-op"]` | **B** | A: nhầm update tại chỗ với replace. C: tưởng có action "replace" (không tồn tại). D: chưa nắm được cấu trúc |
| **H1.2** | Xóa file state local rồi chạy `plan` với cấu hình không đổi (resource đã tồn tại trên AWS). Kết quả? A. No changes B. Plan tạo mới mọi resource, apply sẽ lỗi trùng tên hoặc tạo trùng C. Terraform tự import D. Lỗi cú pháp | **B** | A: M2 (state là cache). C: tưởng có auto-import. D: nhầm tầng lỗi |
| **H2.1** | `for_each = toset(["a","b","c"])`, xóa `"b"`. Plan? A. Xóa `["b"]` B. Thay thế `["c"]` C. Xóa phần tử cuối D. Lỗi | **A** | B, C: mang tư duy index của `count` sang (M4). D: chưa hiểu set |
| **H2.2** | Root `~> 6.0`, module `>= 6.20`. Init chọn gì nếu bản mới nhất là 6.73.0? A. 6.0.0 B. 6.20.0 C. **6.73.0** D. Lỗi | **C** | A, B: nghĩ Terraform chọn bản *thấp nhất* thỏa mãn. D: M10 |
| **H3.1** | `deny contains m if { some r in input.resource_changes; r.change.after.acl == "public-read"; m := r.address }`. Với resource có `after = {}`: A. deny B. **không deny** C. lỗi D. warn | **B** | A: nghĩ thiếu trường thì coi như vi phạm. Cần hiểu "undefined thì điều kiện fail" và khi nào phải dùng `not` hoặc `object.get` |
| **H3.2** | Rule "plan xóa > 5 resource" nên là? A. deny B. **warn + yêu cầu người review** C. bỏ D. deny chỉ ở dev | **B** | A: không cân nhắc dương tính giả (refactor hợp lệ). D: đảo ngược mức độ rủi ro giữa môi trường (U5) |
| **H4.1** | Job dùng `environment: prod`. Claim `sub` trong OIDC token có dạng? A. `repo:org/r:ref:refs/heads/main` B. **`repo:org/r:environment:prod`** C. `repo:org/r:pull_request` D. `org/r` | **B** | A: không biết `environment` thay đổi định dạng `sub`, nên trust policy viết sai và assume role bị từ chối |
| **H4.2** | Plan được lưu lúc 9h, approval lúc 15h, giữa chừng có một apply khác chạy. `terraform apply tfplan`? A. Apply bình thường B. **Lỗi "Saved plan is stale"** C. Tự plan lại D. Apply một phần | **B** | A: nghĩ plan không gắn với phiên bản state. C, D: chưa hiểu cơ chế bảo vệ. Điểm thảo luận: đây là hành vi *an toàn*; pipeline phải xử lý bằng cách chạy lại plan |

## Ghi chú kiểm chứng
- H3.1 được kiểm bằng `opa eval` (resource có `after = {}` không bị deny).
- Đáp án H1.1 khớp với spec định dạng plan JSON (`format_version` 1.2, được sinh thật trong lab).
