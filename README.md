<p align="center">
  <img src="web/static/logo.png" alt="VocaMac" width="128" height="128">
</p>

<h1 align="center">VocaMac</h1>

<p align="center"><strong>你的声音，你的 Mac，你的隐私。由 AI 驱动的开源听写工具。</strong></p>

<div align="center">
  
[![Build & Test](https://github.com/fwz233-RE/vocamac-zh-CN/actions/workflows/ci.yml/badge.svg)](https://github.com/fwz233-RE/vocamac-zh-CN/actions/workflows/ci.yml)
[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS%2013%2B-lightgrey.svg)](https://github.com/fwz233-RE/vocamac-zh-CN)
[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org)
[![Release](https://img.shields.io/github/v/release/fwz233-RE/vocamac-zh-CN?include_prereleases&label=Release)](https://github.com/fwz233-RE/vocamac-zh-CN/releases)
[![Nightly](https://img.shields.io/badge/Nightly-download-blueviolet)](https://github.com/fwz233-RE/vocamac-zh-CN/releases/tag/nightly)

[![Powered by WhisperKit](https://img.shields.io/badge/Powered%20by-WhisperKit-blueviolet.svg)](https://github.com/argmaxinc/WhisperKit)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Optimized-black.svg?logo=apple&logoColor=white)](https://github.com/fwz233-RE/vocamac-zh-CN)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local-brightgreen.svg)](https://github.com/fwz233-RE/vocamac-zh-CN)
[![Works Offline](https://img.shields.io/badge/Works-Offline-success.svg)](https://github.com/fwz233-RE/vocamac-zh-CN)

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/fwz233-RE/vocamac-zh-CN/pulls)
[![GitHub Issues](https://img.shields.io/github/issues/fwz233-RE/vocamac-zh-CN)](https://github.com/fwz233-RE/vocamac-zh-CN/issues)
[![GitHub Stars](https://img.shields.io/github/stars/fwz233-RE/vocamac-zh-CN?style=social)](https://github.com/fwz233-RE/vocamac-zh-CN/stargazers)
[![Twitter Follow](https://img.shields.io/twitter/follow/jatinkrmalik?style=social)](https://x.com/intent/user?screen_name=jatinkrmalik)

</div>

<p align="center">开口说话，文字自动输入。100% 离线、开源的 macOS 语音转文字工具，由 WhisperKit 驱动。无需云端、无需订阅、数据不离开你的设备。只需按住快捷键说话，文字就会出现在光标所在位置。</p>

---

## ✨ 功能特性

- **🔒 100% 本地处理** - 所有音频处理都在本机完成。无需联网 — Tiny 模型已内置，开箱即用、完全离线。
- **⌨️ 系统级文字注入** - 转写结果会输入到光标所在位置：浏览器、Slack、VS Code、电子表格、终端 — 无处不在。
- **🎯 按住说话（Push-to-Talk）** - 按住快捷键（默认：右 Option）开始录音，松开后转写。
- **👆 双击切换** - 双击快捷键开始/停止录音。
- **🧠 智能模型选择** - 自动检测硬件（Apple Silicon/Intel、内存），通过 WhisperKit 推荐最佳 Whisper 模型。
- **⚡ 原生 Apple 加速** - 在 Apple Silicon 上使用 CoreML + Metal + 神经网络引擎加速，无需手动配置。
- **📊 可视化反馈** - 录音时菜单栏图标会隐藏，转写时变色，弹出面板显示音频输入电平。
- **🔄 自动更新** - 内置更新检查器在启动时查询 GitHub Releases，可在应用内一键下载并安装最新版本。
- **⚙️ 可配置** - 可自定义快捷键、模型、语言、静音检测阈值等。

---

## 📸 截图

<p align="center">
  <img src="docs/screenshots/popover-panel.png" alt="VocaMac Popover" width="400">
  <br>
  <em>菜单栏弹出面板，显示状态与控制项</em>
</p>

<p align="center">
  <img src="docs/screenshots/menu-bar-idle.png" alt="Menu Bar - Idle" width="250">
  &nbsp;&nbsp;
  <img src="docs/screenshots/menu-bar-recording.png" alt="Menu Bar - Recording" width="250">
  <br>
  <em>菜单栏图标：空闲（左）；录音时从菜单栏隐藏（右为示意）</em>
</p>

<p align="center">
  <img src="docs/screenshots/settings-general.png" alt="Settings - General" width="400">
  &nbsp;&nbsp;
  <img src="docs/screenshots/settings-models.png" alt="Settings - Models" width="400">
  <br>
  <em>设置：通用（左）与模型页，含资源监控（右）</em>
</p>

<p align="center">
  <img src="docs/screenshots/settings-audio.png" alt="Settings - Audio" width="400">
  &nbsp;&nbsp;
  <img src="docs/screenshots/settings-about.png" alt="Settings - About" width="400">
  <br>
  <em>设置：音频（左）与关于（右）</em>
</p>

<p align="center">
  <img src="docs/screenshots/cursor-indicator.png" alt="Cursor Indicator" width="400">
  <br>
  <em>录音时在文本光标附近显示的浮动麦克风指示器</em>
</p>

---

## 🏛️ 为什么选择 WhisperKit？

VocaMac 使用 [WhisperKit](https://github.com/argmaxinc/WhisperKit) 而非原生 whisper.cpp，原因如下：

| | WhisperKit | whisper.cpp |
|---|-----------|-------------|
| **语言** | 纯 Swift（原生） | C++（需要桥接） |
| **Apple Silicon** | CoreML + 神经网络引擎 | 仅 Metal |
| **SPM 集成** | 一行依赖即可 | 复杂的 vendoring |
| **模型格式** | CoreML（按设备优化） | GGML（通用） |
| **流式处理** | 原生 async/await | 手动线程管理 |
| **质量** | 相同的 OpenAI Whisper 模型 | 相同的 OpenAI Whisper 模型 |
| **维护** | Argmax Inc.（商业） | 社区 |

准确度相同，Apple 平台集成显著更好。

---

## 📋 系统要求

- **macOS 13（Ventura）** 或更高版本
- **Apple Silicon**（M1/M2/M3/M4）
- **Xcode 15+** 或 Swift 5.9+（仅源码构建时需要）

### 权限

VocaMac 需要三项 macOS 权限：

| 权限 | 用途 |
|---|---|
| **麦克风** | 采集语音用于转写 |
| **辅助功能（Accessibility）** | 全局快捷键与向其他应用注入文字 |
| **输入监控（Input Monitoring）** | 系统级检测快捷键按下 |

> **注意：** 授予输入监控权限后，需要重启 VocaMac 才能生效。

---

## 🚀 快速开始

### 方式一：下载 DMG（推荐）

1. 从 [Releases 页面](https://github.com/fwz233-RE/vocamac-zh-CN/releases) 下载最新的 `VocaMac-x.x.x-arm64.dmg`
2. **打开** DMG，将 VocaMac 拖入「应用程序」文件夹
3. 从「应用程序」**打开** VocaMac
4. 按提示**授予权限**：麦克风、辅助功能、输入监控

> VocaMac 已通过 Apple **Developer ID 签名并公证** — macOS 可直接打开，不会出现安全警告。

### 方式二：从源码构建（推荐）

```bash
git clone https://github.com/fwz233-RE/vocamac-zh-CN.git
cd vocamac
make install
```

这会构建 VocaMac、安装到 `/Applications` 并启动应用。权限直接授予 VocaMac，与 DMG 安装方式相同。

### 方式三：CLI 命令（面向开发者）

```bash
git clone https://github.com/fwz233-RE/vocamac-zh-CN.git
cd vocamac
make install-cli
```

这会将两个命令安装到 `~/.local/bin`：
- `vocamac &`：在后台启动 VocaMac
- `vocamac-build`：拉取更新后从源码重新构建

> **权限说明：** CLI 模式下，macOS 会将权限授予你的**终端应用**（Terminal、iTerm2 等），而非 VocaMac 本身。请将麦克风、辅助功能、输入监控权限授予你的终端应用。

### 首次启动

1. **VocaMac 出现在菜单栏**（麦克风图标，无 Dock 图标）
2. **授予权限**：麦克风、辅助功能、输入监控（见上方[权限](#权限)）
3. **首次模型下载**：WhisperKit 会自动为你的设备下载推荐模型（约 40–500 MB，取决于硬件）
4. **开始听写**：按住 **右 Option** 键说话，松开后文字会出现在光标处！

---

## 🌙 Nightly 构建

Nightly 构建是从最新 `main` 分支自动生成的每日构建，在有新提交时于 UTC 午夜发布。你可以在稳定版发布前提前体验最新功能、修复与改进。

**为什么使用 Nightly 构建？**

- **抢先体验** — 在下一个稳定版发布前数天或数周即可测试新功能
- **帮助改进 VocaMac** — 你对 Nightly 的反馈能在问题影响所有用户前被发现
- **完整签名与公证** — Nightly 与稳定版一样经过 Developer ID 签名和 Apple 公证，无 Gatekeeper 警告，无需右键绕过

**如何安装：**

1. 从 [Nightly Release](https://github.com/fwz233-RE/vocamac-zh-CN/releases/tag/nightly) 下载最新的 `VocaMac-nightly-*.dmg`
2. 打开 DMG，将 VocaMac 拖入「应用程序」
3. 按提示授予权限（与稳定版相同）

**如何识别你的构建版本：**

Nightly 构建会在版本字符串中嵌入日期和 commit SHA。打开 **设置 → 关于**，可看到类似内容：

```
Version 0.5.0-nightly.20260414+abc1234 (Nightly)
```

这有助于我们在你报告问题时精确定位所运行的代码。

**发布节奏与稳定性：**

| | 稳定版 | Nightly 构建 |
|---|---|---|
| **频率** | 就绪时发布（手动打 tag） | 每日 UTC 午夜 |
| **来源** | 已打 tag 的 commit | 最新 `main` 分支 |
| **签名与公证** | ✅ 是 | ✅ 是 |
| **稳定性** | 可用于日常生产 | 可能包含未完成功能或 bug |
| **适合** | 日常使用 | 测试与早期反馈 |

> ⚠️ **Nightly 构建可能不稳定。** 如遇问题，请[提交 bug 报告](https://github.com/fwz233-RE/vocamac-zh-CN/issues/new) — 你的反馈有助于我们发布更好的稳定版！

---

## 🎮 使用方法

### 按住说话（默认）

| 操作 | 效果 |
|--------|-------------|
| **按住右 Option** | 开始录音（菜单栏图标从菜单栏消失） |
| **说话** | 本地采集音频 |
| **松开右 Option** | 停止录音 → 转写 → 在光标处注入文字 |

### 双击切换

| 操作 | 效果 |
|--------|-------------|
| **双击右 Option** | 开始录音 |
| **说话** | 采集音频 |
| **再次双击右 Option** | 停止录音 → 转写 → 注入文字 |

可在 **设置 → 通用 → 激活方式** 中切换模式。

---

## 🧠 Whisper 模型

VocaMac 通过 WhisperKit 的 CoreML 格式使用 OpenAI Whisper 模型。应用会自动检测硬件并推荐最佳模型：

| 模型 | 参数量 | 下载大小 | 运行内存 | 速度 | 质量 | 适用场景 |
|-------|-----------|----------|----------|------|-------|----------|
| **Tiny** | 39M | ~75 MB | ~150 MB | ⚡⚡⚡⚡⚡ | 良好 | 快速笔记、较旧 Mac |
| **Base** | 74M | ~140 MB | ~250 MB | ⚡⚡⚡⚡ | 较好 | 8GB 内存 Mac 日常使用 |
| **Small** | 244M | ~460 MB | ~600 MB | ⚡⚡⚡ | 很好 | 16GB+ Apple Silicon |
| **Medium** | 769M | ~1.5 GB | ~1.8 GB | ⚡⚡ | 优秀 | 24GB+ 高精度需求 |
| **Large v3** | 1550M | ~3 GB | ~3.2 GB | ⚡ | 最佳 | 最高精度 |

> 上表为 WhisperKit CoreML（Apple Silicon Neural Engine）的实际占用，**不是** OpenAI 上游基于 PyTorch GPU 给出的 VRAM 估算。CoreML 量化后的模型在 ANE 上跑得更轻量。

模型在首次使用时从 [HuggingFace](https://huggingface.co/argmaxinc/whisperkit-coreml) 自动下载并本地缓存。可在 **设置 → 模型** 中下载更多模型。

---

## ⚙️ 配置

从菜单栏弹出面板打开设置，或使用 **⌘,**

### 通用
- **激活方式** - 按住说话或双击切换
- **快捷键** - 可选右 Option、右 Command、Fn、功能键等
- **语言** - 自动检测或指定（英语、西班牙语、法语、德语、中文、日语等）
- **登录时启动**

### 音频
- **最长录音时长** - 30 秒、60 秒、120 秒或 300 秒
- **静音检测** - 可配置静音时长后自动停止录音
- **音效** - 开关录音开始/停止的音频反馈
- **输入设备** - 选择使用的麦克风

### 模型
- 查看系统信息与 WhisperKit 的硬件推荐
- 下载、加载与切换模型
- 查看当前设备支持的模型

---

## 🏗️ 架构

VocaMac 采用清晰、模块化的架构，基于原生 Swift 与 SwiftUI 构建：

```
VocaMacApp (SwiftUI MenuBarExtra)
├── AppState          - 中央可观察状态
├── HotKeyManager     - CGEventTap 全局快捷键监听
├── AudioEngine       - AVAudioEngine 麦克风采集（16kHz，单声道，Float32）
├── WhisperService    - WhisperKit 异步转写封装
│   └── ModelManager  - 模型下载、存储与设备推荐
│       └── SystemInfo - 硬件检测与模型推荐
├── SoundManager      - 音频反馈（开始/停止录音提示音）
├── TextInjector      - 剪贴板 + Cmd+V 文字注入
├── MenuBarView       - 状态弹出面板 UI
└── SettingsView      - 配置页（通用、模型、音频、调试、关于）
```

详细文档请参阅：
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) - 技术架构
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) - 数据模型与实体关系

---

## 🔧 开发

### 前置条件

- **Xcode 15+** 或 Swift 5.9+ 工具链
- **macOS 13+**

### 项目结构

```
VocaMac/
├── Package.swift                   # SPM 配置（WhisperKit 依赖）
├── Sources/
│   └── VocaMac/
│       ├── App/
│       │   └── VocaMacApp.swift    # 入口，MenuBarExtra
│       ├── Views/
│       │   ├── MenuBarView.swift   # 菜单栏弹出面板
│       │   └── SettingsView.swift  # 设置窗口（5 个标签页）
│       ├── Services/
│       │   ├── AudioEngine.swift   # AVAudioEngine 麦克风采集
│       │   ├── HotKeyManager.swift # CGEventTap 全局快捷键
│       │   ├── WhisperService.swift# WhisperKit 转写封装
│       │   ├── ModelManager.swift  # 模型下载与管理
│       │   ├── SoundManager.swift  # 录音音频反馈
│       │   ├── TextInjector.swift  # 基于剪贴板的文字注入
│       │   └── SystemInfo.swift    # 硬件检测
│       ├── Models/
│       │   ├── AppState.swift      # 中央可观察状态
│       │   ├── TranscriptionResult.swift  # VocaTranscription 类型
│       │   └── WhisperModel.swift  # ModelSize 枚举、WhisperModelInfo
│       └── Resources/
├── Tests/
│   └── VocaMacTests/
├── Makefile                        # make build, install, test, clean
├── scripts/
│   ├── build.sh                    # 构建 .app 包（开发）
│   ├── install.sh                  # 安装到 /Applications 或 CLI
│   └── uninstall.sh                # 完全卸载与清理
├── web/                            # 营销网站（vocamac.com）
├── docs/
│   ├── ARCHITECTURE.md             # 技术架构
│   └── DATA_MODEL.md               # 数据模型与实体关系
├── LICENSE                         # AGPL-3.0 许可证
└── .gitignore
```

### 构建命令

```bash
make install        # 构建并安装到 /Applications（推荐）
make install-cli    # 安装 CLI 命令到 ~/.local/bin
make build          # 在仓库根目录构建 .app 包（开发迭代）
make test           # 运行测试
make run            # 启动本地构建的 .app
make clean          # 清除构建产物
make help           # 显示所有命令
```

### 卸载

要完全移除 VocaMac 及其所有数据（已下载模型、偏好设置、缓存）：

```bash
./scripts/uninstall.sh
```

使用 `--keep-build` 保留构建产物：

```bash
./scripts/uninstall.sh --keep-build
```

### 故障排除

**重置引导流程：** 若要重新触发首次启动引导向导（例如升级后或测试时），重置引导标志：

```bash
defaults delete com.vocamac.app vocamac.hasCompletedOnboarding
```

然后重新启动 VocaMac。这仅清除引导状态；其他偏好设置（快捷键、语言、模型）会保留。

**重置所有偏好设置：** 若要完全从头开始：

```bash
defaults delete com.vocamac.app
```

**重置权限（故障排除）：** 若权限显示异常或在更新后未被识别，可在 **设置 → 调试 → 重置所有权限** 中重置，或通过终端手动操作：

```bash
tccutil reset All com.vocamac.app
```

这会清除 VocaMac 的所有权限条目（麦克风、辅助功能、输入监控）。下次启动时，macOS 会提示你重新授权。使用 Developer ID 签名时，权限通常会在更新后保留 — 此操作仅用于故障排除。

**在共享/企业/VPN 网络上出现「Update check failed (HTTP 403)」：** VocaMac 通过调用 GitHub 公开 REST API 检查新版本，该 API 对**每个源 IP 每小时限 60 次未认证请求**。当多人共享同一出口 IP（常见于办公室 VPN、NAT 网络或繁忙的 CI 运行器）时，该配额会被集体耗尽，GitHub 会对来自该 IP 的所有客户端（包括 VocaMac）返回 `HTTP 403`。

这**不是 VocaMac 的 bug**，你的安装也没有问题。恢复方法：

1. 断开 VPN（或切换到其他网络，例如手机热点）。
2. 打开 VocaMac → **设置 → 关于 →「检查更新…」**，等待完成。
3. 重新连接 VPN。

一次成功检查后，VocaMac 会缓存响应的 `ETag`，并在后续每次请求中将其作为 `If-None-Match` 发送。GitHub 随后会回复 `304 Not Modified`，**不计入速率限制**，因此即使从已被限流的 IP 也能成功检查 — 直到有新版本发布且 ETag 变化（此时每台机器需要一次新的 `200` 响应，之后才会恢复 `304`）。

---

## 🌐 跨平台

VocaMac 是 Voca 家族中的 macOS 成员：

| 平台 | 项目 | 状态 |
|----------|---------|--------|
|  Linux | [VocaLinux](https://github.com/jatinkrmalik/vocalinux) | ✅ 可用 |
|  macOS | [VocaMac](https://github.com/fwz233-RE/vocamac-zh-CN) | 🚀 Beta |
| 🪟 Windows | [VocaWin](https://vocawin.com) | 📋 计划中 |

各平台使用原生技术以实现最佳集成，同时共享相同的 UX 模式与 Whisper 模型家族。

---

## 🤝 相关项目

- [WhisperKit](https://github.com/argmaxinc/WhisperKit) - Swift 原生设备端语音识别
- [VocaLinux](https://github.com/jatinkrmalik/vocalinux) - Linux 语音转文字
- [OpenAI Whisper](https://github.com/openai/whisper) - 原始 Whisper 模型

---

## ⚠️ 已知限制

- **较大模型需要一次性下载**：VocaMac 内置 Whisper Tiny 模型 — 无需联网即可立即听写。切换到更大模型（Small、Medium、Large）需要一次性下载；之后所有启动均可完全离线。
- **仅支持 macOS**：需要 macOS 13（Ventura）或更高版本。
- **重建时权限重置（仅源码构建）**：在没有 Developer ID 证书的情况下从源码构建时，由于 ad-hoc 签名，macOS 会在每次重建后重置辅助功能与输入监控权限。正式版采用 Developer ID 签名，更新后权限会保留。

### 权限与代码签名

VocaMac 正式版已通过 Apple **Developer ID 签名并公证**。辅助功能与输入监控权限在更新后会保留 — 无需手动重新授权。

**面向从源码构建的开发者：** 若没有 Developer ID 证书，`build.sh` 会回退到 ad-hoc 签名。ad-hoc 签名下，由于 CDHash 每次变化，macOS 会在每次重建后重置辅助功能与输入监控权限。这是 macOS 的标准安全行为 — 所有需要辅助功能的开源应用（Rectangle、Maccy、AltTab 等）在 ad-hoc 签名时都有相同限制。

**ad-hoc 构建的变通方案：**

| 方式 | 做法 | 权限是否持久 |
|---|---|---|
| **从终端运行** | 一次性向 Terminal.app 授予权限，然后运行 `make run` | ✅ 始终有效 |
| **手动重新授权** | 每次重建后在系统设置 → 隐私与安全性中重新授权 | 每次重建 |

> **💡 开发者提示：** 在系统设置中将你的终端应用（Terminal.app 或 iTerm2）加入辅助功能与输入监控。然后从终端直接运行 VocaMac，权限会被继承且不会重置。

---

## 📄 许可证

AGPL-3.0 许可证 — 详见 [LICENSE](LICENSE)。

---

<div align="center">
  
为 macOS 社区用心打造 ❤️

</div>
