# spec-kit Adapter

这个 adapter 把 spec-kit 视为前三个产物的来源：

- `spec.md`
- `plan.md`
- `tasks.md`

当前最小集成不会自动调用 spec-kit。它会创建相同形状的 Feature Bundle，因此由 spec-kit 生成的文件可以复制或链接进 bundle。后续 adapter 可以直接调用 `speckit.specify`、`speckit.plan` 和 `speckit.tasks`。
