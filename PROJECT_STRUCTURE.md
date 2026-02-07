# Helm Charts 仓库结构

```
helm-charts/
├── .github/
│   └── workflows/
│       └── release.yml          # CI/CD 自动发布流程
│
├── charts/                      # 所有 Helm Charts
│   ├── adguard-home/
│   ├── affine/
│   ├── ani-rss/
│   ├── ... (40+ charts)
│   └── <chart-name>/
│       ├── Chart.yaml           # Chart 元数据
│       ├── values.yaml          # 默认配置
│       ├── templates/
│       │   ├── _helpers.tpl
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── ingress.yaml
│       │   ├── httproute.yaml
│       │   ├── pvc.yaml
│       │   └── NOTES.txt
│       └── tests/               # 可选测试
│
├── .gitignore                   # Git 忽略规则
├── AGENTS.md                    # Claude Code Agent 配置
├── CLAUDE.md                    # Claude Code 开发指南
├── CONTRIBUTING.md              # 贡献指南
├── LICENSE                      # GPL-3.0 许可证
└── README.md                    # 项目文档（中文）
```

## 分支说明

### main 分支
- Chart 源代码
- CI/CD 配置
- 项目文档

### gh-pages 分支
- 打包后的 Chart (.tgz)
- index.yaml (Helm 仓库索引)
- 自动部署到 GitHub Pages

## 工作流程

### 开发者
1. 在 `main` 分支修改 Chart
2. 升级 `Chart.yaml` 版本
3. 提交并推送到 GitHub

### CI/CD
1. 检测 `charts/**` 变更
2. 打包 Chart
3. 发布到 `gh-pages`
4. 创建 GitHub Release
5. 清理旧版本

### 用户
1. 添加仓库: `helm repo add sakullla https://sakullla.github.io/helm-charts`
2. 安装应用: `helm install my-app sakullla/<chart-name>`
