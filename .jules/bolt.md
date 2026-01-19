## 2026-01-19 - Drift Index Definition
**Learning:** Drift 2.x supports defining indexes directly in Dart tables using the `@TableIndex` annotation on the class, rather than just in the database migration strategy or `.drift` files. This allows for keeping index definitions close to the table structure.
**Action:** When adding indexes to Drift tables defined in Dart, annotate the table class with `@TableIndex`.
