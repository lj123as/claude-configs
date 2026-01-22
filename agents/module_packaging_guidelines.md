# 模块打包和分发指南

## 1. 概述

本文档描述了LA工业软件的模块打包策略，旨在实现：
- 自动化库文件管理
- 易于分享的独立分发包
- 开发和生产环境的统一配置
- 模块化部署支持

> **相关文档**:
> - [模块封装指南](KA/action/Product-development/development/software/development_system/guidelines/project/module_encapsulation_guidelines.md) - 详细的模块设计和封装规范
> - 本文档专注于构建系统和分发策略

## 2. 当前问题分析

### 2.1 现有问题
- 每个新模块都需要手动添加复制命令
- 库文件分散在不同目录，不利于分发
- 缺乏统一的打包策略
- 开发和部署环境配置不一致

### 2.2 目标架构
```
build/
├── Debug/
│   ├── bin/                    # 运行时目录
│   │   ├── CSPC_LA_function.exe
│   │   ├── *.dll               # 所有依赖库
│   │   └── plugins/            # Qt插件
│   ├── lib/                    # 开发库目录
│   │   ├── *.a                 # 静态库
│   │   └── *.lib               # 导入库
│   └── dist/                   # 分发包目录
│       ├── CSPC_LA_function.exe
│       ├── libs/               # 分发库
│       ├── plugins/            # Qt插件
│       └── config/             # 配置文件
```

## 3. 自动化库管理解决方案

### 3.1 CMake函数式库复制

在主CMakeLists.txt中添加通用函数：

```cmake
# 自动复制库文件的通用函数
function(copy_target_to_runtime target_name)
    if(WIN32 AND TARGET ${target_name})
        get_target_property(target_type ${target_name} TYPE)
        if(target_type STREQUAL "SHARED_LIBRARY")
            add_custom_command(TARGET ${target_name} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:${target_name}>
                ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                COMMENT "Copying ${target_name} to runtime directory"
            )
        endif()
    endif()
endfunction()

# 自动发现并复制所有LA库
function(copy_all_la_libraries)
    # 获取所有目标
    get_property(all_targets DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS)
    
    foreach(target ${all_targets})
        # 只处理LA开头的共享库
        if(target MATCHES "^LA_.*_lib$")
            copy_target_to_runtime(${target})
        endif()
    endforeach()
endfunction()

# 在主程序配置后调用
copy_all_la_libraries()
```

### 3.2 分发包自动生成

```cmake
# 创建分发包目标
add_custom_target(create_distribution
    COMMENT "Creating distribution package"
)

# 复制主程序
add_custom_command(TARGET create_distribution POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/dist
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:${PROJECT_NAME}>
    ${CMAKE_BINARY_DIR}/dist/
)

# 复制所有依赖库到分发目录
add_custom_command(TARGET create_distribution POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/dist/libs
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    ${CMAKE_BINARY_DIR}/dist/
    COMMENT "Copying all dependencies to distribution directory"
)

# 创建便携式启动脚本
add_custom_command(TARGET create_distribution POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Creating portable launcher..."
    COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_SOURCE_DIR}/scripts/portable_launcher.bat
    ${CMAKE_BINARY_DIR}/dist/
)
```

### 3.3 模块自动注册机制

在core/CMakeLists.txt中添加：

```cmake
# 模块自动注册宏
macro(register_la_module module_name)
    # 添加到全局模块列表
    set_property(GLOBAL APPEND PROPERTY LA_MODULES ${module_name})
    
    # 如果是共享库，自动添加到复制列表
    get_target_property(target_type ${module_name} TYPE)
    if(target_type STREQUAL "SHARED_LIBRARY")
        set_property(GLOBAL APPEND PROPERTY LA_SHARED_MODULES ${module_name})
    endif()
endmacro()

# 在每个模块的CMakeLists.txt中调用
# register_la_module(LA_xx_lib)
```

## 4. 实施步骤

### 4.1 第一阶段：重构现有配置
1. 移除现有的手动复制命令
2. 实现通用库复制函数
3. 测试自动发现机制

### 4.2 第二阶段：分发包生成
1. 实现分发包自动生成
2. 创建便携式启动器
3. 添加配置文件管理

### 4.3 第三阶段：模块注册系统
1. 实现模块自动注册
2. 更新所有现有模块
3. 文档和示例更新

## 5. 配置示例

### 5.1 便携式启动器 (portable_launcher.bat)
```batch
@echo off
set APP_DIR=%~dp0
set PATH=%APP_DIR%;%APP_DIR%\libs;%PATH%
start "" "%APP_DIR%\CSPC_LA_function.exe"
```

### 5.2 模块CMakeLists.txt模板
```cmake
# 模块配置
set(TARGET_NAME LA_newmodule_lib)

# 创建库
add_library(${TARGET_NAME} SHARED ${SOURCES})

# 自动注册模块
register_la_module(${TARGET_NAME})

# 其他配置...
```

## 6. 优势

### 6.1 开发优势
- 新模块无需手动配置复制
- 统一的构建和部署流程
- 自动化依赖管理

### 6.2 分发优势
- 一键生成完整分发包
- 便携式部署支持
- 清晰的目录结构

### 6.3 维护优势
- 减少手动配置错误
- 统一的模块管理
- 易于扩展和修改

## 7. 后续规划

1. **集成CI/CD** - 自动构建和打包
2. **版本管理** - 库版本兼容性检查
3. **插件系统** - 动态模块加载
4. **安装程序** - 专业的安装包生成

## 8. 注意事项

- 确保所有模块遵循命名约定
- 定期测试分发包的完整性
- 保持文档和实际配置同步
- 考虑不同平台的兼容性
