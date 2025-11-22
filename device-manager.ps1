# Device Management Class
class DeviceManager {

    # Get all devices
    static [array] GetDevices() {
        return Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.Name } | Sort-Object Name
    }

    # Search devices by name
    static [array] SearchDevices([string]$Name) {
        if ([string]::IsNullOrWhiteSpace($Name)) {
            return [DeviceManager]::GetDevices()
        }
        return Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.Name -like "*$Name*" } | Sort-Object Name
    }

    # Disable device
    static [bool] DisableDevice([string]$InstanceId) {
        try {
            $device = Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.DeviceID -eq $InstanceId }
            if ($device) {
                $result = $device | Invoke-CimMethod -MethodName Disable
                return ($result.ReturnValue -eq 0)
            }
            return $false
        }
        catch {
            return $false
        }
    }

    # Enable device
    static [bool] EnableDevice([string]$InstanceId) {
        try {
            $device = Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.DeviceID -eq $InstanceId }
            if ($device) {
                $result = $device | Invoke-CimMethod -MethodName Enable
                return ($result.ReturnValue -eq 0)
            }
            return $false
        }
        catch {
            return $false
        }
    }

    # Restart device (disable then enable)
    static [bool] RestartDevice([string]$InstanceId) {
        try {
            $success1 = [DeviceManager]::DisableDevice($InstanceId)
            if ($success1) {
                Start-Sleep -Milliseconds 500
                $success2 = [DeviceManager]::EnableDevice($InstanceId)
                return $success2
            }
            return $false
        }
        catch {
            return $false
        }
    }
}

# Interactive Device Selector Class
class DeviceSelector {
    [array]$Devices
    [int]$SelectedIndex
    [int]$PageSize
    [int]$CurrentPage
    [string]$SearchFilter
    [string]$StatusMessage

    DeviceSelector() {
        $this.PageSize = 15
        $this.CurrentPage = 0
        $this.SelectedIndex = 0
        $this.SearchFilter = ""
        $this.StatusMessage = "Use arrow keys to select device, R-Restart, X-Disable, V-Enable, Q-Quit"
        $this.RefreshDevices()
    }

    [void] RefreshDevices() {
        $this.Devices = [DeviceManager]::SearchDevices($this.SearchFilter)
        $this.SelectedIndex = 0
        $this.CurrentPage = 0
    }

    [int] GetTotalPages() {
        return [math]::Ceiling($this.Devices.Count / $this.PageSize)
    }

    [array] GetCurrentPageDevices() {
        $startIndex = $this.CurrentPage * $this.PageSize
        $endIndex = [math]::Min(($startIndex + $this.PageSize - 1), ($this.Devices.Count - 1))

        if ($startIndex -ge $this.Devices.Count) {
            return @()
        }

        return $this.Devices[$startIndex..$endIndex]
    }

    [void] MoveUp() {
        if ($this.SelectedIndex -gt 0) {
            $this.SelectedIndex--

            # Move to previous page if needed
            if ($this.SelectedIndex -lt ($this.CurrentPage * $this.PageSize)) {
                $this.CurrentPage--
            }
        }
    }

    [void] MoveDown() {
        if ($this.SelectedIndex -lt ($this.Devices.Count - 1)) {
            $this.SelectedIndex++

            # Move to next page if needed
            if ($this.SelectedIndex -ge (($this.CurrentPage + 1) * $this.PageSize)) {
                $this.CurrentPage++
            }
        }
    }

    [void] PageUp() {
        $this.CurrentPage = [math]::Max(0, $this.CurrentPage - 1)
        $this.SelectedIndex = $this.CurrentPage * $this.PageSize
    }

    [void] PageDown() {
        $this.CurrentPage = [math]::Min(($this.GetTotalPages() - 1), $this.CurrentPage + 1)
        $this.SelectedIndex = $this.CurrentPage * $this.PageSize
    }

    [void] GoToFirst() {
        $this.CurrentPage = 0
        $this.SelectedIndex = 0
    }

    [void] GoToLast() {
        $this.CurrentPage = $this.GetTotalPages() - 1
        $this.SelectedIndex = $this.Devices.Count - 1
    }

    [object] GetSelectedDevice() {
        if ($this.Devices.Count -eq 0) {
            return $null
        }
        return $this.Devices[$this.SelectedIndex]
    }

    [void] SetSearchFilter([string]$filter) {
        $this.SearchFilter = $filter
        $this.RefreshDevices()
    }

    [void] ShowInterface() {
        while ($true) {
            $this.DrawInterface()
            $key = $this.GetKeyPress()

            switch ($key) {
                'UpArrow' { $this.MoveUp() }
                'DownArrow' { $this.MoveDown() }
                'PageUp' { $this.PageUp() }
                'PageDown' { $this.PageDown() }
                'Home' { $this.GoToFirst() }
                'End' { $this.GoToLast() }
                'R' { $this.RestartSelectedDevice() }
                'X' { $this.DisableSelectedDevice() }
                'V' { $this.EnableSelectedDevice() }
                'F' { $this.ShowSearchDialog() }
                'Q' { return }
            }
        }
    }

    [void] DrawInterface() {
        Clear-Host

        # Title
        Write-Host "=== Device Manager ===" -ForegroundColor Cyan
        Write-Host "Search Filter: '$($this.SearchFilter)'" -ForegroundColor Yellow
        Write-Host "Device Count: $($this.Devices.Count)" -ForegroundColor White
        Write-Host ""

        # Device List
        $pageDevices = $this.GetCurrentPageDevices()
        $startIndex = $this.CurrentPage * $this.PageSize

        # Device List Header (English as requested)
        Write-Host "No.  Status       Device Name                                 Instance ID" -ForegroundColor Cyan
        Write-Host "-----------------------------------------------------------------" -ForegroundColor Cyan

        for ($i = 0; $i -lt $pageDevices.Count; $i++) {
            $deviceIndex = $startIndex + $i
            $device = $pageDevices[$i]
            $isSelected = ($deviceIndex -eq $this.SelectedIndex)

            # Status Color
            $statusColor = if ([string]::IsNullOrEmpty($device.Status) -or $device.Status -eq "OK") { "Green" } else { "Red" }

            # Display Device Info (compact format with header as requested)
            $statusText = if ([string]::IsNullOrEmpty($device.Status)) { "[Unknown]" } else { "[$($device.Status)]" }

            # Limit device name to 50 characters to keep format clean
            $shortName = if ($device.Name.Length -gt 50) { $device.Name.Substring(0, 47) + "..." } else { $device.Name }

            # Handle selected and non-selected rows differently for background color
            if ($isSelected) {
                # Selected row: Dark gray background, yellow text (except status text keeps its original color)
                Write-Host "> " -NoNewline -ForegroundColor Yellow -BackgroundColor DarkGray
                Write-Host "$($deviceIndex + 1) " -NoNewline -ForegroundColor Yellow -BackgroundColor DarkGray
                Write-Host "$statusText " -NoNewline -ForegroundColor $statusColor -BackgroundColor DarkGray
                Write-Host ("{0,-50} " -f $shortName) -NoNewline -ForegroundColor Yellow -BackgroundColor DarkGray
                Write-Host "$($device.DeviceID)" -ForegroundColor Yellow -BackgroundColor DarkGray
            } else {
                # Non-selected row: Default background
                Write-Host "  " -NoNewline -ForegroundColor White
                Write-Host "$($deviceIndex + 1) " -NoNewline -ForegroundColor White
                Write-Host "$statusText " -NoNewline -ForegroundColor $statusColor
                Write-Host ("{0,-50} " -f $shortName) -NoNewline -ForegroundColor White
                Write-Host "$($device.DeviceID)" -ForegroundColor Gray
            }
        }

        # Pagination Info
        if ($this.Devices.Count -gt $this.PageSize) {
            Write-Host "Page $($this.CurrentPage + 1)/$($this.GetTotalPages())" -ForegroundColor Magenta
        }

        Write-Host ""
        Write-Host "=== Operation Instructions ===" -ForegroundColor Cyan
        Write-Host "Arrow Keys: Select Device    Home/End: First/Last Device" -ForegroundColor White
        Write-Host "PageUp/PageDown: Page Up/Down        F: Search Filter" -ForegroundColor White
        Write-Host "R: Restart Device       X: Disable Device     V: Enable Device" -ForegroundColor White
        Write-Host "Q: Exit Program" -ForegroundColor White
        Write-Host ""

        if ($this.StatusMessage) {
            Write-Host "Status: $($this.StatusMessage)" -ForegroundColor Green
        }
    }

    [string] GetKeyPress() {
        do {
            $key = [System.Console]::ReadKey($true)

            # Convert ConsoleKey to string
            switch ($key.Key) {
                UpArrow { return 'UpArrow' }
                DownArrow { return 'DownArrow' }
                PageUp { return 'PageUp' }
                PageDown { return 'PageDown' }
                Home { return 'Home' }
                End { return 'End' }
                Q { return 'Q' }
                R { return 'R' }
                X { return 'X' }
                V { return 'V' }
                F { return 'F' }
                default { continue }
            }
        } while ($true)
        return ''  # This line will never be reached but satisfies the compiler
    }

    [void] ShowSearchDialog() {
        Clear-Host
        Write-Host "=== Search Devices ===" -ForegroundColor Cyan
        Write-Host "Current Filter: '$($this.SearchFilter)'" -ForegroundColor Yellow
        Write-Host "Enter search keyword (press enter to keep current, space to clear):" -ForegroundColor White
        $newFilter = Read-Host

        $this.SetSearchFilter($newFilter)
        $this.StatusMessage = "Search filter updated: '$newFilter'"
    }

    [void] RestartSelectedDevice() {
        $device = $this.GetSelectedDevice()
        if ($device) {
            Write-Host "Restarting device: $($device.Name)" -ForegroundColor Yellow
            $success = [DeviceManager]::RestartDevice($device.DeviceID)
            if ($success) {
                $this.StatusMessage = "Device restarted successfully: $($device.Name)"
                Start-Sleep -Seconds 1
                $this.RefreshDevices()
            } else {
                $this.StatusMessage = "Device restart failed: $($device.Name)"
            }
        } else {
            $this.StatusMessage = "No device selected"
        }
    }

    [void] DisableSelectedDevice() {
        $device = $this.GetSelectedDevice()
        if ($device) {
            Write-Host "Disabling device: $($device.Name)" -ForegroundColor Yellow
            $success = [DeviceManager]::DisableDevice($device.DeviceID)
            if ($success) {
                $this.StatusMessage = "Device disabled successfully: $($device.Name)"
                Start-Sleep -Seconds 1
                $this.RefreshDevices()
            } else {
                $this.StatusMessage = "Device disable failed: $($device.Name)"
            }
        } else {
            $this.StatusMessage = "No device selected"
        }
    }

    [void] EnableSelectedDevice() {
        $device = $this.GetSelectedDevice()
        if ($device) {
            Write-Host "Enabling device: $($device.Name)" -ForegroundColor Yellow
            $success = [DeviceManager]::EnableDevice($device.DeviceID)
            if ($success) {
                $this.StatusMessage = "Device enabled successfully: $($device.Name)"
                Start-Sleep -Seconds 1
                $this.RefreshDevices()
            } else {
                $this.StatusMessage = "Device enable failed: $($device.Name)"
            }
        } else {
            $this.StatusMessage = "No device selected"
        }
    }
}

# Main Function
function Start-DeviceManager {
    # Check for Administrator rights
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "Requires Administrator privileges to run this script!" -ForegroundColor Red
        Write-Host "Please run PowerShell as Administrator and execute this script again." -ForegroundColor Yellow
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        [System.Console]::ReadKey($true) | Out-Null
        return
    }

    try {
        Write-Host "Loading device list..." -ForegroundColor Yellow
        $selector = [DeviceSelector]::new()
        $selector.ShowInterface()

        Write-Host "Device Manager has exited." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        [System.Console]::ReadKey($true) | Out-Null
    }
}

# Run the Main Function
Write-Host "Device Manager Script" -ForegroundColor Cyan
Write-Host "Press any key to start..." -ForegroundColor Gray
[System.Console]::ReadKey($true) | Out-Null

Start-DeviceManager