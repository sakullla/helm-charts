# Helm Charts 仓库

一个面向自托管场景的 Helm Charts 集合，提供可直接部署到 Kubernetes 的应用模板。

## 项目概览
- 当前维护 **39 个 Charts**，覆盖基础设施、AI 应用、知识管理、机器人工具等场景。
- 大多数 Chart 采用统一模板结构：`deployment/service/ingress/httproute/hpa/serviceaccount`，并按需提供 `pvc/secret/configmap/tests`。
- 仓库以 `charts/<chart-name>/` 为最小维护单元，便于独立版本演进和发布。

## 仓库结构
```text
.
├─ charts/
│  ├─ <chart-name>/
│  │  ├─ Chart.yaml
│  │  ├─ values.yaml
│  │  └─ templates/
├─ .github/workflows/release.yml
├─ AGENTS.md
└─ README.md
```

## 快速开始
```bash
# 添加仓库
helm repo add sakullla https://sakullla.github.io/helm-charts
helm repo update

# 搜索 Chart
helm search repo sakullla

# 安装示例
helm install my-app sakullla/vaultwarden

# 查看默认配置
helm show values sakullla/vaultwarden
```

## 代表性 Charts（架构分析）
- **单服务标准型**：如 `adguard-home`、`openlist`、`kavita`，结构清晰，适合快速部署。
- **依赖编排型**：如 `automem`，通过 `dependencies` 组合 `falkordb`、`qdrant`、`automem-graph-viewer`。
- **多组件型**：如 `firecrawl`（api/worker/playwright/nuq 组件）与 `cognee`（主服务 + Postgres + Neo4j + ChromaDB），适合复杂业务栈。

## 本地开发与验证
```bash
# 校验语法与最佳实践
helm lint charts/<chart-name>

# 渲染模板
helm template test charts/<chart-name> --debug

# 模拟安装
helm install test charts/<chart-name> --dry-run --debug -n test --create-namespace

# 有依赖时更新
helm dependency update charts/<chart-name>
```

## 版本与发布机制
- 修改任意 Chart 后，应同步更新该 Chart 的 `Chart.yaml` 中 `version`。
- 上游应用版本变化时，更新 `appVersion`。
- 推送到 `main` 且命中 `charts/**` 变更后，GitHub Actions 会自动执行发布流程（打包、更新索引、清理历史产物）。

## 贡献建议
- 使用 Conventional Commits：`feat(chart-name): ...`、`fix(chart-name): ...`。
- PR 建议包含：变更说明、受影响 Chart、执行过的验证命令、破坏性变更说明。
- 请勿在 `values.yaml` 提交真实密钥，统一使用占位符或外部密钥管理方案。

## 许可证
[GPL-3.0](LICENSE)
