# Production-grade Infrastructure as Code: Terraform + Policy as Code

**An advanced DevOps course designed with AI and reviewed by a human, submitted as evidence for the OpenAI Academy "AI for Educators" certificate.**
Author: Nguyễn Công Định, DevOps Engineer · Course materials in Vietnamese · Verified 23 Nov 2026

## Evidence summary (for Accredible)

> I designed a 4-session (4×2h) advanced course with a capstone, *Production-grade IaC: Terraform + Policy as Code*, for engineers with 1–3 years of experience. I used backward design: KUD, eight ABCD objectives at Analyze/Evaluate/Create levels, and an objective–activity–assessment matrix. Each session includes retrieval practice, worked examples, faded-scaffold labs, hinge questions and exit tickets. Assessment uses parallel pre/post tests on one blueprint, a capstone with a 4-level rubric, and differentiation paths. All labs run offline and pass terraform test, OPA, Checkov, actionlint and zizmor. I grounded the AI in pinned official sources, logged 21 defects in its output (8 high-severity), and then made 6 instructor-review changes, including reversing one AI decision.


## What this repository demonstrates

| Course skill | Where to look |
|---|---|
| Source-grounded prompting | [`05-ai-review-log/01-prompts-and-sources.md`](05-ai-review-log/01-prompts-and-sources.md): version-pinned source packet (registry API, release tags, Terraform v1.16.4 and AWS provider v6.73.0 source) |
| Learning objective alignment | [`01-design/02-kud-objectives.md`](01-design/02-kud-objectives.md), [`01-design/03-alignment-matrix.md`](01-design/03-alignment-matrix.md) |
| Session planning | [`01-design/04-scope-sequence.md`](01-design/04-scope-sequence.md), [`02-sessions/`](02-sessions) |
| Activity & assessment design | [`03-labs/`](03-labs), [`04-assessment/`](04-assessment) |
| AI output review | [`05-ai-review-log/02-findings.md`](05-ai-review-log/02-findings.md): v0 draft → defect → fix → rationale, with real diffs and raw tool logs |

## Repository layout

```
01-design/        learner analysis, misconceptions, KUD + objectives, alignment matrix, scope & sequence, evaluation plan
02-sessions/      4 session plans (timed) + differentiation
03-labs/          runnable labs: secure-bucket module, terraform test, Rego policies + fixtures, GitHub Actions pipeline, 6 seeded incidents
04-assessment/    parallel pre/post tests + blueprint, hinge questions, capstone brief, 4-level rubric, validity check
05-ai-review-log/ prompts & sources, 21 findings + 6 review changes, keep/modify/remove stats, lessons learned, human sign-off, v0 drafts, raw logs
scripts/          validate-all.sh: re-runs every check claimed here
```

## AI review in numbers

| Metric | Value |
|---|---|
| Code/test/quiz lines drafted by AI | 616 |
| Kept / modified / removed | 95.5% / 4.5% / 0% (+73 lines added during review) |
| Learning objectives kept unchanged | 0 of 8 (6 rewritten, 2 removed, 2 added) |
| Findings in AI output | 21 (8 high · 7 medium · 4 low · 2 info) |
| Instructor-review changes | 6 (H-01…H-06), e.g. reversing an AI-accepted risk (implicit KMS key policy) and cutting session scope to fit 2 hours |
| Notable high-severity catches | A policy that let unprotected buckets through (false negative), a structurally wrong test lab, plaintext secrets in plan artifacts, quiz answer keys based on outdated provider behaviour, a validation script that could report a false PASS |

The line percentages measure **volume**, not **risk**: the 4.5% of modified lines contained four high-severity technical defects. See [`03-summary-stats.md`](05-ai-review-log/03-summary-stats.md).

## Verify it yourself

```bash
./scripts/validate-all.sh   # terraform fmt/validate/test, offline plan + conftest, opa test, tflint, checkov, actionlint, zizmor, seeded-fault checks
```
Requirements: Terraform ≥ 1.10, OPA, Conftest, actionlint, shellcheck, zizmor, Docker. **No AWS account needed.** Last run: [`05-ai-review-log/final-validation.txt`](05-ai-review-log/final-validation.txt).

## Scope & constraints
- No employer-internal information. The sample service ("doc-intake") is fictional, and all names are placeholders.
- Every GitHub Action is pinned to a full commit SHA; container images are pinned by digest; downloaded tools are checksum-verified.
- This is a course **design**. It has not been taught yet, so [`01-design/05-evaluation-plan.md`](01-design/05-evaluation-plan.md) is a measurement plan, not results.
- AI tool used: an LLM-based coding agent (drafting files, running commands and validators). Final review and sign-off: the author ([`05-human-signoff.md`](05-ai-review-log/05-human-signoff.md)).
