# 设备管理器 PowerShell 脚本

一个用于管理 Windows 设备的交互式 PowerShell 脚本，具有用户友好的控制台界面。

## 功能特性

- **交互式控制台界面**：使用键盘进行导航和操作
- **设备显示**：以紧凑表格形式显示设备状态、名称和实例 ID
- **键盘控制**：
  - 方向键：导航设备列表
  - PageUp/PageDown：分页浏览
  - Home/End：跳转到首/尾设备
  - R：重启选中设备
  - X：禁用选中设备
  - V：启用选中设备
  - F：搜索设备
  - Q：退出程序
- **搜索功能**：按名称过滤设备
- **分页显示**：每页显示 15 个设备
- **权限检查**：自动验证管理员权限
- **视觉反馈**：
  - 选中行具有深灰色背景和黄色文本
  - 状态指示器：[OK] 为绿色，错误状态为红色

## 系统要求

- Windows 10/11 操作系统
- PowerShell 5.0 或更高版本
- 管理员权限（设备操作需要）

## 使用方法

### 运行脚本

1. **以管理员身份**打开 PowerShell
2. 导航到脚本目录：
   ```powershell
   cd d:\repos\powershell
   ```
3. 执行脚本：
   ```powershell
   .\device-manager.ps1
   ```
4. 按任意键开始使用

### 键盘快捷键

| 按键                | 操作                          |
|--------------------|-------------------------------|
| 上箭头 / 下箭头     | 导航设备列表                  |
| PageUp / PageDown  | 分页浏览设备                  |
| Home / End         | 跳转到首/尾设备                |
| R                  | 重启选中设备                  |
| X                  | 禁用选中设备                  |
| V                  | 启用选中设备                  |
| F                  | 打开搜索对话框                |
| Q                  | 退出设备管理器                |

## 显示格式

```
=== Device Manager ===
Search Filter: ''
Device Count: 100

No.  Status       Device Name                                 Instance ID
-----------------------------------------------------------------
  1 [OK]          Realtek USB 2.0 Card Reader                USB\VID_0BD...
> 2 [Error]       Intel Wireless-AC 9560 160MHz             PCI\VEN_8086...
  3 [OK]          Intel(R) Ethernet Connection (7) I219-V   PCI\VEN_8086...
...

=== Operation Instructions ===
Arrow Keys: Select Device    Home/End: First/Last Device
PageUp/PageDown: Page Up/Down        F: Search Filter
R: Restart Device       X: Disable Device     V: Enable Device
Q: Exit Program

Status: Use arrow keys to select device, R-Restart, X-Disable, V-Enable, Q-Quit
```

## 故障排除

### "Requires Administrator privileges" 错误
- 确保以管理员身份运行 PowerShell
- 右键点击 PowerShell 图标并选择"以管理员身份运行"

### "Cannot read keys" 错误
- 此错误在非交互模式下运行时发生
- 直接在 PowerShell 控制台中运行脚本，不要通过其他应用程序运行

### 设备操作失败
- 某些设备无法通过软件重启/禁用
- 确保安装了最新的设备驱动程序
- 在 Windows 设备管理器中检查设备属性以获取更多信息

## 更新日志

### 版本 1.0
- 初始版本
- 基本设备管理功能
- 交互式控制台界面
- 搜索和分页功能

### 版本 1.1
- 改进了选中行的视觉样式
- 添加了英文表头
- 设备名称自动截断以保持格式整洁

