# 贡献指南

感谢你对本项目的关注！本文档将帮助你了解如何为项目做出贡献。

## 快速开始

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 添加新 Chart

### 方法 1: 从头创建

```bash
# 创建基础结构
helm create charts/my-app

# 编辑关键文件
cd charts/my-app
```

编辑 `Chart.yaml`:
```yaml
apiVersion: v2
name: my-app
description: 应用描述
type: application
version: 0.1.0
appVersion: "1.0.0"
```

### 方法 2: 复制现有 Chart

```bash
# 复制相似的 Chart
cp -r charts/vaultwarden charts/my-app

# 替换名称
cd charts/my-app
find . -type f -exec sed -i 's/vaultwarden/my-app/g' {} +
```

### Chart 必备文件

```
charts/my-app/
├── Chart.yaml          # Chart 元数据
├── values.yaml         # 默认配置
└── templates/
    ├── _helpers.tpl    # 模板辅助函数
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── httproute.yaml
    ├── pvc.yaml
    ├── serviceaccount.yaml
    └── NOTES.txt       # 安装后提示
```

### values.yaml 标准结构

```yaml
# 副本数
replicaCount: 1

# 镜像配置
image:
  repository: app/image
  pullPolicy: IfNotPresent
  tag: ""

# 服务配置
service:
  type: ClusterIP
  port: 80

# Ingress 配置
ingress:
  enabled: false
  className: ""
  hosts: []

# Gateway API HTTPRoute
httpRoute:
  enabled: false
  parentRefs: []
  hostnames: []

# 持久化存储
persistence:
  enabled: false
  size: 1Gi
  storageClass: ""

# 资源限制
resources: {}

# 环境变量（公开）
env: {}

# 敏感信息（Secret）
secrets: {}
```

### 测试 Chart

```bash
# 语法检查
helm lint charts/my-app

# 渲染模板
helm template test charts/my-app --debug

# 模拟安装
helm install test charts/my-app --dry-run --debug

# 实际安装到测试集群
helm install test charts/my-app -n test --create-namespace
```

## 版本管理

### Chart 版本规则（SemVer）

- **MAJOR (x.0.0)**: 破坏性变更
- **MINOR (0.x.0)**: 新功能
- **PATCH (0.0.x)**: Bug 修复

### 更新版本

每次修改 Chart 必须更新 `Chart.yaml` 中的 `version`:

```yaml
version: 0.2.0  # 从 0.1.0 升级
```

## Commit 消息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

### 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `chore`: 构建/工具变更
- `refactor`: 代码重构
- `test`: 测试相关

### 示例

```bash
# 添加新功能
git commit -m "feat(lobehub): add OAuth2 authentication support"

# 修复 Bug
git commit -m "fix(vaultwarden): correct persistence mount path"

# 更新文档
git commit -m "docs: update installation guide"

# 版本升级
git commit -m "chore(adguard-home): bump version to 0.2.0"
```

## Pull Request 规范

### PR 标题

遵循 commit 消息规范：

```
feat(chart-name): add new feature
```

### PR 描述模板

```markdown
## 变更类型
- [ ] 新 Chart
- [ ] Bug 修复
- [ ] 功能增强
- [ ] 文档更新

## 变更说明
简要描述你的变更内容

## 测试
- [ ] 通过 `helm lint`
- [ ] 通过 `helm template`
- [ ] 通过 `--dry-run` 测试
- [ ] 在实际集群中测试

## 相关 Issue
Closes #123
```

## Chart 开发最佳实践

### 1. 使用模板辅助函数

```yaml
# 不推荐
name: my-app-deployment

# 推荐
name: {{ include "my-app.fullname" . }}
```

### 2. 配置验证

在 `_helpers.tpl` 中添加验证：

```yaml
{{- if and .Values.ingress.enabled .Values.httpRoute.enabled }}
{{- fail "ingress 和 httpRoute 不能同时启用" }}
{{- end }}
```

### 3. 资源限制

为所有 Chart 提供合理的默认资源配置：

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### 4. 健康检查

配置适当的探针：

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5
```

### 5. 安全配置

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  capabilities:
    drop:
    - ALL
```

## CI/CD 流程

### 自动发布

当你的 PR 合并到 `main` 分支后：

1. GitHub Actions 检测 `charts/` 目录变更
2. 自动打包并发布 Chart
3. 更新 `index.yaml`
4. 创建 GitHub Release
5. 清理旧版本

### 发布要求

- Chart 版本必须升级
- 通过所有 lint 检查
- PR 已经过 Review

## 代码审查要点

审查者会检查：

- [ ] Chart 版本已更新
- [ ] values.yaml 有详细注释
- [ ] 支持 ingress 和 httpRoute
- [ ] 资源限制配置合理
- [ ] 探针配置正确
- [ ] NOTES.txt 提供清晰的使用说明
- [ ] 遵循项目命名约定

## 获取帮助

- 查看现有 Chart 作为参考
- 阅读 [Helm 官方文档](https://helm.sh/docs/)
- 在 Issue 中提问
- 查看 CLAUDE.md 了解项目架构

## 许可证

贡献代码即表示同意使用 [GPL-3.0](LICENSE) 许可证。
