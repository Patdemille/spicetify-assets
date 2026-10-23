# Now Playing Toast v0.7 - Liked Songs button (preview)
# Windows PowerShell 5.1 / WPF, non-admin, no modification of Spotify or SpotX.
# All local communication is bound to 127.0.0.1 only. No external service.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# A small HTTP receiver that does not require Windows HTTP.sys URL reservations.
# Only a local Spotify extension can supply track text and cover URL.
Add-Type -TypeDefinition @'
using System;
using System.Collections.Concurrent;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

public class NptLocalBridge : IDisposable {
    private TcpListener listener;
    private Thread worker;
    private volatile bool running;
    public readonly ConcurrentQueue<string> Messages = new ConcurrentQueue<string>();
    public readonly ConcurrentQueue<string> Controls = new ConcurrentQueue<string>();
    public const int Port = 43827;

    public void Start() {
        listener = new TcpListener(IPAddress.Loopback, Port);
        listener.Start(8);
        running = true;
        worker = new Thread(() => {
            while (running) {
                try {
                    TcpClient client = listener.AcceptTcpClient();
                    ThreadPool.QueueUserWorkItem(obj => Process((TcpClient)obj), client);
                } catch (SocketException) {
                    if (!running) return;
                } catch (ObjectDisposedException) { return; }
            }
        });
        worker.IsBackground = true;
        worker.Name = "NptLoopback";
        worker.Start();
    }

    private static bool AllowedOrigin(string origin) {
        if (String.IsNullOrEmpty(origin) || origin == "null") return true;
        Uri uri;
        if (!Uri.TryCreate(origin, UriKind.Absolute, out uri)) return false;
        string host = uri.Host.ToLowerInvariant();
        return host == "spotify.com" || host.EndsWith(".spotify.com") ||
               host == "spotifycdn.com" || host.EndsWith(".spotifycdn.com");
    }

    private void Process(TcpClient client) {
        using (client) {
            try {
                client.ReceiveTimeout = 2500; client.SendTimeout = 2500;
                NetworkStream stream = client.GetStream();
                using (MemoryStream header = new MemoryStream()) {
                    int b = -1, a = -1, c = -1, d = -1;
                    while (header.Length < 8192) {
                        int ch = stream.ReadByte();
                        if (ch < 0) return;
                        header.WriteByte((byte)ch);
                        a = b; b = c; c = d; d = ch;
                        if (a == 13 && b == 10 && c == 13 && d == 10) break;
                    }
                    if (!(a == 13 && b == 10 && c == 13 && d == 10)) return;
                    string headers = Encoding.ASCII.GetString(header.ToArray());
                    string[] lines = headers.Split(new[] { "\r\n" }, StringSplitOptions.None);
                    string[] request = lines[0].Split(' ');
                    if (request.Length < 2) { Reply(stream, 400, "bad request"); return; }
                    string method = request[0], route = request[1];
                    int length = 0; string origin = null;
                    foreach (string line in lines) {
                        if (line.StartsWith("Content-Length:", StringComparison.OrdinalIgnoreCase))
                            int.TryParse(line.Substring(15).Trim(), out length);
                        if (line.StartsWith("Origin:", StringComparison.OrdinalIgnoreCase))
                            origin = line.Substring(7).Trim();
                    }
                    if (!AllowedOrigin(origin)) { Reply(stream, 403, "origin forbidden"); return; }
                    if (method == "OPTIONS") { Reply(stream, 204, ""); return; }
                    if (method == "GET" && route == "/health") { Reply(stream, 200, "Now Playing Toast OK"); return; }
                    if (method == "GET" && route == "/control") {
                        string command;
                        if (!Controls.TryDequeue(out command)) command = "none";
                        Reply(stream, 200, command);
                        return;
                    }
                    if (method != "POST" || route != "/track" || length < 2 || length > 16384) {
                        Reply(stream, 400, "invalid request"); return;
                    }
                    byte[] bytes = new byte[length];
                    int read = 0;
                    while (read < length) {
                        int n = stream.Read(bytes, read, length - read);
                        if (n <= 0) return;
                        read += n;
                    }
                    Messages.Enqueue(Encoding.UTF8.GetString(bytes));
                    Reply(stream, 200, "ok");
                }
            } catch (IOException) { }
              catch (ObjectDisposedException) { }
              catch (Exception) { }
        }
    }

    private static void Reply(Stream stream, int status, string text) {
        byte[] body = Encoding.UTF8.GetBytes(text);
        string reason = status == 200 ? "OK" : status == 204 ? "No Content" : "Bad Request";
        string h = "HTTP/1.1 " + status + " " + reason + "\r\n" +
          "Content-Type: text/plain; charset=utf-8\r\n" +
          "Access-Control-Allow-Origin: *\r\n" +
          "Access-Control-Allow-Methods: POST, OPTIONS, GET\r\n" +
          "Access-Control-Allow-Headers: Content-Type\r\n" +
          "Access-Control-Allow-Private-Network: true\r\n" +
          "Cache-Control: no-store\r\n" +
          "Connection: close\r\n" +
          "Content-Length: " + body.Length + "\r\n\r\n";
        byte[] start = Encoding.ASCII.GetBytes(h);
        stream.Write(start, 0, start.Length);
        if (body.Length > 0) stream.Write(body, 0, body.Length);
    }
    public void Dispose() {
        running = false;
        if (listener != null) listener.Stop();
    }
}
public static class NptHotkey {
    [System.Runtime.InteropServices.DllImport("user32.dll", SetLastError=true)]
    public static extern bool RegisterHotKey(IntPtr hwnd, int id, uint mods, uint key);
    [System.Runtime.InteropServices.DllImport("user32.dll", SetLastError=true)]
    public static extern bool UnregisterHotKey(IntPtr hwnd, int id);
}
'@

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Width="442" Height="156" WindowStyle="None" ResizeMode="NoResize"
        AllowsTransparency="True" Background="Transparent" ShowInTaskbar="False"
        ShowActivated="False" Topmost="True" Opacity="0" WindowStartupLocation="Manual">
  <Border Background="#171A1F" CornerRadius="16" BorderThickness="1"
          BorderBrush="#5D5B57" Padding="12" Cursor="SizeAll">
    <Grid>
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="130"/>
        <ColumnDefinition Width="12"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>
      <Border Grid.Column="0" Background="#25262C" CornerRadius="11">
        <Grid>
          <TextBlock Name="CoverPlaceholder" Text="&#x266A;" FontSize="65"
                     Foreground="#D6B77C" HorizontalAlignment="Center"
                     VerticalAlignment="Center"/>
          <Image Name="AlbumCover" Stretch="UniformToFill" Visibility="Collapsed"/>
        </Grid>
      </Border>
      <Grid Grid.Column="2">
        <Grid.RowDefinitions>
          <RowDefinition Height="17"/>
          <RowDefinition Height="28"/>
          <RowDefinition Height="23"/>
          <RowDefinition Height="22"/>
          <RowDefinition Height="22"/>
          <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <TextBlock Grid.Row="0" Text="NOW PLAYING" Foreground="#D6B77C"
                   FontSize="10" FontWeight="SemiBold"/>
        <TextBlock Name="TrackTitle" Grid.Row="1" Text="Waiting for Spotify"
                   Foreground="White" FontSize="18" FontWeight="SemiBold"
                   Margin="0,0,84,0" TextTrimming="CharacterEllipsis" VerticalAlignment="Center"/>
        <Button Name="LikeTrackButton" Grid.Row="0" Grid.RowSpan="2"
                Width="34" Height="34" Margin="0,0,42,0" HorizontalAlignment="Right"
                VerticalAlignment="Top" Cursor="Hand" Focusable="False" IsEnabled="False"
                Opacity="0.4" Content="+" FontSize="21" FontWeight="SemiBold" Foreground="#F5F5F5"
                Background="#292D35" BorderBrush="#555D66" ToolTip="Ajouter aux Titres lik&#xE9;s">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                      BorderThickness="1" CornerRadius="8">
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
            </ControlTemplate>
          </Button.Template>
        </Button>
        <Button Name="NextTrackButton" Grid.Row="0" Grid.RowSpan="2"
                Width="34" Height="34" HorizontalAlignment="Right" VerticalAlignment="Top"
                Cursor="Hand" Focusable="False" Background="#292D35" BorderBrush="#555D66"
                ToolTip="Morceau suivant">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                      BorderThickness="1" CornerRadius="8">
                <Viewbox Width="17" Height="15" Stretch="Uniform">
                  <Path Fill="#F5F5F5" Data="M0,0 L7,6 L0,12 Z M7,0 L14,6 L7,12 Z M15,0 L18,0 L18,12 L15,12 Z"/>
                </Viewbox>
              </Border>
            </ControlTemplate>
          </Button.Template>
        </Button>
        <TextBlock Name="TrackArtist" Grid.Row="2" Text="No track received"
                   Foreground="#E2E5E9" FontSize="12"
                   TextTrimming="CharacterEllipsis"/>
        <TextBlock Name="TrackAlbum" Grid.Row="3" Text=""
                   Foreground="#B8BFC6" FontSize="12"
                   TextTrimming="CharacterEllipsis"/>
        <TextBlock Name="TrackMeta" Grid.Row="4" Text=""
                   Foreground="#DDDFE2" FontSize="12"/>
        <Grid Grid.Row="5" Height="4" VerticalAlignment="Bottom">
          <Border Name="ProgressTrack" Background="#393D44" CornerRadius="2"/>
          <Border Name="ProgressFill" Background="#D6B77C" CornerRadius="2"
                  Width="0" HorizontalAlignment="Left"/>
        </Grid>
      </Grid>
    </Grid>
  </Border>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$win = [Windows.Markup.XamlReader]::Load($reader)
$title = $win.FindName("TrackTitle")
$artist = $win.FindName("TrackArtist")
$album = $win.FindName("TrackAlbum")
$meta = $win.FindName("TrackMeta")
$cover = $win.FindName("AlbumCover")
$placeholder = $win.FindName("CoverPlaceholder")
$progressTrack = $win.FindName("ProgressTrack")
$progressFill = $win.FindName("ProgressFill")
$nextButton = $win.FindName("NextTrackButton")
$likeButton = $win.FindName("LikeTrackButton")
$screen = [System.Windows.SystemParameters]::WorkArea
$win.Left = $screen.Right - $win.Width - 20
$win.Top  = $screen.Bottom - $win.Height - 20

# Position can be changed by dragging the notification and is retained across sessions.
$script:settingsFile = Join-Path $env:LOCALAPPDATA 'NowPlayingToast\position.json'
try {
    if (Test-Path -LiteralPath $script:settingsFile) {
        $saved = Get-Content -LiteralPath $script:settingsFile -Raw | ConvertFrom-Json
        $left = [double]$saved.left
        $top = [double]$saved.top
        $virtualLeft = [System.Windows.SystemParameters]::VirtualScreenLeft
        $virtualTop = [System.Windows.SystemParameters]::VirtualScreenTop
        $virtualRight = $virtualLeft + [System.Windows.SystemParameters]::VirtualScreenWidth
        $virtualBottom = $virtualTop + [System.Windows.SystemParameters]::VirtualScreenHeight
        # Allow some margin for different screen resolutions after unplugging a monitor.
        if (-not [double]::IsNaN($left) -and -not [double]::IsNaN($top) -and
            $left -ge $virtualLeft - 30 -and $left -le $virtualRight - 80 -and
            $top -ge $virtualTop - 30 -and $top -le $virtualBottom - 60) {
            $win.Left = $left
            $win.Top = $top
        }
    }
} catch {
    Write-Warning "Position enregistree illisible, retour au coin inferieur droit."
}

# Clipping explicitly rounds the art itself, not just its container.
$clip = New-Object System.Windows.Media.RectangleGeometry
$clip.Rect = [System.Windows.Rect]::new(0, 0, 130, 130)
$clip.RadiusX = 11
$clip.RadiusY = 11
$cover.Clip = $clip
$win.IsHitTestVisible = $false
$script:dragging = $false

$script:currentUri = ''
$script:hasTrack = $false
$script:canLike = $false
$script:likeBrushOff = ([System.Windows.Media.BrushConverter]::new()).ConvertFromString("#292D35")
$script:likeBrushOn = ([System.Windows.Media.BrushConverter]::new()).ConvertFromString("#1E5740")
$script:playing = $false
$script:durationMs = 0.0
$script:progressMs = 0.0
$script:lastSample = [DateTime]::UtcNow
$script:coverUrl = ''
$script:lastMessageAt = [DateTime]::MinValue

# Smooth opacity transitions: 300 ms in, 450 ms out.
# FillBehavior Stop returns to the base opacity (assigned before each animation).
function Set-ToastOpacitySmooth {
    param(
        [double]$From,
        [double]$To,
        [int]$DurationMs
    )
    $property = [System.Windows.Window]::OpacityProperty
    $win.BeginAnimation($property, $null)
    $win.Opacity = $To
    $animation = New-Object System.Windows.Media.Animation.DoubleAnimation
    $animation.From = $From
    $animation.To = $To
    $animation.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds($DurationMs))
    $animation.FillBehavior = [System.Windows.Media.Animation.FillBehavior]::Stop
    $animation.EasingFunction = New-Object System.Windows.Media.Animation.SineEase
    $win.BeginAnimation($property, $animation)
}

$script:hideTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:hideTimer.Interval = [TimeSpan]::FromSeconds(7)
$script:hideTimer.Add_Tick({
    $script:hideTimer.Stop()
    $currentOpacity = [double]$win.Opacity
    if ($currentOpacity -gt 0.01) {
        Set-ToastOpacitySmooth -From $currentOpacity -To 0 -DurationMs 450
    }
    $win.IsHitTestVisible = $false
})
$script:showToast = {
    if (-not $script:hasTrack -or ([DateTime]::UtcNow - $script:lastMessageAt).TotalSeconds -gt 20) { return }
    $script:hideTimer.Stop()
    $currentOpacity = [double]$win.Opacity
    $win.IsHitTestVisible = $true
    $win.Topmost = $true
    if ($currentOpacity -lt 0.98) {
        Set-ToastOpacitySmooth -From $currentOpacity -To 1 -DurationMs 300
    }
    $script:hideTimer.Start()
}

$script:pulse = New-Object System.Windows.Threading.DispatcherTimer
$script:pulse.Interval = [TimeSpan]::FromMilliseconds(250)
$script:pulse.Add_Tick({
    $elapsed = if ($script:playing) { ([DateTime]::UtcNow - $script:lastSample).TotalMilliseconds } else { 0 }
    $nowMs = [Math]::Min($script:durationMs, $script:progressMs + $elapsed)
    $ratio = if ($script:durationMs -gt 0) { $nowMs / $script:durationMs } else { 0 }
    $progressFill.Width = [Math]::Max(0, $progressTrack.ActualWidth * $ratio)
})

$script:bridge = New-Object NptLocalBridge
try { $script:bridge.Start() }
catch {
    throw "Port local 43827 indisponible. Une autre instance du compagnon tourne-t-elle deja ? $($_.Exception.Message)"
}
$script:incoming = New-Object System.Windows.Threading.DispatcherTimer
$script:incoming.Interval = [TimeSpan]::FromMilliseconds(125)
$script:incoming.Add_Tick({
    $json = $null
    while ($script:bridge.Messages.TryDequeue([ref]$json)) {
        try {
            $item = ConvertFrom-Json -InputObject $json
            if ([string]::IsNullOrWhiteSpace([string]$item.uri)) { continue }
            $changed = $script:currentUri -ne [string]$item.uri
            $script:currentUri = [string]$item.uri
            $script:hasTrack = $true
            $script:lastMessageAt = [DateTime]::UtcNow
            $title.Text = [string]$item.title
            $script:canLike = ($item.likable -eq $true) -and ([string]$item.uri -match '^spotify:track:[A-Za-z0-9]{22}$')
            $liked = $item.liked -eq $true
            $likeButton.IsEnabled = $script:canLike
            $likeButton.Opacity = if ($script:canLike) { 1 } else { 0.4 }
            $likeButton.Content = if ($liked) { [string][char]0x2713 } else { "+" }
            $likeButton.Background = if ($liked) { $script:likeBrushOn } else { $script:likeBrushOff }
            $likeButton.ToolTip = if (-not $script:canLike) { "Disponible pour les morceaux Spotify uniquement" } elseif ($liked) { "Retirer des Titres likes" } else { "Ajouter aux Titres likes" }
            $artist.Text = [string]$item.artist
            $album.Text = [string]$item.album
            $date = if ($item.year -match '^\d{4}$') { [string]$item.year } else { '--' }
            $mins = if ([double]$item.durationMs -gt 0) {
                [TimeSpan]::FromMilliseconds([double]$item.durationMs).ToString('m\:ss')
            } else { '--:--' }
            $meta.Text = "$date     |     $mins"
            $script:durationMs = [Math]::Max(0, [double]$item.durationMs)
            $script:progressMs = [Math]::Max(0, [double]$item.progressMs)
            $script:lastSample = [DateTime]::UtcNow
            $script:playing = $item.playing -eq $true
            if ($script:coverUrl -ne [string]$item.coverUrl) {
                $script:coverUrl = [string]$item.coverUrl
                $cover.Visibility = "Collapsed"
                $placeholder.Visibility = "Visible"
                if ($script:coverUrl -match '^https://') {
                    try {
                        $img = New-Object System.Windows.Media.Imaging.BitmapImage
                        $img.BeginInit()
                        $img.UriSource = New-Object System.Uri($script:coverUrl)
                        $img.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnDemand
                        $img.EndInit()
                        $cover.Source = $img
                        $cover.Visibility = "Visible"
                        $placeholder.Visibility = "Collapsed"
                    } catch { }
                }
            }
            if ($changed -or [string]$item.action -eq 'show') { & $script:showToast }
        } catch {
            Write-Warning "Metadata ignoree : $($_.Exception.Message)"
        }
    }
})

$script:hotkeyId = 47511
$script:source = $null
$script:hotkeyOK = $false
$script:hwnd = [IntPtr]::Zero
$script:hook = [System.Windows.Interop.HwndSourceHook] {
    param($hwnd, $message, $wparam, $lparam, [ref]$handled)
    if ($message -eq 0x0021) {
        # MA_NOACTIVATE (3): permit mouse messages without stealing app focus.
        $handled.Value = $true
        return [IntPtr]3
    }
    if ($message -eq 0x0312 -and $wparam.ToInt32() -eq $script:hotkeyId) {
        & $script:showToast
        $handled.Value = $true
    }
    return [IntPtr]::Zero
}


# The UI queues only "next"; Spotify's JS extension executes the action.
$nextButton.Add_Click({
    if (-not $script:hasTrack) { return }
    $script:bridge.Controls.Enqueue("next")
    $script:hideTimer.Stop()
    $script:hideTimer.Start()
})
$likeButton.Add_Click({
    if (-not $script:hasTrack -or -not $script:canLike) { return }
    if (([DateTime]::UtcNow - $script:lastMessageAt).TotalSeconds -gt 15) { return }
    $script:bridge.Controls.Enqueue("toggle_like:" + $script:currentUri)
    $script:hideTimer.Stop()
    $script:hideTimer.Start()
})
# Drag anywhere except the two control buttons.
$win.Add_MouseLeftButtonDown({
    if ($win.Opacity -le 0.15 -or -not $script:hasTrack -or $nextButton.IsMouseOver -or $likeButton.IsMouseOver) { return }
    $script:hideTimer.Stop()
    $script:dragging = $true
    $win.BeginAnimation([System.Windows.Window]::OpacityProperty, $null)
    $win.Opacity = 1
    try {
        $win.DragMove()
    } catch {
        Write-Warning "Deplacement non disponible : $($_.Exception.Message)"
    } finally {
        $script:dragging = $false
        try {
            $position = @{ left = [Math]::Round($win.Left, 2); top = [Math]::Round($win.Top, 2) }
            $folder = Split-Path -Parent $script:settingsFile
            if (-not (Test-Path -LiteralPath $folder)) {
                New-Item -ItemType Directory -Path $folder -Force | Out-Null
            }
            $json = $position | ConvertTo-Json -Compress
            [IO.File]::WriteAllText($script:settingsFile, $json, [Text.UTF8Encoding]::new($false))
        } catch {
            Write-Warning "Enregistrement de position impossible : $($_.Exception.Message)"
        }
        $script:hideTimer.Stop()
        $script:hideTimer.Start()
    }
})

# Keep notification visible while hovered to allow grabbing it comfortably.
$win.Add_MouseEnter({
    if ($win.Opacity -gt 0.15) { $script:hideTimer.Stop() }
})
$win.Add_MouseLeave({
    if (-not $script:dragging -and $win.Opacity -gt 0.15) {
        $script:hideTimer.Stop()
        $script:hideTimer.Start()
    }
})

$win.Add_SourceInitialized({
    $helper = New-Object System.Windows.Interop.WindowInteropHelper($win)
    $script:hwnd = $helper.Handle
    $script:source = [System.Windows.Interop.HwndSource]::FromHwnd($script:hwnd)
    $script:source.AddHook($script:hook)
    $script:hotkeyOK = [NptHotkey]::RegisterHotKey($script:hwnd, $script:hotkeyId, 0x4006, 0x57)
    Write-Host "Raccourci Ctrl+Maj+W enregistre : $script:hotkeyOK" -ForegroundColor Cyan
    if (-not $script:hotkeyOK) {
        Write-Warning "Ctrl+Maj+W reserve. Fermer les autres programmes utilisant ce raccourci."
    }
})
$win.Add_Loaded({
    $script:pulse.Start()
    $script:incoming.Start()
})
$win.Add_Closed({
    $script:hideTimer.Stop()
    $script:pulse.Stop()
    $script:incoming.Stop()
    if ($script:hotkeyOK) {
        [void][NptHotkey]::UnregisterHotKey($script:hwnd, $script:hotkeyId)
    }
    if ($script:source) { $script:source.RemoveHook($script:hook) }
    $script:bridge.Dispose()
})
Write-Host 'Now Playing Toast v0.7 : Suivant + Titres likes, position memorisee' -ForegroundColor Green
Write-Host 'Demarrer Spotify avec l extension now-playing-toast.js active.'
Write-Host 'Le compagnon ne s affiche que lorsqu il recoit un morceau. Fermer PowerShell pour arreter.'
$app = New-Object System.Windows.Application
$app.ShutdownMode = [System.Windows.ShutdownMode]::OnMainWindowClose
[void]$app.Run($win)
