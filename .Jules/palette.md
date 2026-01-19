## 2024-05-22 - Custom Widget Accessibility
**Learning:** Custom interactive widgets (like `GlassIconButton`) using `GestureDetector` are invisible to screen readers unless wrapped in `Semantics`.
**Action:** Always audit custom UI components for `Semantics` wrappers and `Tooltip` support during the "Observe" phase.
