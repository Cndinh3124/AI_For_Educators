# 1. Prompt chính & nguồn đã neo (source-grounded prompting)

## 1.1 Prompt gốc (brief do người hướng dẫn viết)
Brief đầy đủ do Nguyễn Công Định soạn, tóm tắt các ràng buộc then chốt:
- **Vai trò và mục tiêu:** thiết kế khóa DevOps nâng cao làm evidence cho 5 kỹ năng (source-grounded prompting, objective alignment, session planning, activity & assessment design, AI output review).
- **Người học:** 1–3 năm kinh nghiệm; 4 buổi × 2 giờ + capstone.
- **Thành phần bắt buộc:** 9 mục (phân tích người học → evidence summary).
- **Ràng buộc kỹ thuật:** manifest/workflow phải validate được, dùng API version hiện hành, pin version/SHA, **không** có thông tin nội bộ.
- **Quyết định của người hướng dẫn trong phiên:** chủ đề = *Terraform + Policy as Code*; log = *ghi log thật của phiên*; lưu trữ = thư mục phiên.

## 1.2 Gói nguồn (source packet) đã dùng để neo output
Khác với chat thông thường (dán tài liệu vào prompt), trong phiên agent AI được yêu cầu **tự truy xuất nguồn gốc chính thức theo đúng version** trước khi khẳng định. Các nguồn đã thực sự dùng:

| # | Nguồn | Cách truy xuất | Dùng để neo |
|---|---|---|---|
| S1 | Terraform Registry API: `registry.terraform.io/v1/providers/hashicorp/aws` | HTTP GET | Version provider hiện hành (6.73.0), từ đó sửa ràng buộc `~> 5.x` cũ trong kiến thức của AI (F-01) |
| S2 | Tag phát hành của 8 GitHub Action (`git ls-remote --tags`) | Git | SHA 40 ký tự + tag cho mọi `uses:` (F-01) |
| S3 | `checksums.txt` của bản phát hành Conftest 0.71.1, actionlint 1.7.12 | HTTP GET | SHA-256 cho bước cài công cụ trong CI (F-12) |
| S4 | Mã nguồn Terraform **v1.16.4**: `internal/backend/remote-state/s3/backend.go` | raw.githubusercontent.com tại tag | Xác nhận `dynamodb_table` có `Deprecated: true` và `use_lockfile` (V-01) |
| S5 | Mã nguồn terraform-provider-aws **v6.73.0**: `rds/instance.go`, `dynamodb/table.go`, `elasticache/replication_group.go` | raw.githubusercontent.com tại tag | Kiểm thuộc tính nào là ForceNew trong câu hỏi đánh giá (F-16, V-05) |
| S6 | Output thật của công cụ: `terraform validate/plan/test`, `opa check/test/eval`, `conftest`, TFLint, Checkov, `actionlint`, `zizmor` | Chạy cục bộ | Bằng chứng khách quan cho mọi finding F-xx |
| S7 | Plan JSON thật (`terraform show -json`, `format_version` 1.2) | Sinh từ lab | Fixture cho policy; đáp án hinge H1.1 |

> **Bài học về neo nguồn:** tài liệu web dạng "latest" thay đổi liên tục. Nên neo vào **tag/version cụ thể** (S4, S5) thay vì trang docs không có version.

## 1.3 Các prompt làm việc (theo artifact)
Mỗi artifact được tạo theo mẫu: *Đặc tả + Ràng buộc + Nguồn + Tiêu chí chấp nhận có thể kiểm bằng công cụ*.

| Artifact | Prompt làm việc (rút gọn) | Tiêu chí chấp nhận (máy kiểm được) |
|---|---|---|
| Module `secure-bucket` | "Viết module S3 baseline cho AWS provider `~> 6.0` (S1): SSE-KMS, chặn public 4 cờ, versioning, lifecycle, TLS-only; biến có validation; không có giá trị nội bộ." | `fmt`, `validate`, plan offline, TFLint (aws ruleset), Checkov |
| `terraform test` | "Viết test bằng mock provider cho các bất biến bảo mật, có ca bị từ chối." | `terraform test` pass **và** mutation test làm test fail |
| Policy Rego | "Viết rule Rego v1 trên plan JSON (S7) cho S3/tag/IAM/blast radius; có unit test; có fixture compliant và noncompliant sinh từ plan thật." | `opa check --strict`, `opa test`, conftest đúng kỳ vọng trên 3 fixture |
| Workflow | "Workflow plan → conftest gate → approval → apply đúng plan; OIDC; `permissions` tối thiểu; pin SHA (S2); checksum (S3)." | `actionlint` (+shellcheck), `zizmor --persona=auditor` |
| Lab05 | "Tạo 6 lỗi thuộc các tầng khác nhau; mỗi lỗi phải tái hiện được và mỗi đáp án phải được chạy thử." | Lỗi fail đúng thông báo; bản sửa pass |
| Câu hỏi đánh giá | "Câu hỏi dạng tình huống; phương án nhiễu tương ứng misconception; đáp án phải kiểm được bằng nguồn S5 hoặc `opa eval`." | Đối chiếu S5; `opa eval` |

## 1.4 Template prompt tái sử dụng (cho người dạy khác)
```text
VAI TRÒ: Bạn là kỹ sư platform kiêm người thiết kế bài học.
NGUỒN DUY NHẤT ĐƯỢC DÙNG: <dán trích đoạn docs/schema/mã nguồn tại version X.Y.Z>
Nếu nguồn không đủ để khẳng định, hãy viết "KHÔNG CHẮC – cần kiểm" thay vì đoán.
NHIỆM VỤ: <artifact>
RÀNG BUỘC: version <...>; pin SHA; không có dữ liệu nội bộ; tiếng Việt, thuật ngữ giữ tiếng Anh.
TIÊU CHÍ CHẤP NHẬN: <lệnh kiểm tra cụ thể, ví dụ `opa check --strict`, `actionlint`>
ĐẦU RA: (1) artifact; (2) danh sách khẳng định kỹ thuật kèm nguồn trong NGUỒN cho từng khẳng định;
(3) những điểm bạn KHÔNG chắc.
```
