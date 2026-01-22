# Claude Agents 7层体系一键部署脚本
# 用法: .\deploy.ps1 -ProjectPath "C:\your-qt-project" [-Force]

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

Write-Host "🚀 Claude Agents 7层体系部署器" -ForegroundColor Cyan
Write-Host ("=" * 50)

# 检查Claude Code是否已安装
$claudeExists = Get-Command "claude" -ErrorAction SilentlyContinue
if (-not $claudeExists) {
    Write-Error "❌ Claude Code未安装。请先安装: https://claude.ai/code"
    exit 1
}

# 验证项目路径
if (-not (Test-Path $ProjectPath)) {
    Write-Error "❌ 项目路径不存在: $ProjectPath"
    exit 1
}

Write-Host "📁 项目路径: $ProjectPath" -ForegroundColor Green

# 设置路径
$AgentsSourcePath = Split-Path $PSScriptRoot -Parent
$AgentsTargetPath = "$env:USERPROFILE\.claude\agents\claude-agents"
$ProjectAgentsPath = "$ProjectPath\.claude\agents"

Write-Host "📦 Agent库路径: $AgentsSourcePath" -ForegroundColor Yellow

# 创建.claude目录结构
Write-Host "📂 创建目录结构..."
New-Item -Path "$env:USERPROFILE\.claude\agents" -ItemType Directory -Force | Out-Null
New-Item -Path "$ProjectPath\.claude" -ItemType Directory -Force | Out-Null

# 检查是否已存在符号链接
if (Test-Path $AgentsTargetPath) {
    if ($Force) {
        Write-Host "🔄 强制更新现有链接..." -ForegroundColor Yellow
        Remove-Item $AgentsTargetPath -Force -Recurse
    } else {
        Write-Host "⚠️  已存在agent链接。使用 -Force 参数强制更新" -ForegroundColor Yellow
        $continue = Read-Host "是否继续? (y/N)"
        if ($continue.ToLower() -ne 'y') {
            Write-Host "❌ 部署已取消" -ForegroundColor Red
            exit 0
        }
        Remove-Item $AgentsTargetPath -Force -Recurse
    }
}

# 创建符号链接到用户级agents目录
Write-Host "🔗 创建符号链接到全局agents..."
try {
    # 使用mklink创建目录符号链接
    $mklinkCmd = "mklink /D `"$AgentsTargetPath`" `"$AgentsSourcePath\agents`""
    cmd /c $mklinkCmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 全局agents链接创建成功" -ForegroundColor Green
    } else {
        throw "mklink命令失败"
    }
} catch {
    Write-Error "❌ 创建符号链接失败: $_"
    Write-Host "💡 尝试以管理员身份运行此脚本" -ForegroundColor Yellow
    exit 1
}

# 项目级符号链接 (可选)
$projectLink = Read-Host "是否也在项目中创建agents链接? 便于项目团队共享 (y/N)"
if ($projectLink.ToLower() -eq 'y') {
    $ProjectSymlinkPath = "$ProjectPath\.claude\agents\claude-agents"
    
    if (Test-Path $ProjectSymlinkPath) {
        Remove-Item $ProjectSymlinkPath -Force -Recurse
    }
    
    try {
        $projectMklinkCmd = "mklink /D `"$ProjectSymlinkPath`" `"$AgentsSourcePath\agents`""
        cmd /c $projectMklinkCmd
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ 项目级agents链接创建成功" -ForegroundColor Green
        }
    } catch {
        Write-Warning "⚠️  项目级链接创建失败: $_"
    }
}

# 验证部署结果
Write-Host "🔍 验证部署..."
Push-Location $ProjectPath

# 检查agents是否可用
$agentCheck = claude /agents 2>&1
if ($agentCheck -match "claude-agents" -or $agentCheck -match "team-configurator") {
    Write-Host "✅ Agents部署成功!" -ForegroundColor Green
} else {
    Write-Warning "⚠️  无法验证agents，请手动检查"
}

# 检测项目类型
$isQtProject = Test-Path "$ProjectPath\CMakeLists.txt" -or Test-Path "$ProjectPath\*.pro"
$hasCppFiles = (Get-ChildItem "$ProjectPath\*.cpp" -Recurse | Measure-Object).Count -gt 0

if ($isQtProject -and $hasCppFiles) {
    Write-Host "🎯 检测到Qt/C++项目" -ForegroundColor Cyan
    
    # 自动配置AI团队
    Write-Host "🤖 正在配置AI开发团队..."
    $configCmd = 'claude "use @team-configurator and optimize my Qt/C++ project for the 7-layer agent system"'
    
    Write-Host "运行命令: $configCmd" -ForegroundColor Gray
    try {
        Invoke-Expression $configCmd
        Write-Host "✅ AI团队配置完成!" -ForegroundColor Green
    } catch {
        Write-Warning "⚠️  自动配置失败，请手动运行配置命令"
    }
} else {
    Write-Host "📝 项目类型检测结果:" -ForegroundColor Yellow
    Write-Host "   Qt项目: $(if($isQtProject){'Yes'}else{'No'})"
    Write-Host "   C++文件: $(if($hasCppFiles){'Yes'}else{'No'})"
    Write-Host "💡 手动运行配置: claude `"use @team-configurator and configure agents for my project`"" -ForegroundColor Cyan
}

Pop-Location

# 显示可用命令示例
Write-Host ""
Write-Host "🎉 部署完成! 可用命令示例:" -ForegroundColor Green
Write-Host "   架构设计: claude `"use @architect and design a device communication module`""
Write-Host "   Qt界面:   claude `"use @qt-ui-designer and create settings dialog`""
Write-Host "   代码审查: claude `"use @auditor and review my latest changes`""
Write-Host "   性能优化: claude `"use @performance-optimizer and analyze bottlenecks`""
Write-Host ""
Write-Host "📚 查看所有agents: claude /agents" -ForegroundColor Cyan
Write-Host "🔧 重新配置团队: claude `"use @team-configurator`"" -ForegroundColor Cyan

Write-Host ""
Write-Host "✨ 7层AI开发体系已准备就绪!" -ForegroundColor Green
Write-Host ("=" * 50)