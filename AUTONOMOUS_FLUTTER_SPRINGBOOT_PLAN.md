# Autonomous Branching and Delivery Plan (Flutter + Spring Boot Microservices)

This document defines how work should be executed autonomously: creating branches, implementing scoped changes, validating quality gates, and merging safely.

Note: this repository currently uses Next.js + FastAPI. This plan is a forward-looking workflow for Flutter + Spring Boot microservice delivery and can be applied as a standard operating model.

## 1) Objectives

1. Keep `main` always releasable.
2. Never develop directly on `main`.
3. Use small, testable branches with clear ownership.
4. Enforce mandatory checks before every PR.
5. Make autonomous work traceable, reproducible, and reversible.

## 2) Non-Negotiable Guardrails

1. Pull latest `origin/main` before starting any new branch.
2. No force push to shared branches (`main`, `release/*`).
3. No direct commits to `main`.
4. One branch must map to one clear change goal.
5. Secrets never committed (use environment variables and secret managers only).
6. Every code change must include matching tests or a documented rationale if tests are impossible.

## 3) Branch Model

Protected long-lived branches:

1. `main`: production-ready branch.
2. `release/<version>`: optional stabilization branch for release hardening.

Short-lived working branches:

1. `feat/mobile-<ticket>-<slug>` for Flutter app features.
2. `feat/service-<service>-<ticket>-<slug>` for one Spring Boot microservice feature.
3. `fix/mobile-<ticket>-<slug>` for Flutter bug fixes.
4. `fix/service-<service>-<ticket>-<slug>` for microservice bug fixes.
5. `chore/<scope>-<ticket>-<slug>` for refactors/tooling.
6. `hotfix/<scope>-<ticket>-<slug>` for urgent production incidents.

Examples:

1. `feat/mobile-423-outfit-history-filter`
2. `feat/service-recommendation-441-weather-cache`
3. `fix/service-auth-452-token-refresh-race`

## 4) Autonomous Execution Loop

Run this loop for each task:

1. Sync base branch.
2. Create a task branch with deterministic naming.
3. Implement only the scoped change.
4. Run all required quality gates.
5. Commit with conventional commits.
6. Push branch and open PR.
7. Rebase or merge from `main` if needed.
8. Merge only when all checks pass.
9. Delete merged branch.

## 5) Exact Git Command Sequence

```bash
# 0) Always begin from repository root

# 1) Sync main from remote
git fetch origin --prune
git switch main
git pull --ff-only origin main

# 2) Create branch
git switch -c feat/service-recommendation-441-weather-cache

# 3) Work + stage changes
git add -A

# 4) Commit using conventional commits
git commit -m "feat(recommendation): add weather response cache"

# 5) Push and set upstream
git push -u origin feat/service-recommendation-441-weather-cache

# 6) Before merge, resync with main
git fetch origin --prune
git rebase origin/main

# 7) Push rebased branch safely
git push --force-with-lease
```

## 6) Change Slicing Rules

1. Flutter-only UI changes: one branch if API contract is unchanged.
2. Single-microservice backend change: one branch per service.
3. Shared contract change (OpenAPI/proto/events): split into sequence.
4. Cross-service behavior change: one orchestration branch only if changes are tightly coupled and cannot be safely separated.
5. Large tasks: split into preparatory refactor branch, feature branch, and cleanup branch.

## 7) Quality Gates (Must Pass Before PR)

Flutter gates:

1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze`
4. `flutter test`

Spring Boot gates (per affected microservice):

1. `./gradlew clean test`
2. `./gradlew check`
3. `./gradlew bootJar`

Contract and integration gates:

1. API contract generation/checks (OpenAPI/protobuf if used).
2. Consumer/provider compatibility tests.
3. Integration tests (prefer Testcontainers for DB/message broker dependencies).

Security and hygiene gates:

1. Dependency audit (Gradle and Dart ecosystem).
2. Static analysis warnings reviewed and resolved.
3. No TODO left without ticket reference.

## 8) Commit and PR Standards

Commit message format:

1. `feat(scope): ...`
2. `fix(scope): ...`
3. `refactor(scope): ...`
4. `test(scope): ...`
5. `docs(scope): ...`

PR must include:

1. Problem statement.
2. What changed and why.
3. Risk assessment.
4. Test evidence (logs/screenshots where relevant).
5. Rollback plan.
6. Linked issue/ticket.

## 9) Autonomous Decision Matrix

If request scope is Flutter only:

1. Branch prefix: `feat/mobile` or `fix/mobile`.
2. Validate Flutter gates only plus any touched contract checks.

If request scope is one microservice only:

1. Branch prefix: `feat/service-<name>` or `fix/service-<name>`.
2. Validate affected service plus integration tests.

If request scope spans Flutter + backend:

1. Prefer two branches if backend can be backward-compatible first.
2. Sequence:
   - Backend compatibility branch.
   - Flutter adoption branch.
3. Use one branch only when API breakage prevents safe sequencing.

## 10) Release and Hotfix Protocol

Normal release flow:

1. Merge feature/fix branches into `main` through PR.
2. Tag release from `main`.
3. Optionally create `release/<version>` for stabilization.

Hotfix flow:

1. Branch from `main` using `hotfix/...`.
2. Apply minimal fix only.
3. Run critical tests and smoke tests.
4. Merge immediately after approval.
5. Backport to any open `release/*` branch if required.

## 11) Rollback Strategy

1. Preferred rollback: revert merge commit, do not rewrite `main` history.
2. Keep database migrations backward-safe when possible.
3. Use feature flags for high-risk behavior.
4. Maintain deployment notes for rapid disable/rollback.

## 12) Definition of Done (Autonomous)

A task is done only when all are true:

1. Branch created from latest `origin/main`.
2. Scope implemented and reviewed for side effects.
3. All relevant quality gates pass.
4. Documentation updated.
5. PR opened with evidence and rollback notes.
6. Branch merged and deleted.

## 13) Reusable Task Checklist

Copy and tick for each new autonomous task:

```text
[ ] Synced origin/main
[ ] Created correctly named branch
[ ] Implemented scoped change only
[ ] Ran Flutter/Spring quality gates
[ ] Added or updated tests
[ ] Updated docs/changelog if needed
[ ] Committed with conventional commit message
[ ] Pushed branch and opened PR
[ ] Rebased on origin/main before final merge
[ ] Merged and deleted remote branch
```