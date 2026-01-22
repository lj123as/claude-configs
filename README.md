# claude-configs

按场景组织的 Claude 配置库，支持一键切换开发/研究/量化等工作环境。

## 特性

- 🎯 **场景驱动** - profiles.yaml 定义场景，一键切换工作环境
- 📦 **类型组织** - Skills / Agents / MCPs / Hooks / Commands / Rules / Prompts
- 🔄 **上游同步** - 追踪外部优质配置，保持更新
- 🔗 **符号链接** - 无侵入式集成到 Claude Code / Codex

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/lj123as/claude-configs.git
cd claude-configs

# 查看可用场景
python scripts/link-profile.py --list

# 切换到开发场景
python scripts/link-profile.py daily-dev

# 切换到全量场景
python scripts/link-profile.py full
```

## 场景列表

| 场景 | 描述 | 包含配置 |
|------|------|----------|
| `daily-dev` | 日常开发 | mcp-builder |
| `full` | 全量加载 | 所有配置 |

## 目录结构

```
claude-configs/
├── profiles.yaml          # 场景配置映射
├── SOURCES.yaml           # 上游来源追踪
├── skills/                # 技能定义
│   └── _upstream/         # 上游同步的技能
├── agents/                # 子代理配置
├── mcps/                  # MCP 外部工具集成
├── hooks/                 # 触发式自动化
├── commands/              # 斜杠命令
├── rules/                 # 全局规则
├── prompts/               # 提示词模板
└── scripts/               # 辅助脚本
```

## 添加自定义配置

1. 在对应类型目录下创建配置，如 `skills/my-skill/SKILL.md`
2. 在 `profiles.yaml` 中将配置添加到合适的场景
3. 运行 `python scripts/link-profile.py <profile>` 激活

## 同步上游配置

```bash
# 同步所有上游（需要 sync-upstream.sh）
./scripts/sync-upstream.sh

# 上游配置会保存到 _upstream/ 子目录
```

## profiles.yaml 格式

```yaml
profiles:
  my-profile:
    description: "我的场景"
    extends: daily-dev          # 可选：继承其他场景
    skills:
      - my-skill
      - _upstream/mcp-builder
    agents:
      - my-agent
    # ... 其他类型

default: daily-dev
target: ~/.claude
```

## 许可证

MIT
