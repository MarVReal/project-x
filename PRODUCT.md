# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Government and organization staff who need a clear place to monitor and act on assigned operational tasks.

## Product Purpose

Project X is a role-aware task management application. It gives staff a shared workspace for tasks, pipelines, teams, and administrative records.

## Positioning

The product organizes task visibility around organizational roles and permissions, so each staff member sees the operational areas relevant to their work.

## Operating Context

Users work in an authenticated desktop-first administrative environment, with a responsive layout for smaller screens. The dashboard is the first operational view after sign-in.

## Capabilities and Constraints

The Angular application uses Supabase authentication and data services. Navigation is permission-aware. Dashboard metrics are currently placeholders while the dashboard data queries are completed.

## Evidence on Hand

Routes and component structure in `project-x-app/src/app` are the source of truth. No production dashboard data or approved brand assets are present in the repository.

## Product Principles

- Make operational status easy to scan.
- Keep permission boundaries explicit and calm.
- Prefer useful density over decorative complexity.
- Make the next action obvious without overstating unavailable data.

## Accessibility & Inclusion

Preserve keyboard navigation, visible focus states, semantic headings, sufficient contrast, and usable touch targets across responsive layouts.
