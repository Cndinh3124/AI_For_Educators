# 3. Thống kê: AI giữ nguyên / chỉnh sửa / loại bỏ

## 3.1 Theo dòng (code, test, câu hỏi). Tính bằng diff thật giữa `drafts/` và bản cuối
Phương pháp: `difflib.SequenceMatcher` trên các dòng không rỗng. *Giữ* = dòng giống hệt; *sửa* = dòng bị thay; *bỏ* = dòng v0 bị xóa không có dòng thay thế; *thêm* = dòng mới do quá trình review sinh ra. Output thô: `diffstats.txt`.

| Artifact | Dòng v0 | Giữ | Sửa | Bỏ | Thêm khi review |
|---|---:|---:|---:|---:|---:|
| Module secure-bucket | 138 | 138 (100%) | 0 | 0 | 19 |
| Root lab01 | 35 | 35 (100%) | 0 | 0 | 0 |
| `terraform test` | 52 | 45 (87%) | 7 (13%) | 0 | 17 |
| Policy Rego | 107 | 100 (93%) | 7 (7%) | 0 | 17 |
| Workflow lab04 | 130 | 124 (95%) | 6 (5%) | 0 | 13 |
| Workflow validate | 41 | 40 (98%) | 1 (2%) | 0 | 7 |
| Pre/post test | 113 | 106 (94%) | 7 (6%) | 0 | 0 |
| **Tổng** | **616** | **588 (95.5%)** | **28 (4.5%)** | **0 (0%)** | **73 (+11.9%)** |

## 3.2 Theo mục (mục tiêu học tập, so v0 với bản cuối)
| | Số mục | Tỉ lệ |
|---|---:|---:|
| Giữ nguyên | 0 / 8 | 0% |
| Chỉnh sửa (viết lại theo ABCD/Bloom) | 6 / 8 | 75% |
| Loại bỏ | 2 / 8 | 25% |
| Thêm mới | 2 | — |

## 3.3 Theo mức độ nghiêm trọng (21 finding trong output AI, gồm F-17 phát hiện sau)
| Mức | Số lượng | ID |
|---|---:|---|
| High | 8 | F-07, F-08, F-10, F-16, F-17, P-01, P-02, P-03 |
| Medium | 7 | F-01, F-02, F-04, F-09, F-11, F-12, P-04 |
| Low | 4 | F-03, F-05, F-13, F-15 |
| Info | 2 | F-06, F-14 |

| Nguồn phát hiện | Số lượng |
|---|---:|
| Công cụ độc lập (Tool) | 9 |
| Mã nguồn / registry chính thức (Source) | 2 |
| Thử nghiệm đối kháng (Adversarial) | 1 |
| AI tự rà soát (Self-review) | 8 |
| Lỗi thao tác của agent (Process) | 1 |

## 3.4 Vòng rà soát của giảng viên (v1 → v2, H-01…H-06)
Snapshot v1 trong `drafts/v1-ai-reviewed/`. Output thô: `diffstats-review-stage.txt`.

| Artifact | Dòng v1 | Giữ | Sửa | Bỏ | Thêm |
|---|---:|---:|---:|---:|---:|
| Module secure-bucket (kèm test) | 226 | 222 (98%) | 3 (1%) | 1 (0%) | 93 |
| Root lab01 | 35 | 33 (94%) | 2 (6%) | 0 | 6 |
| Workflow lab04 | 143 | 141 (99%) | 2 (1%) | 0 | 12 |
| Kế hoạch buổi học | 112 | 103 (92%) | 9 (8%) | 0 | 1 |

Thay đổi chủ yếu là **thêm** (key policy + 3 test mới, job summary) và **thu hẹp phạm vi** (sửa ít dòng nhưng làm thay đổi đáng kể khối lượng học tập).

## 3.5 Diễn giải: vì sao "95,5% giữ nguyên" **không** có nghĩa là "AI đúng 95,5%"
- 28 dòng bị sửa (4,5%) chứa **4 lỗi High về mặt kỹ thuật**: một kiểm soát bảo mật bị vượt qua (F-08), một cấu trúc lab sai về nguyên lý (F-07), dữ liệu nhạy cảm bị lộ qua artifact (F-10), và đáp án chấm sai (F-16). Tỉ lệ dòng đo **khối lượng** chỉnh sửa, không đo **rủi ro**.
- 73 dòng *thêm* (+11,9%) phần lớn là guardrail mà bản nháp bỏ sót: logging, abort multipart, step summary, checksum, comment quyền.
- Ở tầng sư phạm thì ngược lại: 0% mục tiêu được giữ nguyên. AI viết code "chạy được" tốt hơn nhiều so với viết mục tiêu "đo được".
- Phần tài liệu buổi học, rubric và hướng dẫn không có snapshot v0 riêng (viết sau khi đã có các finding ở trên), nên không đưa vào bảng 3.1. Các lỗi phát hiện trong phần này (F-15) được ghi riêng.
