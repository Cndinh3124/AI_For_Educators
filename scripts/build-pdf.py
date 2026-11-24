#!/usr/bin/env python3
"""Build the combined evidence PDF: Markdown -> styled HTML -> Chrome headless print.
Usage: python3 scripts/build-pdf.py   (needs: pip install markdown pygments; Google Chrome)"""
import html, pathlib, re, subprocess, sys
import markdown

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT_HTML = ROOT / "build" / "evidence.html"
OUT_PDF = ROOT / "AI-for-Educators-Evidence_Nguyen-Cong-Dinh.pdf"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

PARTS = [
    ("Overview", ["README.md"]),
    ("Part 1 — Thiết kế khóa học", ["01-design/01-learner-analysis.md", "01-design/02-kud-objectives.md",
        "01-design/03-alignment-matrix.md", "01-design/04-scope-sequence.md"]),
    ("Part 2 — Kế hoạch buổi học", ["02-sessions/session-1-state-plan-modules.md", "02-sessions/session-2-testing-refactoring.md",
        "02-sessions/session-3-policy-as-code.md", "02-sessions/session-4-pipeline-governance.md", "02-sessions/differentiation.md"]),
    ("Part 3 — Lab thực hành", ["03-labs/README.md", "03-labs/lab01-module-state/README.md", "03-labs/lab02-testing/README.md",
        "03-labs/lab03-policy/README.md", "03-labs/lab04-ci/README.md", "03-labs/lab05-troubleshooting/README.md",
        "03-labs/lab05-troubleshooting/INSTRUCTOR-KEY.md"]),
    ("Part 4 — Hệ thống đánh giá", ["04-assessment/01-pre-post-test.md", "04-assessment/02-hinge-questions.md",
        "04-assessment/03-capstone-brief.md", "04-assessment/04-capstone-rubric.md", "04-assessment/05-validity-check.md"]),
    ("Part 5 — AI Usage & Review Log", ["05-ai-review-log/README.md", "05-ai-review-log/01-prompts-and-sources.md",
        "05-ai-review-log/02-findings.md", "05-ai-review-log/03-summary-stats.md", "05-ai-review-log/04-lessons-learned.md",
        "05-ai-review-log/05-human-signoff.md"]),
    ("Part 6 — Đo hiệu quả khóa học", ["01-design/05-evaluation-plan.md"]),
]
CODE_APPENDIX = [
    ("03-labs/modules/secure-bucket/main.tf", "hcl"),
    ("03-labs/modules/secure-bucket/tests/secure_bucket.tftest.hcl", "hcl"),
    ("03-labs/lab03-policy/policy/s3.rego", "rego"),
    ("03-labs/lab03-policy/policy/iam.rego", "rego"),
    ("03-labs/lab04-ci/.github/workflows/terraform.yml", "yaml"),
    ("05-ai-review-log/final-validation.txt", "text"),
]

CSS = """
@page { size: A4; margin: 18mm 16mm 18mm 16mm;
  @bottom-right { content: counter(page); font: 9pt 'Inter', sans-serif; color:#64748b; } }
:root { --ink:#0f172a; --muted:#475569; --accent:#0e7490; --rule:#e2e8f0; --soft:#f1f5f9; }
* { box-sizing: border-box; }
html, body { background:#fff; }
body { font-family: 'Inter','Helvetica Neue',Arial,sans-serif; color:var(--ink); font-size:9.6pt; line-height:1.5; margin:0; }
h1 { font-size:17pt; color:var(--accent); border-bottom:2px solid var(--accent); padding-bottom:4px; margin:0 0 10px; break-after:avoid; }
h2 { font-size:12.5pt; margin:16px 0 6px; break-after:avoid; }
h3 { font-size:10.8pt; margin:12px 0 4px; break-after:avoid; color:#155e75; }
p, li { orphans:3; widows:3; }
a { color:var(--accent); text-decoration:none; }
table { border-collapse:collapse; width:100%; margin:6px 0 10px; font-size:8.3pt; break-inside:auto; }
th { background:var(--soft); text-align:left; font-weight:600; }
th, td { border:1px solid var(--rule); padding:3px 5px; vertical-align:top; }
tr { break-inside:avoid; }
code { font-family:'JetBrains Mono','SF Mono',Menlo,monospace; font-size:8.2pt; background:var(--soft); padding:0 3px; border-radius:3px; }
pre { background:#0b1220; color:#e2e8f0; padding:8px 10px; border-radius:6px; font-size:7.6pt; line-height:1.4; white-space:pre-wrap; word-break:break-word; }
pre code { background:none; color:inherit; padding:0; font-size:inherit; }
blockquote { border-left:3px solid var(--accent); margin:8px 0; padding:4px 10px; background:#ecfeff; color:#164e63; }
.doc { break-before:page; }
.part { break-before:page; break-after:page; display:flex; flex-direction:column; justify-content:center; height:230mm; }
.keep { break-inside:avoid; }
thead { display:table-header-group; }
li, blockquote, .src { break-inside:avoid; }
.src { break-after:avoid; }
.part h1 { font-size:26pt; border:none; }
.part p { color:var(--muted); font-size:11pt; }
.src { color:var(--muted); font-size:8pt; margin:0 0 8px; font-family:'SF Mono',Menlo,monospace; }
.cover { height:230mm; display:flex; flex-direction:column; justify-content:space-between; }
.cover .kicker { color:var(--accent); font-weight:600; letter-spacing:.08em; text-transform:uppercase; font-size:9pt; }
.cover h1 { font-size:28pt; border:none; color:var(--ink); line-height:1.15; margin-top:8px; }
.cover .sub { font-size:12pt; color:var(--muted); }
.cover .meta td { border:none; padding:2px 10px 2px 0; font-size:10pt; }
.toc li { margin:2px 0; }
.codehilite .k,.codehilite .kd,.codehilite .kn { color:#7dd3fc; } .codehilite .s,.codehilite .s2,.codehilite .s1 { color:#86efac; }
.codehilite .c,.codehilite .c1,.codehilite .cm { color:#94a3b8; font-style:italic; } .codehilite .nb,.codehilite .nf { color:#fcd34d; }
.codehilite .m,.codehilite .mi { color:#fda4af; } .codehilite .gd { color:#fca5a5; } .codehilite .gi { color:#86efac; } .codehilite .gu { color:#7dd3fc; }
"""

def md(text):
    text = re.sub(r"\]\((?!https?://)([^)]+)\)", r"](#)", text)   # repo-relative links are not navigable in a PDF
    return keep_short(markdown.markdown(text, extensions=["tables", "fenced_code", "codehilite", "sane_lists"],
                             extension_configs={"codehilite": {"guess_lang": False, "css_class": "codehilite"}}))

def keep_short(h):
    """Avoid splitting short tables (<=14 rows) and code blocks (<=35 lines) across pages."""
    h = re.sub(r"<table>(.*?)</table>", lambda m: ('<table class="keep">' if m.group(1).count("<tr") <= 14 else "<table>")
               + m.group(1) + "</table>", h, flags=re.S)
    return re.sub(r'<div class="codehilite">(.*?)</div>', lambda m: ('<div class="codehilite keep">' if m.group(1).count("\n") <= 35
               else '<div class="codehilite">') + m.group(1) + "</div>", h, flags=re.S)

def main():
    body = ['''<section class="cover"><div>
<div class="kicker">OpenAI Academy · AI for Educators · Evidence</div>
<h1>Production-grade Infrastructure as Code:<br>Terraform + Policy as Code</h1>
<p class="sub">Khóa đào tạo DevOps nâng cao (4 buổi × 2 giờ + capstone), được thiết kế bằng AI và kiểm soát chất lượng bởi con người</p>
</div><div>
<table class="meta"><tr><td><b>Tác giả</b></td><td>Nguyễn Công Định — DevOps Engineer</td></tr>
<tr><td><b>Chứng chỉ</b></td><td>OpenAI Academy — AI for Educators (18/11/2026)</td></tr>
<tr><td><b>Ngày kiểm chứng</b></td><td>23/11/2026 · Terraform 1.16.4 · AWS provider 6.73.0 · OPA 1.22.4</td></tr>
<tr><td><b>Kỹ năng thể hiện</b></td><td>Source-grounded prompting · Objective alignment · Session planning · Activity &amp; assessment design · AI output review</td></tr></table>
</div><div><h2>Nội dung</h2><ol class="toc">''' + "".join(f"<li>{html.escape(t)}</li>" for t, _ in PARTS) +
            "<li>Appendix — Code tiêu biểu &amp; kết quả kiểm chứng</li></ol></div></section>"]
    for title, files in PARTS:
        if title != "Overview":
            body.append(f'<section class="part"><h1>{html.escape(title)}</h1></section>')
        for i, f in enumerate(files):
            cls = "doc" if (title == "Overview" or i > 0) else "doc first"
            body.append(f'<section class="{cls}"><div class="src">{f}</div>{md((ROOT / f).read_text())}</section>')
    body.append('<section class="part"><h1>Appendix — Code tiêu biểu &amp; kết quả kiểm chứng</h1>'
                '<p>Toàn bộ code nằm trong repo; đây là trích các file trọng tâm, đúng nguyên văn bản cuối.</p></section>')
    for f, lang in CODE_APPENDIX:
        body.append(f'<section class="doc"><h2>{f}</h2>{md(f"```{lang}\n{(ROOT / f).read_text()}\n```")}</section>')
    OUT_HTML.parent.mkdir(exist_ok=True)
    OUT_HTML.write_text(f'<!doctype html><html lang="vi"><head><meta charset="utf-8"><title>AI for Educators Evidence</title>'
                        f'<style>{CSS}</style></head><body>{"".join(body)}</body></html>')
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                    f"--print-to-pdf={OUT_PDF}", OUT_HTML.as_uri()], check=True, capture_output=True)
    print("wrote", OUT_PDF.name)

if __name__ == "__main__":
    sys.exit(main())
