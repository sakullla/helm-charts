# Helm Charts 项目指南

## 项目概述

这是一个个人维护的 Helm Charts 仓库，用于在 Kubernetes 上部署各种自托管应用。仓库托管在 GitHub Pages 上，使用 GitHub Actions 自动发布。

## 项目结构

```
helm-charts/
├── charts/                    # 所有 Helm Charts
│   ├── adguard-home/         # 每个 Chart 一个目录
│   │   ├── Chart.yaml        # Chart 元数据
│   │   ├── values.yaml       # 默认配置值
│   │   ├── templates/        # Kubernetes 模板
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   ├── ingress.yaml
│   │   │   ├── httproute.yaml    # Gateway API 支持
│   │   │   ├── _helpers.tpl      # 模板辅助函数
│   │   │   └── NOTES.txt         # 部署后说明
│   │   └── tests/            # 测试模板
│   └── ...                   # 其他 Charts
├── .github/
│   └── workflows/
│       └── release.yml       # 自动发布工作流
└── README.md                 # 使用文档
```

## 开发规范

### 添加新 Chart

1. 使用 `helm create` 创建基础结构
2. 修改 `Chart.yaml`：
   - 填写正确的 `name` 和 `description`
   - 设置合适的 `version`（从 0.0.1 开始）
   - 设置 `appVersion` 为应用的实际版本
3. 配置 `values.yaml`：
   - 提供合理的默认值
   - 添加详细的注释说明
   - 支持通用配置：replicaCount, image, service, ingress, httpRoute, persistence, resources 等
4. 编写模板文件：
   - 使用 `_helpers.tpl` 中的辅助函数
   - 支持多种服务类型（ClusterIP, NodePort, LoadBalancer）
   - 支持 Ingress 和 Gateway API HTTPRoute
5. 编写 `NOTES.txt`：提供部署后的访问说明

### 通用配置标准

所有 Charts 应支持以下配置：

```yaml
# 基础配置
replicaCount: 1
image:
  repository: <app>/app
  pullPolicy: IfNotPresent
  tag: ""

# 服务配置
service:
  type: ClusterIP
  port: <app-port>

# Ingress 配置
ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts: []
  tls: []

# Gateway API HTTPRoute 配置
httpRoute:
  enabled: false
  parentRefs: []
  hostnames: []
  rules: []

# 持久化配置
persistence:
  enabled: false
  size: 1Gi
  storageClass: ""
  accessMode: ReadWriteOnce

# 资源限制
resources: {}

# 扩缩容
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
```

### 模板辅助函数

所有 Charts 共享标准的 `_helpers.tpl` 模板：

- `{{- define "<chart-name>.name" -}}` - Chart 名称
- `{{- define "<chart-name>.fullname" -}}` - 完整资源名称
- `{{- define "<chart-name>.chart" -}}` - Chart 信息
- `{{- define "<chart-name>.selectorLabels" -}}` - 选择器标签
- `{{- define "<chart-name>.commonLabels" -}}` - 通用标签
- `{{- define "<chart-name>.serviceAccountName" -}}` - 服务账号名称

## CI/CD 流程

### 自动发布

- 触发条件：`main` 分支的 `charts/**` 路径变更
- 使用 `helm/chart-releaser-action` 发布 Charts
- 自动裁剪 `index.yaml` 只保留最新版本
- 自动清理旧 Release/Tag，只保留最近 2 个

### 版本管理

- Chart 版本遵循 [SemVer](https://semver.org/)
- 每次修改 Chart 时更新 `version`
- `appVersion` 应与应用镜像版本保持一致

## 常见问题

### 如何测试 Chart 更改

```bash
# 模板渲染测试
helm template my-release charts/<chart-name>

# 安装测试（dry-run）
helm install my-release charts/<chart-name> --dry-run --debug

# 实际安装测试
helm install my-release charts/<chart-name>
```

### 如何更新已发布的 Chart

1. 修改 Chart 文件
2. 更新 `Chart.yaml` 中的 `version`
3. 提交并推送到 `main` 分支
4. CI 将自动发布新版本

## 外部依赖

- Kubernetes 1.20+
- Helm 3.8.0+
- 可选：Ingress Controller（Nginx, Traefik 等）
- 可选：Gateway API 控制器
