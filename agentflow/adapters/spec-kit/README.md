# spec-kit Adapter

This adapter treats spec-kit as the source of the first three artifacts:

- `spec.md`
- `plan.md`
- `tasks.md`

The current minimum integration does not call spec-kit automatically. It creates
the same Feature Bundle shape so generated spec-kit files can be copied or
linked into the bundle. A later adapter can invoke `speckit.specify`,
`speckit.plan`, and `speckit.tasks` directly.
