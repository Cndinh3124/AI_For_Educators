# 2. Findings: output AI → lỗi → bản sửa → lý do

**Mức độ:** High = sai kiến thức được dạy, bỏ lọt kiểm soát bảo mật, hoặc đáp án chấm sai · Medium = lab/pipeline không chạy được hoặc rủi ro bảo mật có điều kiện · Low = vệ sinh/chất lượng · Info = không áp dụng/quy trình.
**Nguồn phát hiện:** Tool = công cụ độc lập · Source = mã nguồn/registry chính thức · Adversarial = thử nghiệm đối kháng/mutation · Self-review = AI tự rà soát (cần người xác nhận) · Process = lỗi thao tác của agent.

## 2.1 Bảng tổng hợp

| ID | Artifact | Output AI ban đầu | Lỗi phát hiện | Phát hiện bởi | Mức | Xử lý | Bản sửa |
|---|---|---|---|---|---|---|---|
| F-01 | Mọi file version | Kiến thức mặc định của AI: AWS provider `~> 5.x`, `actions/checkout@v4`, setup-terraform v3 | Đã lỗi thời. Hiện hành: provider 6.73.0, checkout v7.0.1, setup-terraform v4.0.1, configure-aws-credentials v6.3.0 | Source (S1, S2) | Medium | Sửa | Pin version và SHA đã kiểm **trước khi** viết bản nháp |
| F-02 | lab01 | Giả định `terraform plan` chạy được với credentials giả | `STS GetCallerIdentity 403 InvalidClientTokenId`: học viên không có AWS thì không làm được lab | Tool (terraform plan) | Medium | Sửa | `offline_override.tf.example` (skip_credentials_validation…), đổi đuôi `.example` + `.gitignore` để không lọt vào môi trường thật |
| F-03 | module | Lifecycle không có abort multipart | Checkov CKV_AWS_300 | Tool (Checkov) | Low | Sửa | `abort_incomplete_multipart_upload { days_after_initiation = 7 }` |
| F-04 | module | Không có access logging | Checkov CKV_AWS_18 | Tool (Checkov) | Medium | Sửa (thay đổi thiết kế) | Logging tùy chọn qua `var.access_log_bucket` + **rule OPA bắt buộc logging ở prod** (dùng đúng tầng: module linh hoạt, policy ép theo môi trường) |
| F-05 | module | KMS key không có key policy tường minh | Checkov CKV2_AWS_64 | Tool (Checkov) | Low | Chấp nhận rủi ro, có lý do | Policy mặc định (account root) là chủ đích; prod dùng key quản lý tập trung qua `kms_key_arn`. Lý do: `data.aws_caller_identity` phá chế độ offline. **→ Bị bác ở vòng rà soát, thay bằng H-01** |
| F-06 | module | — | CKV_AWS_144 (CRR), CKV2_AWS_62 (event notification) | Tool (Checkov) | Info | Bỏ qua, có lý do | CRR là quyết định DR theo workload (chi phí ×2); notification phụ thuộc consumer. Đưa vào ADR của capstone |
| F-07 | lab02 test | Đặt test ở một root bọc module, assert `module.bucket.aws_kms_key.this` | `Error: Unsupported attribute`: `terraform test` chỉ truy cập được resource/output của root đang được test | Tool (terraform test) | **High** | Sửa (đổi cấu trúc lab) | Chuyển test vào `modules/secure-bucket/tests/`; bổ sung 2 run; thêm cảnh báo trong README của lab02 |
| F-08 | policy `s3.rego` | `has_sibling()`: "cùng module có PAB/logging" là đủ | **Âm tính giả**: 2 bucket + 1 PAB vẫn pass (fixture `plan-adversarial.json`) | Adversarial | **High** | Sửa | `attached()`: đối chiếu `configuration.*.expressions.bucket.references`, có duyệt `module_calls` lồng nhau |
| F-09 | lab04 workflow | Gate approval qua `environment` | Người duyệt **không thấy plan** khi bấm Approve → approval chỉ còn hình thức (M9) | Self-review | Medium | Sửa | Đẩy `terraform show tfplan` vào `$GITHUB_STEP_SUMMARY` |
| F-10 | lab04 workflow | Upload `tfplan` + `plan.json` làm artifact, retention 5 ngày | File plan chứa giá trị nhạy cảm dạng plaintext; ai có quyền đọc Actions đều tải được | Self-review | **High** | Giảm thiểu + ghi rủi ro còn lại | retention 1 ngày, comment cảnh báo, đưa vào nội dung dạy (M6) và R4 mức 4 của rubric. Nhánh mở rộng: mã hóa hoặc attestation |
| F-11 | lab01 | `.terraform.lock.hcl` chỉ có checksum darwin_arm64 | Runner `ubuntu-24.04` sẽ không xác minh được checksum provider | Self-review → xác minh bằng `terraform providers lock` | Medium | Sửa | Lock cho linux_amd64, darwin_arm64, darwin_amd64, windows_amd64 |
| F-12 | validate workflow | `bash <(curl …/v1.7.12/scripts/download-actionlint.bash)` | Chạy script từ tag có thể bị dịch chuyển, không kiểm toàn vẹn (supply chain). zizmor **không** bắt được lỗi này | Self-review | Medium | Sửa | Tải tarball phát hành + `sha256sum -c` (S3) |
| F-13 | 2 workflow | `id-token: write` không có comment; thiếu `concurrency`, thiếu `name` | zizmor (auditor): undocumented-permissions, concurrency-limits, anonymous-definition | Tool (zizmor) | Low | Sửa | Comment giải thích trust policy; thêm concurrency và name |
| F-14 | (thao tác agent) | `actionlint -color=never`; chạy `mkdir` sai thư mục làm fixture rơi vào `policy/`; `brew install` gộp 4 gói fail vì 1 gói không tồn tại | Cờ không hợp lệ; file sai vị trí (conftest báo `stat policy: no such file`) | Process | Info | Sửa | Đổi sang `-no-color`; di chuyển file; cài từng gói, TFLint chạy bằng image pin theo digest |
| F-15 | Đáp án lab05 | Ghi thông báo lỗi t3 là `Error: Cycle: aws_security_group.app, aws_security_group.db` (viết theo trí nhớ) | Output thật có nhiều dòng, thứ tự khác | Tool (chạy lại) | Low | Sửa | Ghi đúng định dạng quan sát được |
| F-16 | Pre/post test A1, B1 | A1: đổi `identifier` của `aws_db_instance` → "forces replacement". B1: `aws_elasticache_replication_group` có argument `name` | Provider v6.73.0: `identifier` **không** ForceNew (đổi tên được tại chỗ); ElastiCache replication group **không có** argument `name` → **đáp án chấm sai** | Source (S5) | **High** | Sửa | A1 → `aws_dynamodb_table.name` (ForceNew, đã kiểm); B1 → `replication_group_id` (ForceNew, đã kiểm) |
| F-17 | `scripts/validate-all.sh` | Mẫu `( … ) && pass "…"` với `set -e`; kiểm tra phủ định "fixture phải bị chặn" = "conftest trả về khác 0" | Khi repo được chuyển sang thư mục có `:` trong tên, conftest/opa lỗi tải policy (coi `:` là dấu phân tách) nhưng script **vẫn in ALL CHECKS PASSED**: `set -e` không dừng trong danh sách `&&`, và *lỗi chạy* bị tính là *bị chặn* (**pass giả**) | Tool (chạy lại sau khi chuyển thư mục) | **High** | Sửa | Mọi bước dạng `cmd \|\| fail`; đường dẫn policy tương đối; `expect_denied` yêu cầu exit code = 1 **và** đúng số dòng FAIL (7 và 1); shellcheck sạch; thử sabotage (giấu `iam.rego`) để xác nhận script fail. Các kết quả PASS trước đó (thư mục không có `:`) vẫn hợp lệ: log thô cho thấy conftest đã chạy và in vi phạm thật |
| P-01 | Mục tiêu học tập | "Hiểu…", "Biết…", "Nắm vững best practice…" | Động từ không quan sát được, không có điều kiện và tiêu chí (ABCD) | Self-review | **High** | Viết lại | 8 LO theo ABCD với tiêu chí định lượng |
| P-02 | Mục tiêu học tập | Phần lớn ở cấp Understand/Apply | Lệch với yêu cầu của khóa nâng cao (Analyze/Evaluate/Create) | Self-review | **High** | Viết lại | Phân bố: 2 Analyze, 3 Evaluate, 3 Create; kiến thức nền chuyển sang K |
| P-03 | Đánh giá | "Trắc nghiệm cuối khóa + capstone" | Trắc nghiệm không đo được Create/Evaluate; không có pre-test nên không đo được tiến bộ | Self-review | **High** | Viết lại | Pre/post song song cùng blueprint, hinge, rubric 4 mức, vấn đáp |
| P-04 | Mục tiêu học tập | Thiếu | Không có mục tiêu cho "đánh giá pipeline" và "bảo vệ đánh đổi", dù brief yêu cầu | Self-review | Medium | Thêm | LO5, LO8 |

## 2.2 Vòng rà soát của giảng viên (H-xx)

**Cách các thay đổi này ra đời (ghi trung thực):** khi được hỏi *"nếu là giảng viên thật thì bạn sẽ chọn thế nào?"*, AI đóng vai giảng viên và đề xuất 6 điều chỉnh, kể cả việc bác bỏ quyết định trước đó của chính nó (F-05). Nguyễn Công Định xem xét và **chấp thuận toàn bộ** ngày 23/11/2026. Như vậy, nguồn đề xuất là AI (vai trò reviewer), còn quyết định là của con người. H-01b là lỗi mới do công cụ phát hiện khi AI thực hiện H-01.

| ID | Thay đổi | Vấn đề | Bản sửa | Kiểm chứng |
|---|---|---|---|---|
| H-01 | Bác F-05 | Lý do skip CKV2_AWS_64 là *tiện cho mình* (giữ chế độ offline), không phải *rủi ro thấp*: một tấm gương xấu trong khóa dạy về guardrail | Key policy tường minh: `kms_key_admin_arns` (bắt buộc khi module tự tạo key, có cross-variable validation) + `kms_key_user_arns` chỉ dùng qua S3 (`kms:ViaService`). Bỏ skip | Checkov 28 pass / 3 skip (CKV2_AWS_64 pass). Test 10/10; mutation `identifiers = ["*"]` làm test fail |
| H-01b | Lỗi khi thực hiện H-01 | Mock provider sinh chuỗi ngẫu nhiên cho `json` của `aws_iam_policy_document` → `"policy" contains an invalid JSON` | `override_data` với JSON hợp lệ; assert trên **input** của policy (sid, principals, condition) thay vì chuỗi đã mock (tránh test tự khẳng định chính nó) | `terraform test` 10/10 |
| H-02 | Điều chỉnh F-09 | Plan 300 dòng thì người duyệt không đọc; job summary có giới hạn kích thước | Dòng tiêu đề "N add / M change / K destroy", cảnh báo `[!WARNING]` liệt kê mọi resource bị destroy hoặc replace, plan đầy đủ thu gọn (400 dòng đầu) | actionlint, zizmor sạch; logic jq được chạy trên fixture thật (8 create) |
| H-03 | Buổi 1 | Pre-test chiếm 15/120 phút trên lớp | Pre-test làm online trước buổi; mở đầu buổi 1 bằng 2 misconception lấy từ dữ liệu pre-test của chính lớp; lab01 thêm 5 phút | Ma trận và scope cập nhật |
| H-04 | Buổi 3 | Fixture đối kháng quá khó cho người mới học Rego trong 40 phút | Lộ trình chính: 4 cờ + prod logging, có helper `attached()`; fixture đối kháng chuyển sang nhánh mở rộng và capstone | Starter qua `opa check --strict` |
| H-05 | Buổi 4 | Red-team + lab04 + 6 ticket trong 120 phút là không khả thi | 3 ticket trên lớp (t1, t5, t6, mỗi tầng một ticket), 3 ticket ở nhà | Ngưỡng đo lab05 đổi thành ≥ 2/3 |
| H-06 | Kế hoạch đo | 3 câu/LO là quá ít để kết luận gain theo LO | Ghi rõ "chỉ mang tính tham khảo", đối chiếu với rubric và lab; lần sau ≥ 5 câu/LO | — |

## 2.3 Các khẳng định của AI đã được xác minh là đúng (giữ nguyên)
| ID | Khẳng định | Cách xác minh |
|---|---|---|
| V-01 | S3 backend: `dynamodb_table` đã deprecated, thay bằng `use_lockfile` | Mã nguồn Terraform v1.16.4 (S4) |
| V-02 | Ngữ nghĩa Rego trong A4, B4, H3.1 (undefined, `not`) | `opa eval` |
| V-03 | Bộ test module bắt được regress bảo mật | Mutation: rotation=false, restrict_public_buckets=false → 2/7 run fail |
| V-04 | 6 lỗi lab05 tái hiện đúng; 6 đáp án sửa được | Chạy thật, có log |
| V-05 | `aws_dynamodb_table.name`, `replication_group_id` là ForceNew | Mã nguồn provider v6.73.0 (S5) |

## 2.4 Diff tiêu biểu

### F-08 — Âm tính giả trong policy (trước/sau)
```diff
--- v0 (AI draft)
+++ final
@@ -25,4 +25,4 @@
 	bucket.type == "aws_s3_bucket"
-	not has_sibling(bucket, "aws_s3_bucket_public_access_block")
-	msg := sprintf("%s: no aws_s3_bucket_public_access_block in the same module", [bucket.address])
+	not attached(bucket, "aws_s3_bucket_public_access_block")
+	msg := sprintf("%s: no aws_s3_bucket_public_access_block references this bucket", [bucket.address])
 }
@@ -34,3 +34,3 @@
 	bucket.change.after.tags_all.Environment == "prod"
-	not has_sibling(bucket, "aws_s3_bucket_logging")
+	not attached(bucket, "aws_s3_bucket_logging")
 	msg := sprintf("%s: prod buckets require aws_s3_bucket_logging", [bucket.address])
@@ -48,6 +48,25 @@
 
-has_sibling(res, type) if {
-	some other in changes
-	other.type == type
-	object.get(other, "module_address", "") == object.get(res, "module_address", "")
+# A companion resource (PAB, logging...) is "attached" to a bucket when its
+# `bucket` argument references that bucket in the configuration. Matching on
+# module alone is NOT enough: two buckets + one PAB would pass (see
+# fixtures/plan-adversarial.json and 05-ai-review-log, finding F-07).
+attached(bucket, type) if {
+	some cfg in config_resources
+	cfg.resource.type == type
+	cfg.module == object.get(bucket, "module_address", "")
+	some ref in cfg.resource.expressions.bucket.references
+	ref == sprintf("%s.%s", [bucket.type, bucket.name])
 }
+
+# Every resource block in the configuration, tagged with its module address
+# (e.g. "module.artifacts_bucket"), walking nested module_calls.
+config_resources contains {"module": module_address(path), "resource": r} if {
+	walk(input.configuration.root_module, [path, r])
+	count(path) >= 2
+	path[count(path) - 2] == "resources"
+}
+
+module_address(path) := concat(".", [sprintf("module.%s", [path[i + 1]]) |
+	some i
+	path[i] == "module_calls"
+])
```

### F-07 — Test tham chiếu sai phạm vi (trích)
```diff
--- v0 (AI draft)
+++ final
@@ -12 +12 @@
-    condition     = length(module.bucket.aws_kms_key.this) == 1
+    condition     = length(aws_kms_key.this) == 1
@@ -17 +17 @@
-    condition     = module.bucket.aws_kms_key.this[0].enable_key_rotation == true
+    condition     = aws_kms_key.this[0].enable_key_rotation == true
@@ -27,4 +27,4 @@
-      module.bucket.aws_s3_bucket_public_access_block.this.block_public_acls,
-      module.bucket.aws_s3_bucket_public_access_block.this.block_public_policy,
-      module.bucket.aws_s3_bucket_public_access_block.this.ignore_public_acls,
-      module.bucket.aws_s3_bucket_public_access_block.this.restrict_public_buckets,
+      aws_s3_bucket_public_access_block.this.block_public_acls,
+      aws_s3_bucket_public_access_block.this.block_public_policy,
+      aws_s3_bucket_public_access_block.this.ignore_public_acls,
```

### F-16 — Đáp án sai do kiến thức provider lỗi thời
```diff
--- v0 (AI draft)
+++ final
@@ -29,3 +29,3 @@
-# aws_db_instance.main must be replaced
--/+ resource "aws_db_instance" "main" {
-      ~ identifier = "orders-db" -> "orders-db-v2" # forces replacement
+# aws_dynamodb_table.orders must be replaced
+-/+ resource "aws_dynamodb_table" "orders" {
+      ~ name = "orders" -> "orders-v2" # forces replacement
@@ -34,2 +34,2 @@
-- A. Database được đổi tên tại chỗ, dữ liệu giữ nguyên
-- B. **Database cũ bị hủy và một database mới (rỗng) được tạo, trừ khi có snapshot hoặc deletion protection chặn lại** ✔
+- A. Bảng được đổi tên tại chỗ, dữ liệu giữ nguyên
+- B. **Bảng cũ bị xóa và một bảng mới (rỗng) được tạo, trừ khi `deletion_protection_enabled` chặn lại (khi đó apply fail)** ✔
@@ -37 +37 @@
-- D. Apply bị từ chối vì `identifier` là thuộc tính bất biến
+- D. Apply bị từ chối ngay ở bước plan vì `name` là thuộc tính bất biến
@@ -118 +118 @@
-**B1.** Plan: `~ name = "app-cache" -> "app-cache-2" # forces replacement` trên `aws_elasticache_replication_group.cache`. Hệ quả: **cluster cũ bị hủy và cluster mới được tạo, dữ liệu cache mất** ✔ / đổi tên tại chỗ / chỉ cập nhật state / apply bị từ chối.
+**B1.** Plan: `~ replication_group_id = "app-cache" -> "app-cache-2" # forces replacement` trên `aws_elasticache_replication_group.cache`. Hệ quả: **cluster cũ bị hủy và cluster mới được tạo, dữ liệu cache mất** ✔ / đổi tên tại chỗ / chỉ cập nhật state / apply bị từ chối.
```

### F-09 / F-10 / F-13 — Workflow (toàn bộ thay đổi)
```diff
--- v0 (AI draft)
+++ final
@@ -66 +66 @@
-      - name: opa unit tests
+      - name: setup opa
@@ -70 +70,3 @@
-      - run: opa test policy -v
+
+      - name: opa unit tests
+        run: opa test policy -v
@@ -78 +80 @@
-      id-token: write
+      id-token: write # OIDC -> AWS STS; plan role is read-only + state lock, trust policy pinned to this repo
@@ -108,0 +111,10 @@
+      - name: publish plan to job summary (what the approver reviews)
+        working-directory: ${{ env.WORKDIR }}
+        run: |
+          {
+            echo '### terraform plan'
+            echo '```'
+            terraform show -no-color tfplan
+            echo '```'
+          } >> "$GITHUB_STEP_SUMMARY"
+
@@ -112,0 +125,3 @@
+      # NOTE: a saved plan file contains sensitive values in plaintext. Keep the repo
+      # private, retention minimal, and never put secrets in Terraform variables
+      # that land in state/plan (see 05-ai-review-log finding F-10).
@@ -119 +134 @@
-          retention-days: 5
+          retention-days: 1
@@ -126 +141 @@
-    environment: dev
+    environment: dev # required reviewers configured on this environment = human approval gate
@@ -129 +144 @@
-      id-token: write
+      id-token: write # OIDC -> AWS STS; apply role trust policy allows only environment:dev
```

### F-12 / F-13 — Validate workflow
```diff
--- v0 (AI draft)
+++ final
@@ -9,0 +10,4 @@
+concurrency:
+  group: validate-${{ github.ref }}
+  cancel-in-progress: true
+
@@ -11,0 +16 @@
+    name: validate evidence repo
@@ -45 +50,4 @@
-          bash <(curl -sSfL https://raw.githubusercontent.com/rhysd/actionlint/v1.7.12/scripts/download-actionlint.bash) 1.7.12
+          curl -sSfL -o actionlint.tgz \
+            "https://github.com/rhysd/actionlint/releases/download/v1.7.12/actionlint_1.7.12_linux_amd64.tar.gz"
+          echo "8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8  actionlint.tgz" | sha256sum -c -
+          tar -xzf actionlint.tgz actionlint
```

### P-01..P-04 — Mục tiêu học tập
Bản v0 (nguyên văn trong `drafts/objectives.v0.md`): 8 mục tiêu dạng "Hiểu/Biết/Viết/Nắm vững…", đánh giá = "trắc nghiệm cuối khóa + capstone".
Bản cuối: `01-design/02-kud-objectives.md`. Ánh xạ: v0#1 → LO1 · v0#2, #3 → LO2/LO3 · v0#4 → K3 (không còn là mục tiêu) · v0#5 → LO4 · v0#6 → LO6 · v0#7 → **loại** (không đo được) · v0#8 → LO7 · **mới:** LO5, LO8.
