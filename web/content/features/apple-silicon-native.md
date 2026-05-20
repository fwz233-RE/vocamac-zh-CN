---
title: "Apple Silicon 原生"
subtitle: "通过 WhisperKit 使用 CoreML + Metal + 神经网络引擎加速，在 M1/M2/M3/M4 上极速运行。"
description: "VocaMac 在 Apple Silicon 上原生运行，借助 CoreML 与神经网络引擎实现硬件加速语音识别，无需云端、无 CPU 瓶颈。"
keywords: "apple silicon 语音识别, coreml 语音转文字, 神经网络引擎听写, whisperkit macOS, M1 M2 M3 M4 语音输入, mac 硬件加速转写"
icon: "⚡"
---

## 为现代 Mac 硬件而生

VocaMac 从底层为 Apple Silicon 打造。借助 CoreML 与 WhisperKit，应用利用 M1、M2、M3、M4 芯片中的神经网络引擎进行语音识别，比仅靠 CPU 更快、更省电。

这不仅是优化，更是架构优势。云端听写要把语音传到网上再等回应，VocaMac 则在 Mac 本地毫秒级处理一切。

## 神经网络引擎加速

![Apple Silicon 上的 VocaMac 模型管理设置](/screenshots/settings-models.png)

Apple Silicon 的神经网络引擎专为机器学习设计。VocaMac 转写时将重计算卸载到这块专用硬件。

效果显而易见：转写接近实时，说完话文字往往已出现。听写不再像「用一个 App」，而像打字方式的延伸。

神经网络引擎与 CPU、GPU 独立工作，转写不会挤占你正在做的其他任务。编辑文档、查邮件或运行复杂应用时，VocaMac 可在后台转写且几乎不影响性能。

## CoreML 与 Metal

CoreML 是 Apple 的设备端机器学习框架。VocaMac 用它在本地运行 Whisper，零云依赖，语音永不离开 Mac。

Metal 为部分计算提供额外加速。CoreML 与 Metal 协同，在保持隐私与系统流畅的同时追求最高效率。

WhisperKit 专为 Apple Silicon 优化，自动选择最佳执行路径：CoreML 处理神经网络、Metal 处理图形相关计算、CPU 负责协调，三者配合。

## 卓越性能

在 M1 Mac 上，中等 Whisper 模型转写速度约为实时的 3–5 倍：30 秒音频约 6–10 秒完成，而仅靠 CPU 的 Intel Mac 可能要 90 秒以上。

模型越大、准确度越高，差距越明显。Base 几乎即时，Small 数秒，Medium 在 Apple Silicon 上通常一分钟内完成。云端服务或许也快，但需要网络、订阅，并带来隐私顾虑。

## 续航与发热

神经网络引擎为机器学习而生，极其省电。同样任务若由 CPU 承担会明显耗电，交给神经网络引擎则能耗大幅降低。

Mac 风扇很少需要狂转，应用安静运行，不增加工作区噪音与热量。

在 M 系列 Mac 上，可全天使用 VocaMac 而几乎感觉不到电池消耗：始终可用、始终响应、始终尊重硬件资源。

## 为何重要

Apple Silicon 不只是更快，更代表一种理念：用极高效率处理用户真正关心的任务。

对听写而言：更快意味着少等待；本地意味着语音私密；高效意味着 Mac 保持凉爽流畅。VocaMac 因此成为 Mac 上最自然的语音转文字体验。

无论你用的是 M1、M2、M3 还是 M4，都能充分发挥硬件能力。VocaMac 原生、快速、高效，专为你的 Mac 打造。
