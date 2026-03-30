# DeerFlow Helm Chart

DeerFlow 是字节跳动开源的长时程 AI 研究与编码 Agent 系统，基于 LangGraph 构建，支持研究、编码、创作等多类任务。

本 Chart 基于 [sakullla/deer-flow](https://github.com/sakullla/deer-flow)（upstream: [bytedance/deer-flow](https://github.com/bytedance/deer-flow)）。

## 架构

```
用户请求
    │
    ▼
nginx (端口 2026) — 反向代理
    ├── /api/langgraph/*  → langgraph (LangGraph Server, 2024)
    ├── /api/*            → gateway   (FastAPI Backend, 8001)
    ├── /health /docs     → gateway
    └── /                 → frontend  (Next.js, 3000)
```

## 前置条件

- Kubernetes 1.19+
- Helm 3.0+
- 自行构建并推送 Docker 镜像（见下方说明）

## 构建镜像

在部署前，需先从源码构建镜像：

```bash
# Backend (gateway + langgraph 共用同一镜像)
docker build -t ghcr.io/<your-user>/deer-flow-backend:latest \
  -f backend/Dockerfile .

# Frontend
docker build -t ghcr.io/<your-user>/deer-flow-frontend:latest \
  --target prod -f frontend/Dockerfile .

# Provisioner (可选，K8s 沙箱模式)
docker build -t ghcr.io/<your-user>/deer-flow-provisioner:latest \
  docker/provisioner/
```

## 安装

```bash
helm install my-deer-flow charts/deer-flow \
  --namespace deer-flow --create-namespace \
  --set gateway.image.repository=ghcr.io/<your-user>/deer-flow-backend \
  --set gateway.image.tag=latest \
  --set langgraph.image.repository=ghcr.io/<your-user>/deer-flow-backend \
  --set langgraph.image.tag=latest \
  --set frontend.image.repository=ghcr.io/<your-user>/deer-flow-frontend \
  --set frontend.image.tag=latest \
  --set secrets.TAVILY_API_KEY=tvly-xxx \
  --set secrets.JINA_API_KEY=jina_xxx \
  --set secrets.BETTER_AUTH_SECRET=$(openssl rand -hex 32) \
  --set secrets.OPENAI_API_KEY=sk-xxx
```

## 访问服务

默认以 `ClusterIP` 暴露，通过端口转发访问：

```bash
kubectl port-forward -n deer-flow svc/my-deer-flow-deer-flow-nginx 2026:2026
# 访问 http://localhost:2026
```

或启用 Ingress：

```bash
helm upgrade my-deer-flow charts/deer-flow \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set "ingress.hosts[0].host=deer-flow.example.com" \
  --set "ingress.hosts[0].paths[0].path=/" \
  --set "ingress.hosts[0].paths[0].pathType=Prefix"
```

## 关键配置项

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `gateway.image.repository` | Gateway 镜像 | `ghcr.io/sakullla/deer-flow-backend` |
| `gateway.image.tag` | Gateway 镜像 Tag | `""` (使用 appVersion) |
| `langgraph.image.repository` | LangGraph 镜像 | `ghcr.io/sakullla/deer-flow-backend` |
| `frontend.image.repository` | Frontend 镜像 | `ghcr.io/sakullla/deer-flow-frontend` |
| `nginx.service.port` | Nginx 监听端口 | `2026` |
| `persistence.enabled` | 启用数据持久化 | `true` |
| `persistence.size` | 存储容量 | `10Gi` |
| `persistence.accessMode` | 存储访问模式 | `ReadWriteOnce` |
| `ingress.enabled` | 启用 Ingress | `false` |
| `httpRoute.enabled` | 启用 Gateway API HTTPRoute | `false` |
| `provisioner.enabled` | 启用 K8s 沙箱 Provisioner | `false` |
| `secrets.TAVILY_API_KEY` | Tavily 搜索 API Key（必填） | `""` |
| `secrets.JINA_API_KEY` | Jina 搜索 API Key（必填） | `""` |
| `secrets.BETTER_AUTH_SECRET` | Frontend 鉴权密钥（必填） | `""` |
| `secrets.OPENAI_API_KEY` | OpenAI API Key | `""` |
| `secrets.DEEPSEEK_API_KEY` | DeepSeek API Key | `""` |
| `deerflowConfig` | config.yaml 内容 | `""` |

## DeerFlow 配置文件

通过 `deerflowConfig` 传入 `config.yaml` 内容，挂载至 gateway 和 langgraph 容器：

```yaml
deerflowConfig: |
  SEARCH_API: tavily
  LLM_PROVIDER: openai
  # 更多配置项参考上游文档
```

## 数据持久化

Gateway 和 LangGraph 共享一个 PVC（`DEER_FLOW_HOME`），存储线程、记忆等数据。

> **注意**：多节点集群需将 `persistence.accessMode` 改为 `ReadWriteMany` 并使用支持 RWX 的 StorageClass（如 NFS、CephFS）。

## 验证

```bash
helm lint charts/deer-flow
helm template my-release charts/deer-flow --debug
helm install my-release charts/deer-flow --dry-run --debug -n deer-flow --create-namespace
```
