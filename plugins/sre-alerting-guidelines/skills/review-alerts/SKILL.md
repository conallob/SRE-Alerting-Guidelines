---
name: review-alerts
description: Apply the SRE Alerting Guidelines when writing, reviewing or refactoring alerts, such as Prometheus alert rules, SLO burn-rate alerts, Alertmanager routing, or paging versus ticketing decisions. Also use when asked whether an alert is actionable, noisy, redundant, symptom-based or well-thresholded. Fetches the current guide from writings.conall.dev rather than relying on a bundled copy.
---

# Review alerts against the SRE Alerting Guidelines

The guide is a peer-to-peer style guide of "do this, not that" guardrails for alert design. It is maintained at https://writings.conall.dev/projects/sre-alerting-guidelines/ and changes over time, so always read the current text before applying it.

It is formatted like a style guide: the guardrails are broken out by subsection, and each subsection can include one or more TIPs, NOTEs, and Examples and Counter Examples related to that subsection. Read a subsection as a whole before citing it, since its TIPs, NOTEs and Counter Examples often qualify the main guidance.

## 1. Fetch the guide

Fetch the Markdown edition, which is the same content as the web page without the site chrome:

```
https://writings.conall.dev/projects/sre-alerting-guidelines/index.md
```

Use WebFetch, or `curl -sL` if shell access is available. If that URL is unreachable, fall back to the source file:

```
https://raw.githubusercontent.com/conallob/SRE-Alerting-Guidelines/main/sre-alerting-guidelines.md
```

If neither can be fetched, say so and stop. Do not reconstruct the guide from memory, because the current wording is the point.

## 2. Apply it

Read the alert definitions, routing config or design under discussion, then check them against the guide's guidelines, which as of this writing are:

- Synthetic vs exposed metrics
- Alert on symptoms, not causes
- Use error budgets for SLO alerting thresholds
- Avoid redundant alerts
- Use predictive (extrapolation) alerting sparingly
- Avoid anticipating data correctness in the monitoring data
- Take responsibility where others cannot or do not

plus the guiding principles (coverage, priorities such as "alerts should always be actionable", and maintainability) and the strategies for alert fatigue and thresholds that do the waiting. Treat the fetched text as authoritative over this list.

## 3. Report

For each finding, give:

1. The guideline by name, linked to the page (https://writings.conall.dev/projects/sre-alerting-guidelines/).
2. What in the alert or design triggers it, quoting the relevant rule, expression or threshold.
3. A concrete suggested change.

Rules for the review:

- Only cite guidance that appears in the fetched guide. If something looks wrong but the guide does not cover it, say that it is outside the guide.
- The guide does not cover pipeline systems. Say so rather than stretching it to fit.
- Prefer a short list of real findings over exhaustive nitpicking. If the alert already follows the guide, say that.
