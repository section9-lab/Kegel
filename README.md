# KegelTimer

**macOS 提肛运动计时器 · 定时提醒 · 隐私优先**

[English](README_EN.md) | [日本語](README_JP.md)

![KegelTimer 截图](assets/screenshot.png)

## 简介

KegelTimer 是一款极简的 macOS 菜单栏应用，帮助你养成定时做提肛运动的习惯。

- ⏰ **倒计时提醒**：设定间隔时间，自动弹出提醒
- 🌻 **葵花动画**：收缩时绽放，放松时收拢
- 📊 **进度追踪**：分段进度条显示训练进度
- 🔒 **隐私优先**：无账号、无数据收集、完全本地运行

---

## 快速开始

### 1. 下载安装

```bash
# 从 GitHub Releases 下载
https://github.com/marswaveai/KegelTimer/releases/latest
```

下载 `KegelTimer.app.zip` → 解压 → 拖入 `/Applications` 文件夹

### 2. 首次使用

1. 打开 KegelTimer（菜单栏会出现 🍑 图标）
2. 点击图标 → **设置...** → 调整提醒间隔（默认 60 分钟）
3. 等待倒计时结束，或手动点击 **开始训练**

### 3. 训练流程

```
倒计时结束 → 卡片弹出 + 提示音 → 
跟随葵花动画（收缩→放松）→ 
完成所有组数 → 点击 × 关闭 → 重新开始倒计时
```

---

## 功能说明

### 主界面

| 状态 | 显示内容 | 操作 |
|------|----------|------|
| 空闲 | 下次提醒：X 分钟 | 点击卡片开始训练 |
| 训练中 | 葵花动画 + 进度条 | 点击卡片暂停/继续 |
| 完成 | ✅ 训练完成！ | 自动关闭或点击 × |

### 葵花动画

- **绽放**（收缩）：保持 X 秒（可设置 1-10 秒）
- **收拢**（放松）：保持 X 秒（可设置 1-10 秒）

### 进度条

- 每小段代表一次重复
- 绿色 = 已完成，灰色 = 未完成
- 底部显示当前组数/总组数

---

## 设置选项

打开 **设置...**（快捷键 `⌘,`）调整以下参数：

| 选项 | 范围 | 默认值 | 说明 |
|------|------|--------|------|
| **提醒间隔** | 5-240 分钟 | 60 分钟 | 多久提醒一次 |
| **收缩时间** | 1-10 秒 | 5 秒 | 每次收缩保持多久 |
| **放松时间** | 1-10 秒 | 5 秒 | 每次放松休息多久 |
| **每组次数** | 1-30 次 | 10 次 | 一组做多少次 |
| **组数** | 1-10 组 | 3 组 | 一次训练做几组 |
| **组间休息** | 10-180 秒 | 60 秒 | 组与组之间休息多久 |

### 示例配置

**新手模式**（约 3 分钟）：
- 收缩 3 秒，放松 3 秒
- 每组 5 次，共 2 组
- 组间休息 30 秒

**进阶模式**（约 10 分钟）：
- 收缩 10 秒，放松 5 秒
- 每组 15 次，共 5 组
- 组间休息 60 秒

---

## 常见问题

### Q: 什么是提肛运动？

A: 提肛运动（Kegel exercises）是锻炼盆底肌肉的运动，有助于改善膀胱控制、核心稳定性等。建议咨询医生后开始任何锻炼计划。

### Q: 如何关闭提醒？

A: 点击卡片右上角的 × 按钮即可关闭并重置倒计时。也可以在菜单栏点击图标 → 停止训练。

### Q: 会收集我的数据吗？

A: **不会**。所有数据都存储在本机 UserDefaults 中，不会上传到任何服务器。

### Q: 支持 Apple Silicon 吗？

A: 支持。使用 Swift 原生开发，同时支持 Intel 和 Apple Silicon Mac。

### Q: 最低系统要求？

A: macOS 14.0 (Sonoma) 及以上版本。

---

## 技术栈

- **语言**: Swift 6.2
- **框架**: SwiftUI + AppKit
- **架构**: 单文件应用（~900 行）
- **更新**: GitHub Releases 自动更新

---

## 构建指南

```bash
git clone https://github.com/marswaveai/KegelTimer.git
cd KegelTimer

# 生成图标（可选，已有预生成图标）
./scripts/generate_icon.sh

# 构建应用
./scripts/build_app.sh

# 输出位置
dist/KegelTimer.app
```

---

## 更新日志

### v1.0.0
- ✨ 初始版本发布
- ⏰ 倒计时提醒功能
- 🌻 葵花动画特效
- 📊 分段进度条
- 🔄 自动更新机制

---

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=marswaveai/KegelTimer&type=Date)](https://star-history.com/#marswaveai/KegelTimer&Date)

---

## 许可证

GNU General Public License v3.0

---

## 相关链接

- [GitHub 仓库](https://github.com/marswaveai/KegelTimer)
- [问题反馈](https://github.com/marswaveai/KegelTimer/issues)
- [官方网站](https://kegeltimer.com)
