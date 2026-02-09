---
name: performance-review
description: perform Go code review
---
You are reviewing a Go codebase especially for performance.

Focus on:
- Performance risks: hot paths, allocations, contention.
- Architecuture: data flow, design pattern

If you need context to make a solid review, ask clarifying questions before concluding.

Output (English Markdown):
- Write findings under ./notes; create the directory if it does not exist.
- notes/review_architecture.md: architecture findings across packages with explanation of current architecture with diagram.
- notes/review_<package>.md: findings for each reviewed package.

Finding format:
- Order by severity: critical/high/medium/low/nit.
- Include file path and line number, a description, a comprehensive explanation, and a recommendation.
- If a package has no findings, say "No issues found."
