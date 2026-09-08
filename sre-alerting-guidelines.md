---
title: "SRE Alerting Guidelines"
description: "A peer-to-peer style guide for writing effective alerts"
date: 2023-10-17
draft: false
showToc: true
---

# SRE Alerting Guidelines: A Peer to Peer Quick Style Guide

Author: [Conall O'Brien](mailto:conall.obrien@docusign.com)
Status: Seeking a forum to Publish
Published:
Last Edited: 2023-10-17

# Why This Document

There are many foundational monitoring texts for engnineers—most notably the [Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/) chapter of the SRE Book, and the design advice from the [Monitoring](https://sre.google/workbook/monitoring/) chapter of the SRE Workbook.

This guide isn't here to rehash broad architectural theory. Instead, it's a tactical, peer-to-peer [style guide](https://abseil.io/resources/swe-book/html/ch08.html) designed to give you direct "do-this, not-that" guardrails for code reviews and design debates, explicitly accounting for modern systems and the realities of human operational psychology.

This document is intended to be a complimentary [style guide](https://abseil.io/resources/swe-book/html/ch08.html) to the philosophies described in [Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/) of the SRE Book and the design advice from the [Monitoring](https://sre.google/workbook/monitoring/) chapter of the SRE Workbook.

When implementing/refactoring an alert, sometimes you just need a specific best practice (or cautionary tale) to cite during review.

TODO(conall): Create useful hyperlink anchors to each section

## Supported System Paradigms

These best practices have been collected from various systems of the following paradigms:

  - User Facing Systems
      - Stateless User Facing Systems
      - Stateful User Facing Systems
  - Infrastructure
      - Stateless Infrastructure (e.g a [Redis](http://www.redis.io) cache)
      - Stateful Backend Infrastructure (e.g Storage systems)
  - Control Systems (e.g Service Meshes such as [Istio](https://www.istio.io))

## Unsupported System Paradigms

  - Pipeline Systems

# Guiding Principles

Each principle represents an important goal; at times a compromise between two principles may be necessary, but tradeoffs should be made with an understanding of the intention behind the principles in tension

## Coverage

  - We need to know about significant user harm as much as possible.
      - Corollary: user reports of significant issues will always highlight a monitoring blindspot. User reports of systemic issues should rarely catch a well-tuned monitoring system by surprise. User reports should almost never occur for a monitoring system with sufficiently high coverage.
  - End to end verification for every service is desirable, end to end verification for critical user workflows is paramount.

## Priorities

  - Choose alerts that have a high signal to noise ratio, and focus on excellent quality and thoroughness for those alerts, rather than a scattershot of alerts which are not well-tuned.
  - Alerts should always be actionable, either directly or indirectly (e.g escalating to another team/ SaaS vendor, etc.).
  - For a large number of SLO definitions, grouping by defined SLO groups (aka bucket), will be more effective than individual alerts per SLO definiton

## Maintainability

  - Maintain effective monitoring with minimal time commitment
  - Every alert requires ongoing maintenance and tuning or risks an increase in false positives or negatives.
  - Aim to have the smallest number of alerts that grant adequately thorough coverage; defence in depth may be appropriate in some cases, but excessive redundant or overlapping alerts increases maintenance cost and ultimately quality.

# Guidelines

## Synthetic vs Published Metrics (neé Blackbox vs Whitebox)

There are an infinite number of ways things can break, which means the amount of alerting logic required for good coverage would be staggering.

Although synthetic (neé blackbox) monitoring (AKA dye testing, when referring to pipeline systems) has less coverage, its ability to cover multiple scenarios means its cost-benefit is much more appealing compared to exposed metrics (neé whitebox) monitoring. Prefer synthetic monitoring where possible.

There is a misconception that the choice is only ever an XOR between monitoring synthetic vs exposed metrics. A system needs both; synthetic checks to tell you **when** (and ideally **where**) something is wrong; and exposed metrics to facilitate in depth troubleshooting to discover exactly **what** has gone wrong.

TIP: Low level HTTP probes implemented such as [prometheus/blackbox_exporter](https://github.com/prometheus/blackbox_exporter) are useful, but often deviate from the modern user experience. In addition to low level HTTP probes, combined with feature rich solutions such as rich HTTP (e.g [CloudProber](http://www.cloudprober.org)) and headless browser probing (e.g [Checkly](https://www.checklyhq.com/)) for richer, javascript powered Web UIs.

## Alert on Symptoms, not Causes

Alert based on symptoms, not root causes/edge cases. The number of root causes will always vastly outnumber symptoms, so symptom based alerting will always result in higher coverage. Moreover, root causes are very specific to the current implementation; as the system evolves, behaviours and thus symptoms are more likely to remain consistent than are details of the implementation.

Root cause alerts can accelerate debugging, but only for known failure modes. Due to the number of potential root causes, edge cases or unknown failure modes, the maintenance cost of caused based alerting will continue to grow in perpetuity.

For complicated systems with multiple failure modes, multiple symptom based signals may be employed to perform differential diagnosis. For validation, root cause signals can be surfaced on (opinionated, curated) dashboards to help aid debugging almost as quickly.

### Examples

  - Since distributed systems are regularly degraded in steady state, system components can export a metric to calculate the cumulative degradation score across multiple components of the distributed system.
  - HTTP 500 Errors can occur for both network issues behind HTTP reverse proxies (such as load balancers) and for backend HTTP servers experiencing localised issues. TCP retransmits between load balancers and backend components is a more specific symptom signal than HTTP 500s, when diagnosing network issues compared to HTTP 500 errors

## Use [Error Budgets](https://sre.google/sre-book/embracing-risk/#xref_risk-management_unreliability-budgets) for SLO Alerting Thresholds

If your service has an [error budget](https://sre.google/sre-book/embracing-risk/#xref_risk-management_unreliability-budgets), implement a pageable alert for approximately one day of the error budget, as determined by the SLO. Smaller events which do not cause significant risk to the SLO do not warrant immediate attention, but waiting more than one day's worth of damage risks consuming too much error-budget too fast.

TIP: Define a threshold to represent roughly one day of the SLO time period, to the nearest whole percentage. e.g 3% represents 1 day of monthly SLO, 1% roughly one day of a quarterly SLO. If no time window has been defined, the SLI should be revised. Align SLI windows with billing window, if applicable

E.g.

Service X handles 100M queries per quarter and the SLO is 99.9% available. So the paging alert is configured to be:

  - 100M x (100 - 99.9)% x 1% = 10,000 queries fail

Service Y has a latency SLO that \< 1% of queries can take 2 seconds and serves 200M queries

  - 100M x (100 - 99)% x 1% = 20,000 queries are slow

TIP: Annotate SLO burn down alerts with the formula used to calculate thresholds, so the alert can be easily maintained

TIP: Use aggregated data that aligns with your SLI definitions. E.g Aggregate regional data into a global aggregate for a global SLI, instead of trying to de-aggregate a global SLI into a per deployment SLO.

TIP: Always ensure an SLO alert has an order of magnitude defined in the alert definition. Defining SLO alerts with exclusively percentage based thresholds will scale (up and down) to all traffic volumes equally well. Although counterintuitive, periodically recalculating the threshold and revising the alert definition accordingly is actually less work to maintain.

TIP: SLO alerting \!= SLO reporting. Smaller, discrete SLO impacting events that do not cause pages should still be followed up. But followup should be retroactive at the appropriate urgency, instead of being handled using incident management practices.

See [Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/) from the SRE Workbook and [Implementing SLOs](https://www.oreilly.com/library/view/implementing-service-level/9781492076803/). For feature rich implementations, see [Sloth](https://www.sloth.dev) (Open Source) or [Nobl9](http://www.nobl9.com) (SaaS).

### Counter Examples

  - Traditional networking alerts assume every packet is unique and precious, and consider the loss of individual packets to be a terrible thing. This approach does not consider that lower level network events fail to consider the layers of abstraction in the OSI networking model and which layers provide redundancy. In reality, higher level applications anticipate network issues and rarely notice, thanks to features such as the retry logic in TCP, multi region deployments, caching, etc.

## Avoid Redundant Alerts

Avoid redundant alerting. If alert A always fires whenever alert B fires, then remove alert B (since alert A is a superset which includes edge case B).

TIP: For alerts which have multiple thresholds, ensure all thresholds are distinct and do not overlap.

TIP: Alerting systems often have a "fanout" or "[grouping](https://prometheus.io/docs/alerting/latest/alertmanager/#grouping)" setting, which can be used to de-duplicate alerts.

### Example

  - Once implemented, the degraded score signal makes a Jobs Missing alert redundant

### Counter Example

  - If a system X employs both symptom and root caused based alerting, these alerts will often have overlapping thresholds and/or scope. Common failure modes will include regular storms of pages and/or tickets, only a handful of which will actually be useful.

## Use Predictive Alerting Sparingly

Predictive alerting should only be used when there is a high likelihood (50%+) of a major failure (e.g significant error budget burn) or significant MTTM or MTTR. Predictive alerting makes sense for pipeline system use cases, as metrics cannot update quicker than the pipeline's latency.

Where possible use direct observation, simulations or empirical testing to prove damage, instead of anecdotes or speculation.

TIP: A predictive alert should fire time T ahead of a predicted event, which is X% of the error budget or MTTM.

### Counter Examples

  - Quota usage alerts are usually only actionable for enforcement of a hard quota ceiling. Alerts for soft quota ceilings or for high, but non critical usage are often unactionable.

## Avoid Anticipating Data Correctness Issues

Monitoring data should always be treated as an approximation of what a system is actually doing. It is always a snapshot in time, often with a known value for staleness.

Attempting to work around data correctness issues within the monitoring system can likely leverage complicated operations. The potential for bugs would be greater than the original risk of data correctness. In time, there will be hard to distinguish justified caution from paranoia.

## Take Responsibility where Others Cannot or Do Not

Catastrophic coverage gaps can occur when multiple teams make assumptions about each other's monitoring. The obvious exception is when both teams have made an explicit agreement.

### Example

  - An infrastructure team providing a shared service to multiple teams may only monitor their system per class of users. A specific team should not assume their service is the canonical example of their user class, and should therefore create an end-to-end test to cover **their own usage** of the managed infrastructure

### Counter Example

  - An infrastructure team who explicitly chooses to not implement black box monitoring of their service, instead abdicating this responsibility to other teams with overlapping coverage and expecting manual escalations.

# Strategies for Improving Alerting Signal

## Combatting [Alert Fatigue](https://www.atlassian.com/incident-management/on-call/alert-fatigue)

Humans receiving unactionable alerts are susceptible to [alert fatigue](https://www.atlassian.com/incident-management/on-call/alert-fatigue). Once it sets in, cognitive biases often form and perceived root causes or a perception that the alert is low-signal may disincline oncallers to do adequate investigation or skew root-cause analysis. Since alert fatigue is as much a signal to noise issue **compounded by** a perception issue, it can lead to a [normalisation of deviance](https://en.wikipedia.org/wiki/Normalization_of_deviance).

Once an alert is known to have a long history of questionable signal, it is not enough to refactor and tune the alert to have more value; it is useful to also delete or rename the offending alert, to address the perception issue and reset biases going forward.

## Let Your Thresholds Do The Waiting

A common anti-pattern is a ticket generating alert which triggers after a few minutes (detection time), but routinely waits days or weeks for attention (response time). Once triaged, the underlying issue has resolved itself and the ticket is marked as Obsolete or Not Repeatable.

Since detection time is a subset of response time, redistribute some of the implicit waiting from overall response time by explicitly adding it to the alert thresholds itself.

Application and regular tuning of [hysteresis](https://en.wikipedia.org/wiki/Hysteresis) settings (aka hold up/hold down timers in Networking terminology) can also remove hair triggers.

## Acknowledgements

The curator would like to recognise and thank the following for their invaluable feedback on this document:

  - John Truscott Reese
  - Laura Nolan
  - Stepan Davidovic
  - Trisha Weir
  - The Late Cody Smith
