---
name: architecture-principles-template
---

# 通用架构设计原则模板

## 核心设计原则

### 1. 单一职责和单一来源 (Single Responsibility & Single Source of Truth)
- 每个模块只负责一个功能，避免职责混杂
- 每类数据只在一个地方定义和维护
- 核心定义、规则、映射关系统一管理

### 2. 类型定义分层原则 (Type Definition Layering Principle)

**判断准则**：
- **跨模块共享且稳定** → 放入公共基础模块
- **模块专用或易变** → 保留在各自模块内
- **频繁变化** → 通过适配器隔离

**公共基础模块放置规则**：
```
// ✅ 基础枚举和标识符
enum class ComponentType { TypeA, TypeB, TypeC };
enum class ProtocolType { HTTP, TCP, Custom };
enum class ConnectionType { Direct, Proxied, Cached };

// ✅ 核心数据结构（稳定且跨模块）
struct ComponentId { string value; };
struct RequestId { string value; };

// ❌ 不放入：具体实现、配置细节、内部状态
```

**模块内保留**：
```
// 各模块保留自己的实现细节
namespace Project::Component::Internal {
    struct ComponentConfig { /* 具体配置 */ };
}

namespace Project::Communication::Internal {
    struct ConnectionState { /* 连接状态 */ };
}
```

### 3. 组合优于继承 (Composition over Inheritance)
- 最大继承深度：3层
- 通过依赖注入实现功能复用
- 接口基于多个实现时才抽象

### 4. 接口与数据分离原则
- 接口只定义行为契约
- 数据结构专注信息表达
- 通过适配器连接不同层次

## 架构原则

### 1. 最小接口 (Minimal Interface)
接口只暴露必要功能，客户端不依赖不需要的方法。

### 2. 职责分离 (Separation of Concerns)
- 接口与实现完全分离
- **Connection**: 纯数据传输
- **Protocol**: 纯编解码
- **Service**: 业务逻辑封装
- **Registry**: 对象生命周期管理

### 3. 无状态设计 (Stateless Design)
组件尽量无状态，状态集中管理，提高可测试性。

### 4. 配置驱动 (Configuration Driven)
映射关系、行为规则通过配置定义，支持运行时调整。

## 实践检查

### 类型定义检查清单
- [ ] 基础枚举是否在公共基础模块中？
- [ ] 跨模块数据结构是否统一定义？
- [ ] 实现细节是否保留在模块内？
- [ ] 是否存在重复类型定义？

### 代码质量检查
- [ ] 继承深度是否超过3层？
- [ ] 接口是否过于庞大？
- [ ] 模块职责是否清晰？
- [ ] 组件是否可独立测试？

---

## 项目定制说明

此模板应根据具体项目需求进行定制：

1. **技术栈适配**：根据项目使用的编程语言和框架调整示例代码
2. **模块结构**：根据项目实际模块划分调整命名空间和目录结构
3. **业务领域**：根据项目业务特点调整具体的组件类型和协议类型
4. **工具链集成**：根据项目构建系统和开发工具调整检查清单

*简洁明确的设计原则，专注解决实际问题。*