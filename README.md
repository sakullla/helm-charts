# Helm Charts 仓库

一个面向自托管场景的 Helm Charts 集合，提供可直接部署到 Kubernetes 的应用模板。

## 项目概览

- 当前维护 **28 个 Charts**，覆盖网络代理、AI 应用、知识管理、基础设施、机器人工具等场景。
- 大多数 Chart 采用统一模板结构：`deployment / service / ingress / httproute / hpa / serviceaccount`，并按需提供 `pvc / secret / configmap / tests`。
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
helm install my-app sakullla/vaultwarden -n my-ns --create-namespace

# 查看默认配置
helm show values sakullla/vaultwarden
```

## Charts 一览

| 分类 | Chart | 说明 |
|------|-------|------|
| 网络与代理 | `adguard-home` | 全网广告与追踪拦截 DNS 服务器 |
| | `ddns-go` | 动态 DNS 客户端 |
| | `dns-server` | DNS 服务 |
| | `frp` | 内网穿透工具 |
| | `hubproxy` | Hub 代理服务 |
| | `nginx-reverse-emby` | Emby/Jellyfin 自动化反向代理，支持面板管理与自动 SSL |
| | `nginx-stream` | Nginx 四层流量转发 |
| | `xray` | 代理工具 |
| AI 与大模型 | `litellm` | LLM API 代理网关 |
| | `lobehub` | AI 聊天框架（含数据库依赖） |
| | `newapi` | AI API 管理平台 |
| | `openclaw` | AI 应用 |
| 知识与文档 | `calibre-web-automated` | 自动化电子书管理 |
| | `hedgedoc` | 协作 Markdown 编辑器 |
| | `kavita` | 数字阅读服务器 |
| | `hugo-site` | Hugo 静态站点 |
| 数据采集与搜索 | `firecrawl` | 网页抓取服务（多组件：api/worker/playwright 等） |
| | `searxng` | 隐私搜索引擎 |
| 工具与基础设施 | `certimate` | 证书自动化管理 |
| | `koipy` | 交易机器人 |
| | `logvar` | 日志变量服务 |
| | `miaospeed` | 节点测速工具（含依赖） |
| | `openlist` | 网盘管理 |
| | `saveany-bot` | Telegram 文件保存机器人 |
| | `substore` | 订阅管理工具 |
| | `tabby-web` | Web 终端 |
| | `vaultwarden` | Bitwarden 兼容密码管理器 |
| | `misaka-danmu-server` | 弹幕服务器 |

## 架构模式

- **单服务标准型**：如 `adguard-home`、`openlist`、`kavita`，结构清晰，适合快速部署。
- **依赖编排型**：如 `lobehub`、`miaospeed`，通过 `Chart.yaml` 中的 `dependencies` 组合子服务。
- **多组件型**：如 `firecrawl`（api / worker / playwright 等 6 个 Deployment），适合复杂业务栈。

## 本地开发与验证

```bash
# 校验语法与最佳实践
helm lint charts/<chart-name>

# 渲染模板
helm template test charts/<chart-name> --debug

# 模拟安装
helm install test charts/<chart-name> --dry-run --debug -n test --create-namespace

# 有依赖时先更新
helm dependency update charts/<chart-name>

# 打包验证
helm package charts/<chart-name>
```

## 版本与发布

- 修改任意 Chart 后，应同步更新该 Chart 的 `Chart.yaml` 中 `version`。
- 上游应用版本变化时，更新 `appVersion`。
- 推送到 `main` 且命中 `charts/**` 变更后，GitHub Actions 自动执行发布流程（打包、更新索引、清理历史产物）。

## 贡献指南

- 使用 Conventional Commits：`feat(chart-name): ...`、`fix(chart-name): ...`。
- PR 建议包含：变更说明、受影响 Chart、执行过的验证命令、破坏性变更说明。
- 请勿在 `values.yaml` 提交真实密钥，统一使用占位符或外部密钥管理方案。

## 许可证

[GPL-3.0](LICENSE)
