# Now Playing Toast - V0.3 DEMO
# Windows PowerShell 5.1, interface WPF; ne modifie pas Spotify/Spicetify/SpotX.
# Lancer en mode NON administrateur : powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File .\NowPlayingToast-Demo.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class NptHotkey {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool RegisterHotKey(IntPtr hwnd, int id, uint modifiers, uint vk);
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool UnregisterHotKey(IntPtr hwnd, int id);
}
'@

# Dimensions en unités WPF (adaptées à la mise à l'échelle Windows).
# Pochette 124 x 124, bloc d'informations de même hauteur; rayon 11.
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Width="442" Height="156" WindowStyle="None" ResizeMode="NoResize"
        AllowsTransparency="True" Background="Transparent" ShowInTaskbar="False"
        ShowActivated="False" Topmost="True" WindowStartupLocation="Manual">
  <Border Background="#171A1F" CornerRadius="16" BorderThickness="1"
          BorderBrush="#8C7758" Padding="12">
    <Grid>
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="130"/>
        <ColumnDefinition Width="12"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>
      <Border Grid.Column="0" Background="#24242B" CornerRadius="11" BorderThickness="1" BorderBrush="#3C3C43">
        <Grid>
          <Rectangle Margin="6" RadiusX="7" RadiusY="7" Fill="#27252B"/>
          <Ellipse Width="75" Height="75" Fill="#4A3B3A" HorizontalAlignment="Center" VerticalAlignment="Center"/>
          <TextBlock Text="♫" FontSize="56" Foreground="#D6B77C"
                     HorizontalAlignment="Center" VerticalAlignment="Center"/>
        </Grid>
      </Border>
      <Grid Grid.Column="2">
        <Grid.RowDefinitions>
          <RowDefinition Height="18"/>
          <RowDefinition Height="28"/>
          <RowDefinition Height="23"/>
          <RowDefinition Height="22"/>
          <RowDefinition Height="22"/>
          <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <TextBlock Grid.Row="0" Text="●  NOW PLAYING  ·  DEMO" Foreground="#D6B77C"
                   FontSize="10" FontWeight="SemiBold"/>
        <TextBlock Grid.Row="1" Text="Get Lucky" Foreground="#FFFFFF"
                   FontSize="19" FontWeight="SemiBold" TextTrimming="CharacterEllipsis"/>
        <TextBlock Grid.Row="2" Text="Daft Punk / Pharrell Williams" Foreground="#E2E5E9"
                   FontSize="12" TextTrimming="CharacterEllipsis"/>
        <TextBlock Grid.Row="3" Text="Random Access Memories" Foreground="#B8BFC6"
                   FontSize="12" TextTrimming="CharacterEllipsis"/>
        <TextBlock Grid.Row="4" Text="2013     |     6:09" Foreground="#DDDFE2" FontSize="12"/>
        <Grid Grid.Row="5" Height="4" VerticalAlignment="Bottom">
          <Border Background="#393D44" CornerRadius="2"/>
          <Border Background="#D6B77C" CornerRadius="2"
                  Width="88" HorizontalAlignment="Left"/>
        </Grid>
      </Grid>
    </Grid>
  </Border>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)
$workArea = [System.Windows.SystemParameters]::WorkArea
$window.Left = $workArea.Right - $window.Width - 20
$window.Top  = $workArea.Bottom - $window.Height - 20

$script:timer = New-Object System.Windows.Threading.DispatcherTimer
$script:timer.Interval = [TimeSpan]::FromSeconds(5)
$script:timer.Add_Tick({
    $script:timer.Stop()
    # Garder la fenetre et son HWND actifs pour conserver le raccourci global.
    $window.Opacity = 0
    $window.IsHitTestVisible = $false
})
$script:showToast = {
    $script:timer.Stop()
    $window.Opacity = 1
    $window.IsHitTestVisible = $true
    $window.Topmost = $true
    $script:timer.Start()
}

# Raccourci : Ctrl + Alt + point (VK_OEM_PERIOD 0xBE) - non répétitif.
$script:hotkeyId = 47511
$script:hwnd = [IntPtr]::Zero
$script:hotkeyOK = $false
$script:source = $null
$script:hook = [System.Windows.Interop.HwndSourceHook]{
    param($hwnd, $msg, $wparam, $lparam, [ref]$handled)
    if ($msg -eq 0x0312 -and $wparam.ToInt32() -eq $script:hotkeyId) {
        & $script:showToast
        $handled.Value = $true
    }
    return [IntPtr]::Zero
}

$window.Add_SourceInitialized({
    $helper = New-Object System.Windows.Interop.WindowInteropHelper($window)
    $script:hwnd = $helper.Handle
    $script:source = [System.Windows.Interop.HwndSource]::FromHwnd($script:hwnd)
    $script:source.AddHook($script:hook)
    $script:hotkeyOK = [NptHotkey]::RegisterHotKey($script:hwnd, $script:hotkeyId, 0x0006, 0x57)
    Write-Host "Raccourci enregistre : $script:hotkeyOK" -ForegroundColor Cyan
    if (-not $script:hotkeyOK) {
        Write-Warning 'Raccourci Ctrl+Maj+W indisponible : raccourci reserve par une autre application (Win32=$([Runtime.InteropServices.Marshal]::GetLastWin32Error())).'
    }
})
$window.Add_Loaded({
    $script:timer.Start()
})
$window.Add_Closed({
    $script:timer.Stop()
    if ($script:hotkeyOK) {
        [void][NptHotkey]::UnregisterHotKey($script:hwnd, $script:hotkeyId)
    }
    if ($script:source) {
        $script:source.RemoveHook($script:hook)
    }
})
Write-Host 'Now Playing Toast DEMO V0.3 : affichage 5 secondes; Ctrl+Maj+W pour reafficher.' -ForegroundColor Green
Write-Host 'Garder cette session PowerShell ouverte pendant le test. Fermer la session pour arreter.'
$app = New-Object System.Windows.Application
$app.ShutdownMode = [System.Windows.ShutdownMode]::OnMainWindowClose
[void]$app.Run($window)
