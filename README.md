# Device Manager PowerShell Script

An interactive PowerShell script for managing Windows devices with a user-friendly console interface.

## Features

- **Interactive Console Interface**: Navigation and operations using keyboard
- **Device Display**: Compact table showing device status, name, and instance ID
- **Keyboard Controls**:
  - Arrow keys: Navigate device list
  - PageUp/PageDown: Pagination
  - Home/End: Go to first/last device
  - R: Restart selected device
  - X: Disable selected device
  - V: Enable selected device
  - F: Search devices
  - Q: Quit program
- **Search Functionality**: Filter devices by name
- **Pagination**: Display devices in pages of 15
- **Permission Check**: Automatically verifies administrator privileges
- **Visual Feedback**:
  - Selected rows have dark gray background with yellow text
  - Status indicators: [OK] in green, error statuses in red

## Requirements

- Windows 10/11
- PowerShell 5.0 or later
- Administrator privileges (required for device operations)

## Usage

### Running the Script

1. Open PowerShell **as Administrator**
2. Navigate to the script directory:
   ```powershell
   cd C:\Path\To\YourScript
   ```
3. Execute the script:
   ```powershell
   .\device-manager.ps1
   ```
4. Press any key to start

### Keyboard Shortcuts

| Key                | Action                                  |
|--------------------|-----------------------------------------|
| Up Arrow / Down Arrow | Navigate device list                 |
| PageUp / PageDown  | Page through device pages               |
| Home / End         | Go to first/last device                 |
| R                  | Restart selected device                 |
| X                  | Disable selected device                 |
| V                  | Enable selected device                  |
| F                  | Open search dialog                      |
| Q                  | Quit the device manager                 |

## Display Format

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

## Troubleshooting

### "Requires Administrator privileges" error
- Ensure you are running PowerShell as Administrator
- Right-click PowerShell icon and select "Run as Administrator"

### "Cannot read keys" error
- This error occurs if running in non-interactive mode
- Run the script directly in a PowerShell console, not through other applications

### Device operations fail
- Some devices cannot be restarted/disabled via software
- Ensure you have the latest device drivers
- Check device properties in Windows Device Manager for more information

## Changelog

### Version 1.0
- Initial release
- Basic device management functionality
- Interactive console interface
- Search and pagination features

### Version 1.1
- Improved visual styling for selected rows
- English header added
- Device name truncation for clean formatting

