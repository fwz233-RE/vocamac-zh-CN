---
title: "GitHub 发布更新"
subtitle: "VocaMac 检查 GitHub Releases，下载最新签名 DMG，并引导你拖入替换完成更新。"
description: "VocaMac 内置基于 GitHub Releases API 的更新检查：在应用内查看新版本、带进度下载签名 DMG，安全安装。"
keywords: "mac 应用更新检查, github releases 更新, 签名 dmg 更新, 菜单栏应用更新流程, vocamac 更新"
icon: "⬇️"
---

## 内置更新检查

VocaMac 可直接从 GitHub 检查新版本，将当前版本与最新稳定版对比，有新版本时在应用内显示更新横幅。

检查轻量且对 API 友好：

- 启动时自动检查（最多每 24 小时一次）
- **设置 → 关于** 中的手动 **检查更新…**
- 无需额外账号、登录或第三方更新服务

## 更新流程

发现更新后，VocaMac 在菜单栏弹出面板显示清晰、不打扰的横幅。可打开详情、阅读发布说明并开始下载。

![VocaMac 更新界面：发布说明与「下载并安装」按钮](/screenshots/update-ux.png)

随后应用会：

1. 从 GitHub Release 资源下载最新 `arm64` DMG
2. 显示实时下载进度
3. 使用 GitHub 发布 API 中的 SHA-256 校验文件完整性
4. 打开 DMG，便于将 VocaMac 拖入「应用程序」文件夹

安装过程熟悉、透明，同时让更新更快。

## 安全与信任

VocaMac 仅请求 `https://api.github.com/repos/fwz233-RE/vocamac-zh-CN/releases/latest`，并通过 HTTPS 从 GitHub 下载发布资源。

每个 DMG 在提供打开选项前都会对照发布摘要中的摘要进行校验。发布包仍为 Developer ID 签名并公证，与现有分发流程一致。

## 更新后的权限

VocaMac 现使用稳定的 Developer ID 身份签名，权限通常可在更新后保留。多数情况下更新后无需重新授权即可继续听写。

若权限显示异常，调试标签页仍提供一键重置权限的辅助功能。
