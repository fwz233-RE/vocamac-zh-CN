---
title: "智能模型推荐"
subtitle: "自动识别硬件（Apple Silicon、Intel、内存）并推荐最合适的 Whisper 模型。"
description: "VocaMac 自动检测 Mac 硬件并推荐最佳 Whisper 模型。可按需在 Tiny 到 Large v3 之间选择。"
keywords: "whisper 模型选择, macOS 硬件检测, apple silicon whisper, coreml 语音模型, mac 最佳 whisper 模型, 按内存推荐模型"
icon: "🧠"
---

## 智能硬件检测

每台 Mac 都不同。8GB 内存的 Apple Silicon MacBook Air 与 8GB Intel Mac mini 能力各异。VocaMac 检测处理器类型（Apple Silicon 或 Intel）、CPU 核心数、GPU 与已安装内存，并推荐在准确度与速度之间平衡最佳的模型档位。

首次启动会分析硬件并给出建议。你仍可自由选择任意模型，但推荐能让你无需猜测即可获得出色效果。

## 五档模型

![VocaMac 设置中的模型管理与系统信息](/screenshots/settings-models.png)

VocaMac 支持五种 Whisper 模型，从轻量到高精度，均针对 CoreML 优化并在 Mac 本地运行。

**Tiny（下载 39 MB，运行内存约 1 GB）**  
最快、内存占用最小。适合 4–8GB 内存或更看重速度的场景。转写可实时甚至更快，准确度略低于大模型，但日常笔记与短消息足够。

**Base（下载 142 MB，运行内存约 1.5 GB）**  
稳健折中。8GB 及以上内存的 Mac 均可流畅运行，比 Tiny 明显更准且仍很快，常作为多数用户的推荐。

**Small（下载 466 MB，运行内存约 2 GB）**  
面向 16GB 内存、追求更高准确度。在现代 Mac 上仍很快，专业写作、编程等场景值得选用。

**Medium（下载 1.5 GB，运行内存约 5 GB）**  
高准确度，适合要求高的场景，建议 16GB 及以上内存。Apple Silicon 上速度仍可接受，适合技术文档、医疗转写等字字要紧的用途。

**Large v3（下载 3.1 GB，运行内存约 10 GB）**  
最高准确度，32GB 及以上 Apple Silicon 表现最佳。速度可能约 2–3 秒/分钟音频，在极致准确度优先于速度时使用。

## 基于硬件的建议

VocaMac 会给出针对性建议，例如：

- **Apple Silicon MacBook Air（8GB）**：推荐 Base 或 Small
- **Apple Silicon MacBook Pro（16GB）**：推荐 Small 或 Medium
- **Intel Mac mini（8GB）**：推荐 Tiny 或 Base
- **Apple Silicon Mac Studio（32GB）**：推荐 Medium 或 Large v3

建议综合硬件能力与实际转写速度；最终选择取决于你对准确度与耗时的要求。

## 下载与切换模型

模型按需下载。首次使用某模型需联网，之后使用本地缓存，并带校验和验证完整性。

在设置中可即时切换，无需重启，下次录音即用新模型。可同时保留多个模型并按场景切换：技术会议用 Small，快速邮件用 Tiny。

界面显示各模型占用空间，可删除不用的模型释放磁盘。

## CoreML 优化

VocaMac 中的 Whisper 模型均转换为 Apple CoreML 格式，带来：

- Apple Silicon 上通过神经网络引擎原生执行
- Intel Mac 通过兼容指令高效运行
- 更低能耗，利于笔记本续航
- 无云依赖、无外部 API
- 完全隐私，处理均在本地

CoreML 充分利用 Mac 的机器学习硬件；Apple Silicon 相较通用框架速度提升显著。

## 由你最终决定

自动推荐帮你快速上手，但选用哪个模型由你掌控。有的机器偏速度，有的偏精度，需求变化时随时调整。听写工作流随硬件与偏好而变——这就是 VocaMac 的方式。
