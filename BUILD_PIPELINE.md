# Xiaxia App V0.1 · Android Build Pipeline

本文件说明 `.github/workflows/android-build.yml` 提供的可重复 Android CI 构建流程。

## 触发方式

Workflow 名称为 `Android Build`，支持两种触发方式：

1. 向 GitHub 仓库的 `main` 分支 push 后自动运行。
2. 在仓库的 **Actions → Android Build → Run workflow** 页面手动运行。

手动运行依赖 `workflow_dispatch`。如果 GitHub Actions 页面暂时没有出现 **Run workflow**，先确认 workflow 文件已经存在于默认分支。

## Runner 执行内容

每次运行使用 `ubuntu-latest`，配置 Temurin Java 17 和 Flutter stable，然后按顺序执行：

```bash
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

任一步失败都会使 job 失败。只有 debug APK 实际生成后，上传步骤才会成功。

构建不读取、注入或打包 `CORE_API_TOKEN`。Core Base URL 与 Bearer Token 仍由 App 在运行时配置，其中 Token 继续使用现有 Android 安全存储。

## APK artifact

| 项目 | 值 |
| --- | --- |
| GitHub Actions artifact 名称 | `xiaxia-app-debug-apk` |
| Runner 中的 APK 路径 | `build/app/outputs/flutter-apk/app-debug.apk` |
| Artifact 内的文件名 | `app-debug.apk` |
| 保留时间 | 14 天 |

### 下载方法

1. 打开 GitHub 仓库的 **Actions** 页面。
2. 进入一次状态为绿色的 `Android Build` workflow run。
3. 在运行摘要页底部找到 **Artifacts**。
4. 点击 `xiaxia-app-debug-apk` 下载压缩包。
5. 解压后取得 `app-debug.apk`。

GitHub 通常要求登录且对该仓库具有相应访问权限才能下载 artifact。

## 本轮本地验证记录

| 检查 | 状态 | 结果 |
| --- | --- | --- |
| Workflow YAML 解析与必需字段 | PASS | 已确认两种触发器、Ubuntu runner、Java 17、Flutter stable、五条命令及 artifact 上传配置。 |
| Flutter 项目位置 | PASS | Workflow 位于项目根目录下，根目录存在 `pubspec.yaml` 与 `android/app/build.gradle.kts`。 |
| Artifact 路径 | PASS | 上传路径与根目录执行 `flutter build apk --debug` 的目标 `build/app/outputs/flutter-apk/app-debug.apk` 一致。 |
| Secret 边界 | PASS | Workflow 不含 `CORE_API_TOKEN`、Core Base URL 或 GitHub secret 引用。 |
| 既有项目文件比较 | PASS | 与 Production Integration 基线逐文件比较，原有 73 个文件内容及权限未改变；仅新增 workflow 与本文档。 |
| 本地 `flutter analyze` / `flutter test` / APK build | NOT RUN | 当前 Work 环境没有 Flutter SDK；实际 PASS 等待 GitHub Actions runner 结果。 |

## CI 与真机验收边界

CI 成功可以证明依赖解析、静态分析、测试和 Android debug APK 构建已经在干净 runner 中真实完成，但以下项目仍需在 Android 真机或授权测试设备上验证：

- APK 安装、首次启动与系统版本兼容性；
- Home Light、quiet/absent Presence、Chat、Core unavailable 和 Dark Home 的实际显示；
- 软键盘、安全区、返回键及不同屏幕尺寸下的交互；
- Android Keystore 中 Core Token 的保存、读取与删除；
- 设备网络、DNS、TLS 与目标 Xiaxia Core 的连通性；
- 使用授权 URL/Token 完成真实 `/health`、`/v1/status` 和 `/v1/chat` 往返；
- 首条消息取得 Core `conversation_id`，后续消息复用同一 ID；
- 回复非空，并存在 `request_id`，且截图和日志不泄露 Token。

在 GitHub Actions 首次出现绿色结果之前，不应将 `flutter analyze`、`flutter test` 或 Android build 标记为 PASS。
