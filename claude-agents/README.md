# Claude Agents - 7层智能开发体系 🚀

**专为Qt/C++和Python项目构建的分层式AI开发团队**，融合[awesome-claude-agents](https://github.com/vijaythecoder/awesome-claude-agents)的团队协作理念与自定义7层架构。

## 🏗️ 七层体系架构

### 第1层：工具层 (Tool Layer)
**基础设施与开发环境**
- `claude-vs-copilot.md` - AI工具选择与配置
- `development-environment.md` - 开发环境标准化

### 第2层：语言层 (Language Layer) 
**编程语言专业化**
- `cpp-expert.md` - C++17/20专家，Qt框架深度集成
- `python-expert.md` - Python专家，科学计算与自动化

### 第3层：项目层 (Project Layer)
**项目级规范与架构**
- `module-encapsulation-guidelines.md` - 模块封装规范
- `code-refactoring-guidelines.md` - 代码重构指导
- `module-packaging-guidelines.md` - 模块打包规范

### 第4层：角色层 (Role Layer)
**专业化角色分工** (融合awesome-claude-agents)
- `developer.md` - 开发工程师 (对应universal/backend-developer)
- `architect.md` - 系统架构师 (对应orchestrators/tech-lead-orchestrator)  
- `tester.md` - 测试工程师 (基于core理念扩展)
- `auditor.md` - 代码审查师 (对应core/code-reviewer)
- `researcher.md` - 技术研究员 (对应core/code-archaeologist)
- `memory-network-builder.md` - 知识图谱构建师 (自创)

### 第5层：组件层 (Component Layer)
**Qt/C++专业化组件** (项目特色)
- `qt-ui-designer.md` - Qt界面设计专家
- `device-command-tester.md` - 设备通信测试专家
- `ui-tester.md` - UI功能测试专家
- `ui-visual-validator.md` - UI视觉验证专家
- `module-tester.md` - 模块测试专家
- `debugger.md` - 调试专家

### 第6层：任务层 (Task Layer)
**对应GitHub Issues的具体任务**
- 动态生成，基于issue分析自动配置

### 第7层：执行层 (Execute Layer)
**具体操作与实现**
- `canvas-drawing.md` - Obsidian Canvas功能图绘制
- `commit-as-prompt.md` - 提交信息优化

## 🎯 核心特色

### 1. **双系统融合**
- **继承awesome-claude-agents**: 团队协作机制、自动配置能力
- **保留7层架构**: 更细致的分层管理，适配Qt/C++项目特性

### 2. **智能配置系统**
```bash
# 自动检测并配置最适合的agent团队
claude "use @team-configurator and setup agents for Qt/C++ project"
```

### 3. **专业化Qt/C++支持**
- 工业软件开发模式
- 设备通信协议测试  
- Qt界面设计最佳实践
- 模块化架构指导

## 🚀 快速开始

### 1. 安装agents
```bash
# Windows创建符号链接
mklink /D "%USERPROFILE%\.claude\agents\claude-agents" "F:\101_link-notebook\KA-Vault\action\Product-development\development\software\prompt\claude-agents\agents"
```

### 2. 项目初始化
```bash
# 导航到Qt/C++项目目录
claude "use @team-configurator and optimize my Qt/C++ project for the 7-layer agent system"
```

### 3. 开始开发
```bash
# 使用架构师规划功能
claude "use @architect and design a device communication module"

# 使用Qt专家实现界面
claude "use @qt-ui-designer and create settings dialog with validation"
```

## 👥 Agent团队映射

| 功能需求   | 首选Agent                | 备选Agent                 | 说明     |
| ------ | ---------------------- | ----------------------- | ------ |
| 架构设计   | @architect             | @tech-lead-orchestrator | 系统级设计  |
| Qt界面开发 | @qt-ui-designer        | @frontend-developer     | UI组件设计 |
| 设备通信   | @device-command-tester | @backend-developer      | 协议测试   |
| 代码审查   | @auditor               | @code-reviewer          | 质量保证   |
| 性能优化   | @performance-optimizer | @cpp-expert             | 性能调优   |
| 测试用例   | @tester/@ui-tester     | @module-tester          | 测试策略   |

## 📁 目录结构

```
claude-agents/
├── agents/
│   ├── tool-layer/          # 第1层：工具配置
│   ├── language-layer/      # 第2层：语言专家  
│   ├── project-layer/       # 第3层：项目规范
│   ├── role-layer/          # 第4层：角色专家
│   ├── component-layer/     # 第5层：组件专家 (Qt/C++)
│   ├── task-layer/          # 第6层：任务配置
│   ├── execute-layer/       # 第7层：执行操作
│   └── qt-cpp/              # Qt/C++专用agents (当前项目移入)
├── scripts/
│   ├── deploy.ps1           # 一键部署脚本
│   └── configure-team.py    # 团队配置脚本
└── README.md
```

## 🛠️ 开发原则

### Linus式品味 (Good Taste)
- **简洁性**: 消除特殊情况，统一处理逻辑
- **分层清晰**: 每层职责单一，接口明确
- **向后兼容**: 永不破坏现有用户空间

### 实用主义
- 解决真实问题，而非理论完美
- Qt/C++工业软件的实际需求导向
- 快速迭代，持续改进

## ⚠️ 使用须知

- **Token消耗**: 多Agent协作会消耗较多tokens，建议订阅用户使用
- **专业化**: 针对Qt/C++项目优化，其他技术栈可参考awesome-claude-agents
- **实验性**: 7层架构正在验证中，欢迎反馈改进建议

## 🚀 一键部署

```powershell
# Windows PowerShell
.\scripts\deploy.ps1 -ProjectPath "C:\your-qt-project"

# 或使用Python脚本  
python scripts\configure-team.py --stack qt-cpp --project-path .
```

## 📄 许可证

MIT License - 自由使用于您的项目！

---

**结合awesome-claude-agents的团队协作 + 7层专业化架构 = Qt/C++项目的终极AI开发体验**