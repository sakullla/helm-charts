# DeerFlow Helm Chart

DeerFlow 是字节跳动开源的长时程 AI 研究与编码 Agent 系统，基于 LangGraph 构建，支持研究、编码、创作等多类任务。

本 Chart 基于 [sakullla/deer-flow](https://github.com/sakullla/deer-flow)（upstream: [bytedance/deer-flow](https://github.com/bytedance/deer-flow)）。

## 架构

```
用户请求
    │
    ▼
Ingress / HTTPRoute (路径路由)
    ├── /api/langgraph/*  → langgraph (LangGraph Server, 2024)
    ├── /api/*            → gateway   (FastAPI Backend, 8001)
    ├── /health /docs /redoc /openapi.json → gateway
    └── /                 → frontend  (Next.js, 3000)
```

Ingress 和 HTTPRoute 均直接路由到各后端服务，无需额外的反向代理层。

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

默认以 `ClusterIP` 暴露，通过端口转发访问前端：

```bash
kubectl port-forward -n deer-flow svc/my-deer-flow-deer-flow-frontend 3000:3000
# 访问 http://localhost:3000
```

或启用 Ingress：

```bash
helm upgrade my-deer-flow charts/deer-flow \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set "ingress.hosts[0].host=deer-flow.example.com"
```

或启用 Gateway API HTTPRoute：

```bash
helm upgrade my-deer-flow charts/deer-flow \
  --set httpRoute.enabled=true \
  --set "httpRoute.hostnames[0]=deer-flow.example.com" \
  --set "httpRoute.parentRefs[0].name=gateway" \
  --set "httpRoute.parentRefs[0].sectionName=http"
```

## 关键配置项

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `gateway.image.repository` | Gateway 镜像 | `ghcr.io/sakullla/deer-flow-backend` |
| `gateway.image.tag` | Gateway 镜像 Tag | `""` (使用 appVersion) |
| `langgraph.image.repository` | LangGraph 镜像 | `ghcr.io/sakullla/deer-flow-backend` |
| `frontend.image.repository` | Frontend 镜像 | `ghcr.io/sakullla/deer-flow-frontend` |
| `frontend.service.port` | Frontend 端口 | `3000` |
| `gateway.service.port` | Gateway 端口 | `8001` |
| `langgraph.service.port` | LangGraph 端口 | `2024` |
| `persistence.enabled` | 启用数据持久化 | `true` |
| `persistence.size` | 存储容量 | `10Gi` |
| `persistence.accessMode` | 存储访问模式 | `ReadWriteOnce` |
| `ingress.enabled` | 启用 Ingress | `false` |
| `httpRoute.enabled` | 启用 Gateway API HTTPRoute | `false` |
| `provisioner.enabled` | 启用 K8s 沙箱 Provisioner | `false` |
| `llm.openaiBaseUrl` | OpenAI 兼容端点（如 Ollama、DeepSeek） | `""` |
| `llm.azureOpenaiEndpoint` | Azure OpenAI 端点 | `""` |
| `secrets.TAVILY_API_KEY` | Tavily 搜索 API Key（必填） | `""` |
| `secrets.JINA_API_KEY` | Jina 搜索 API Key（必填） | `""` |
| `secrets.BETTER_AUTH_SECRET` | Frontend 鉴权密钥（必填） | `""` |
| `secrets.OPENAI_API_KEY` | OpenAI API Key | `""` |
| `secrets.DEEPSEEK_API_KEY` | DeepSeek API Key | `""` |
| `deerflowConfig` | config.yaml 内容 | `""` |

## DeerFlow 配置文件

通过 `deerflowConfig` 传入 `config.yaml` 内容，挂载至 gateway 和 langgraph 容器。

### 自定义 LLM 端点

要使用自建或第三方 LLM 端点，需在 `deerflowConfig` 中配置 `models`：

```yaml
deerflowConfig: |
  models:
    - name: ollama-llama
      display_name: Ollama Llama
      use: langchain_openai:ChatOpenAI
      model: llama3
      api_key: ollama
      base_url: http://ollama:11434/v1
      request_timeout: 600.0
      max_retries: 2
```

### 自建 Firecrawl 服务

> **注意**：当前版本的 deer-flow（`deerflow.community.firecrawl.tools`）在初始化 `FirecrawlApp` 时只读取 `api_key`，不支持自定义 `api_url`。如需使用自建 Firecrawl，需要修改上游镜像的源码，或等待上游支持。

`FIRECRAWL_API_KEY` 可通过 `secrets` 配置传入：

```yaml
secrets:
  FIRECRAWL_API_KEY: "your-api-key"
```

### 关于 `llm.*` 配置项

`llm.*` 配置项（如 `llm.openaiBaseUrl`）会被注入为环境变量（如 `OPENAI_BASE_URL`），但：

- **不会覆盖** `deerflowConfig` 中的 `models` 配置
- **可能被某些 SDK 自动读取**（如 OpenAI Python SDK 会读取 `OPENAI_BASE_URL`）
- **不保证所有场景生效**

要确保自定义端点生效，请在 `deerflowConfig` 中显式配置 `models` 的 `base_url` 字段。

## 数据持久化

Gateway 和 LangGraph 共享一个 PVC（`DEER_FLOW_HOME`），存储线程、记忆等数据。

> **注意**：多节点集群需将 `persistence.accessMode` 改为 `ReadWriteMany` 并使用支持 RWX 的 StorageClass（如 NFS、CephFS）。

## 验证

```bash
helm lint charts/deer-flow
helm template my-release charts/deer-flow --debug
helm install my-release charts/deer-flow --dry-run --debug -n deer-flow --create-namespace
```
