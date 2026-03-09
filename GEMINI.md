# GEMINI.md

本项目为个人维护的 Helm Charts 仓库，旨在提供一系列面向自托管场景、可直接部署到 Kubernetes 的应用模板。

## 项目概览
- **用途**：提供 Kubernetes 部署所需的 Helm Charts。
- **技术栈**：Helm (Kubernetes Package Manager)、Kubernetes YAML。
- **架构**：以 `charts/<chart-name>/` 为单位，采用模块化结构，支持独立版本演进。

## 开发与维护流程
- **开发规范**：
    - 使用 Conventional Commits 格式编写 Git 提交信息（如 `feat(chart-name): ...`）。
    - 严禁在 `values.yaml` 中提交敏感信息（密钥、密码），应使用占位符或外部密钥管理。
- **验证命令**：
    - `helm lint charts/<chart-name>`：检查语法与最佳实践。
    - `helm template test charts/<chart-name> --debug`：本地渲染模板进行排查。
    - `helm install test charts/<chart-name> --dry-run --debug`：本地模拟安装测试。
    - `helm dependency update charts/<chart-name>`：当 Chart 包含依赖（`Chart.yaml` 中定义 `dependencies`）时必须运行。
- **发布流程**：
    - 修改 Chart 时，必须手动更新 `Chart.yaml` 中的 `version`（Chart 版本）和 `appVersion`（上游应用版本）。
    - 变更推送到 `main` 分支后，GitHub Actions (`.github/workflows/release.yml`) 会自动完成打包与索引发布。

## 关键文件与目录
- `charts/`：存放所有 Chart 的根目录。
- `.github/workflows/release.yml`：CI/CD 自动化发布流水线。
- `CLAUDE.md` / `AGENTS.md`：项目特定辅助开发说明文件。

## 使用指南
- **添加仓库**：`helm repo add sakullla https://sakullla.github.io/helm-charts`
- **查看帮助**：运行 `helm search repo sakullla` 或参考 `README.md` 中的示例。
