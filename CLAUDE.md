# CLAUDE.md

本文件为 Claude Code 提供仓库工作指南。

## 仓库概述

这是一个 Helm Charts 仓库，托管 40+ 个自托管应用的生产级 Chart。通过 GitHub Pages 在 `https://sakullla.github.io/helm-charts` 发布，并通过 GitHub Actions 自动化发布。

## 核心命令

### Chart 开发验证

```bash
# 渲染模板（语法检查）
helm template my-release charts/<chart-name>

# 模拟安装（捕获大部分错误）
helm install my-release charts/<chart-name> --dry-run --debug

# 在本地集群测试
helm install my-release charts/<chart-name>

# 查看默认配置
helm show values charts/<chart-name>

# Lint 检查
helm lint charts/<chart-name>
```

### 仓库操作

```bash
# 添加已发布的仓库
helm repo add sakullla https://sakullla.github.io/helm-charts
helm repo update

# 搜索 Chart
helm search repo sakullla
```

## Chart 标准结构

```
charts/<chart-name>/
├── Chart.yaml              # 元数据、版本、依赖
├── values.yaml             # 默认配置（含注释）
├── templates/
│   ├── _helpers.tpl        # 辅助函数
│   ├── deployment.yaml     # 主工作负载
│   ├── service.yaml        # 服务定义
│   ├── ingress.yaml        # Ingress（可选）
│   ├── httproute.yaml      # Gateway API（可选）
│   ├── pvc.yaml            # 持久化卷（可选）
│   ├── serviceaccount.yaml # 服务账户
│   └── NOTES.txt           # 安装后说明
└── tests/                  # 测试（如适用）
```

## 模板辅助函数

所有 Chart 在 `_helpers.tpl` 中定义：

- `<chart>.name`: Chart 名称
- `<chart>.fullname`: 完整资源名称
- `<chart>.chart`: Chart 名称+版本
- `<chart>.labels`: 标准标签
- `<chart>.selectorLabels`: 选择器标签
- `<chart>.serviceAccountName`: ServiceAccount 名称

## 网络暴露方式

Chart 支持多种方式（可组合）：

1. **Ingress** - 设置 `ingress.enabled: true`
2. **Gateway API HTTPRoute** - 设置 `httpRoute.enabled: true`
3. **LoadBalancer/NodePort** - 通过 `service.type`
4. **Port-forward** - 仅用于本地测试

## 标准 Values 结构

```yaml
replicaCount: 1
image:
  repository: <app-image>
  pullPolicy: IfNotPresent
  tag: ""  # 默认使用 Chart.appVersion

service:
  type: ClusterIP
  port: <app-port>

ingress:
  enabled: false
  className: ""
  hosts: []

httpRoute:
  enabled: false
  parentRefs: []
  hostnames: []

persistence:
  enabled: false
  size: 1Gi
  storageClass: ""

resources: {}

# 普通环境变量（ConfigMap）
env: {}

# 敏感信息（Secret）
secrets: {}

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100

nodeSelector: {}
tolerations: []
affinity: {}
```

## 版本管理

### Chart 版本（SemVer）

- **MAJOR**: 破坏性变更
- **MINOR**: 新功能
- **PATCH**: Bug 修复

### 版本字段

- `version` (Chart.yaml): Chart 本身版本（任何修改都需升级）
- `appVersion` (Chart.yaml): 应用版本（跟踪上游）
- `image.tag` (values.yaml): 为空时使用 `appVersion`

**关键**: 修改任何 Chart 文件时，必须升级 `Chart.yaml` 中的 `version`。CI 仅发布版本变更的 Chart。

## CI/CD 流程

### Release 工作流 (`.github/workflows/release.yml`)

在 `main` 分支的 `charts/**` 变更时触发：

1. **Chart Release**: 使用 `helm/chart-releaser-action`
   - 打包变更的 Chart
   - 创建 GitHub Release（标签：`<chart-name>-<version>`）
   - 更新 `gh-pages` 分支的 `index.yaml`

2. **Index 清理**: Python 脚本将每个 Chart 只保留最新版本

3. **Release 清理**: 删除旧的 GitHub Release/Tag，每个 Chart 保留最近 2 个

### CI 关键点

- 只有 `Chart.yaml` 版本变更的 Chart 会被发布
- 使用 `secrets.GITHUB_TOKEN` 认证
- `gh-pages` 提交使用 `[skip ci]` 防止循环
- 清理仅针对当前推送修改的 Chart

## Chart 开发指南

### 创建/修改 Chart 时

1. 遵循标准模板结构
2. 所有名称/标签使用 `_helpers.tpl` 中的辅助函数
3. 在 `values.yaml` 中添加内联注释文档
4. 同时实现 `ingress` 和 `httpRoute` 支持（条件启用）
5. 在 `NOTES.txt` 中提供安装后访问说明
6. 提交前使用 `--dry-run --debug` 测试

### Values 文档风格

```yaml
# 设置的简要描述
# 额外的上下文说明（默认行为、约束等）
settingName: defaultValue
```

### 探针配置

Chart 使用 startup/liveness/readiness 探针：

- **startupProbe**: 高 `failureThreshold` * `periodSeconds` 适应慢启动
- **livenessProbe**: 重启不健康的 Pod
- **readinessProbe**: 控制服务端点成员资格

大多数 Chart 使用主端口的 `tcpSocket` 探针。HTTP 应用可使用 `httpGet`。

## Chart 依赖

某些 Chart 包含 Helm 依赖（如 `firecrawl` 包含 `playwright-service`）：

- 依赖在 `Chart.yaml` 的 `dependencies` 中声明
- 子 Chart 值在 `values.yaml` 的依赖别名下配置
- 本地开发使用 `helm dependency update charts/<chart-name>` 获取依赖

## 开发最佳实践

### 必须遵循

1. **版本升级**: 修改任何文件都升级 Chart 版本
2. **测试充分**: 至少通过 lint 和 dry-run
3. **文档完整**: values.yaml 所有选项都有注释
4. **网络支持**: 同时支持 Ingress 和 HTTPRoute
5. **资源合理**: 提供适当的资源请求和限制

### 推荐做法

1. **安全配置**: 设置 securityContext
2. **探针配置**: 根据应用特性配置合理的探针
3. **NOTES.txt**: 提供清晰的使用说明
4. **命名一致**: 使用辅助函数保持命名一致性

## Commit 消息格式

遵循语义化提交：

- `feat(chart-name): add new feature`
- `fix(chart-name): resolve issue`
- `chore: update CI configuration`
- `docs: update README`

## 不要创建

- 每个 Chart 的单独 README（使用 `NOTES.txt`）
- `.helmignore` 文件（本仓库不需要）
- 独立的文档文件夹（`values.yaml` 内联注释即可）

## 可用技能

仓库包含两个 Claude Code 技能：

- `git-workflow`: Git 操作
- `helm-chart-builder`: 创建/重构 Chart

使用 `/git-workflow` 或 `/helm-chart-builder` 调用。

## 资源建议

| 应用类型 | CPU 请求 | 内存请求 | CPU 限制 | 内存限制 |
|---------|----------|----------|----------|----------|
| 轻量工具 | 10m | 50Mi | 100m | 128Mi |
| 常规应用 | 50m | 128Mi | 500m | 512Mi |
| AI 应用 | 100m | 256Mi | 1000m | 1Gi |
| 浏览器服务 | 200m | 512Mi | 2000m | 2Gi |

## 注意事项

- README.md 使用中文（目标受众）
- Chart.yaml 描述可以是中英文
- 所有 Chart 必须有中文和英文的使用说明
