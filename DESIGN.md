# Design System

## Visual Direction

Project X uses a minimalist civic operations language: a light paper workspace, deep navy shell, clear rules, restrained cobalt action color, and amber reserved for attention or pending status.

## Tokens

- Canvas: `#f4f6f8`
- Surface: `#ffffff`
- Ink: `#17212b`
- Navigation: `#123b63`
- Navigation active: `#28567f`
- Muted text: `#637487`
- Rule: `#d5dde5`
- Status attention: `#c28a28`
- Radius: 4px for controls and repeated items; 6px for framed states
- Typography: IBM Plex Sans first, Segoe UI fallback; Roboto remains Angular Material's component fallback

## Composition

Use an anchored navy navigation rail and a white utility header. Main surfaces use generous outer padding, compact operational groupings, and a clear heading-before-data sequence. Prefer rules, spacing, and weight over decoration.

## Components

Navigation is permission-aware and uses dark navy with a single active background. Dashboard values must distinguish pending data from zero. Cards are reserved for repeated operational indicators and use quiet borders with no decorative gradients.

## Accessibility

Maintain visible keyboard focus using the amber focus ring, preserve semantic headings, keep body text high-contrast, and stack dashboard status groups at narrow widths.
