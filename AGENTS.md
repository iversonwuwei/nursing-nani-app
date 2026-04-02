## Harness Engineering Rules

This repository uses Harness Engineering as the default delivery model for all future implementation work.

### Operating Model

- Design every change as the smallest reviewable delivery unit.
- Before substantial edits, state the entry points, affected users, rollout stage, validation gate, and rollback path.
- Prefer root-cause fixes over surface patches, but keep the blast radius narrow.
- Do not mix unrelated cleanup into feature, bug-fix, or workflow changes.
- Distinguish three outcomes in status reporting: implemented, verified, and residual risk.

### Release Safety And Progressive Delivery

- Treat this app as a release-sensitive caregiver execution client.
- For user-visible or operationally risky changes, prefer scoped exposure, reversible UI logic, or configuration-driven fallback when available.
- If no runtime flag or remote config exists, document the rollback method before changing behavior.
- Prefer reversible changes to task flows, alert handling, routing, and local state transitions.
- Avoid one-way data or state changes unless the rollback cost is documented.

### Verification As A Gate

- Verification is mandatory. Every change needs explicit success signals.
- Default repository gate: `flutter analyze` and `flutter test`.
- For task flows, alert timelines, authentication, or stateful UI changes, also validate the affected runtime path on a simulator when feasible.
- If runtime validation cannot be performed, state the exact unverified behavior and the best available proxy signal.

### Observability And Reliability

- Follow the Harness Continuous Verification mindset: key workflows should expose enough evidence to determine whether the app remains healthy.
- Preserve or add observable signals for login, route guard behavior, task completion, alert acknowledgement, handoff, and failure recovery.
- Prefer deterministic UI states and stable navigation behavior over implicit transitions.
- Define health signals before implementing changes that affect operational workflows.

### Mobile Frontend Rules

- For each meaningful UI change, describe user impact, data source, loading state, empty state, error state, and mobile impact.
- Respect the existing GetX architecture, route layering, and small-widget decomposition.
- Keep execution flows predictable across tab switches, back navigation, re-entry, and app lifecycle changes.
- When changing mock-backed logic, document whether the behavior is prototype-only or intended to mirror the future real contract.

### API And Integration Rules

- If introducing or changing service, repository, or mock interfaces, describe caller impact, compatibility expectations, and migration path to real APIs.
- Preserve backward compatibility for in-app consumers unless a breaking change is explicitly authorized.
- For payload or model changes, include examples and rollback strategy.

### Dependency And Supply Chain Rules

- Avoid adding new packages unless Flutter SDK, Dart SDK, or current dependencies are insufficient.
- Any new package, build step, or external service must be justified with source, purpose, risk, and minimum necessity.
- Preserve reproducible local builds and analyzer behavior.

### Required Delivery Templates

- Mobile frontend: scope -> user impact -> data or mock source -> loading, empty, error, mobile states -> verification -> rollback.
- Service or integration logic: scope -> contract and dependencies -> failure handling -> observability -> verification -> rollback.
- API or model: scope -> compatibility -> caller impact -> field evolution strategy -> examples -> verification -> rollback.

### Repository Verification Gates

- Minimum gate for code changes: `flutter analyze` and `flutter test`.
- Required extra gate for task execution, alert handling, auth, or rendering-sensitive work: run the affected flow on a simulator when feasible.
- If a required gate cannot run because of environment constraints, document the blocker and residual risk.

### Source Of Truth

- Primary reference: <https://developer.harness.io/docs>
- GitHub source reference: <https://github.com/harness/developer-hub>
- Most relevant Harness areas for this repository: Continuous Delivery verification, Feature Flags, Infrastructure as Code Management, Software Supply Chain Security, and operational observability for caregiver workflows.