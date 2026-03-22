# OpenClaw

[OpenClaw](https://openclaw.ai) 是一个运行在自己服务器上的个人 AI 助手，支持通过 WhatsApp、Telegram、Discord、Slack、iMessage 等渠道访问。支持 Anthropic、OpenAI、Google、OpenRouter 以及任何兼容 Anthropic API 的第三方端点。

## 前置条件

- Kubernetes 1.23+
- Helm 3.0+
- 至少一个 AI 提供商的 API Key（Anthropic、OpenAI、OpenRouter 等）

## 安装

```bash
# 添加 Helm 仓库
helm repo add sakullla https://sakullla.github.io/helm-charts
helm repo update

# 使用 Anthropic API Key 安装
helm install my-openclaw sakullla/openclaw \
  --set ai.anthropic.apiKey="sk-ant-..." \
  --set gateway.token="your-secure-gateway-token" \
  -n openclaw --create-namespace

# 使用第三方兼容 Anthropic 端点（如 LiteLLM）
helm install my-openclaw sakullla/openclaw \
  --set ai.anthropic.apiKey="your-litellm-key" \
  --set ai.anthropic.baseUrl="http://litellm.default.svc.cluster.local:4000" \
  --set gateway.token="your-secure-gateway-token" \
  -n openclaw --create-namespace
```

## 配置

### 关键配置项

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `image.repository` | 镜像仓库 | `ghcr.io/openclaw/openclaw` |
| `image.tag` | 镜像标签 | chart appVersion |
| `service.port` | Gateway HTTP 端口 | `18789` |
| `service.bridgePort` | Bridge WebSocket 端口 | `18790` |
| `persistence.enabled` | 启用持久化存储（配置、会话） | `true` |
| `persistence.size` | PVC 大小 | `2Gi` |
| `persistence.mountPath` | 容器内挂载路径 | `/home/node/.openclaw` |

### Gateway 配置

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `gateway.token` | Gateway 安全令牌（`OPENCLAW_GATEWAY_TOKEN`） | `""` |
| `gateway.timezone` | 容器时区（`TZ`） | `"UTC"` |
| `gateway.allowInsecurePrivateWs` | 允许非加密 WebSocket（`OPENCLAW_ALLOW_INSECURE_PRIVATE_WS`） | `""` |

### AI 提供商配置

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `ai.anthropic.apiKey` | Anthropic API Key（`ANTHROPIC_API_KEY`） | `""` |
| `ai.anthropic.baseUrl` | 第三方兼容 Anthropic 端点（`ANTHROPIC_BASE_URL`） | `""` |
| `ai.anthropic.sessionKey` | Claude Code CLI setup-token（`CLAUDE_AI_SESSION_KEY`） | `""` |
| `ai.anthropic.webSessionKey` | Claude Web 会话密钥（`CLAUDE_WEB_SESSION_KEY`） | `""` |
| `ai.anthropic.webCookie` | Claude Web Cookie（`CLAUDE_WEB_COOKIE`） | `""` |

### 其他 AI 提供商

通过 `secrets` 字段传入其他提供商的 API Key：

```yaml
secrets:
  OPENROUTER_API_KEY: "sk-or-..."
  GROQ_API_KEY: "gsk-..."
  GOOGLE_API_KEY: "AIza..."
```

## 使用第三方兼容 Anthropic 的供应商

OpenClaw 的 `anthropic/*` 模型流量默认发往 `api.anthropic.com`。
通过设置 `ANTHROPIC_BASE_URL` 可将流量路由到任何实现了 Anthropic Messages API 的代理或网关：

```yaml
# values.yaml 示例：通过 LiteLLM 代理路由 Anthropic 流量
ai:
  anthropic:
    apiKey: "your-litellm-master-key"
    baseUrl: "http://litellm.default.svc.cluster.local:4000"
```

常见的兼容 Anthropic API 的供应商：

- **LiteLLM** — 统一 LLM 网关，支持 100+ 提供商
- **OpenRouter** — 多模型路由，部分端点兼容 Anthropic Messages API
- **Cloudflare AI Gateway** — 企业级 AI 流量管理
- **Vercel AI Gateway** — Vercel 托管的 AI 代理

## 示例 values 配置

### 直连 Anthropic API

```yaml
ai:
  anthropic:
    apiKey: "sk-ant-..."

gateway:
  token: "your-secure-token"
  timezone: "Asia/Shanghai"

persistence:
  enabled: true
  size: 2Gi

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: openclaw.example.com
      paths:
        - path: /
          pathType: Prefix
```

### 通过 LiteLLM 使用国内或企业 AI 服务

```yaml
ai:
  anthropic:
    apiKey: "litellm-master-key"
    baseUrl: "http://litellm:4000"

secrets:
  OPENROUTER_API_KEY: "sk-or-..."

gateway:
  token: "your-secure-token"
```

## 验证

```bash
helm lint charts/openclaw
helm template my-release charts/openclaw
helm install my-release charts/openclaw --dry-run --debug -n openclaw --create-namespace
```

连接 Gateway 后验证健康状态：

```bash
kubectl -n openclaw port-forward svc/my-openclaw 18789:18789
curl http://localhost:18789/healthz
```
