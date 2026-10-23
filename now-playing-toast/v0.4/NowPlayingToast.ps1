# Now Playing Toast v0.4 - local Windows companion (prototype)
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
          BorderBrush="#5D5B57" Padding="12">
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
                   TextTrimming="CharacterEllipsis" VerticalAlignment="Center"/>
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
$screen = [System.Windows.SystemParameters]::WorkArea
$win.Left = $screen.Right - $win.Width - 20
$win.Top  = $screen.Bottom - $win.Height - 20

# Clipping explicitly rounds the art itself, not just its container.
$clip = New-Object System.Windows.Media.RectangleGeometry
$clip.Rect = [System.Windows.Rect]::new(0, 0, 130, 130)
$clip.RadiusX = 11
$clip.RadiusY = 11
$cover.Clip = $clip
$win.IsHitTestVisible = $false

$script:currentUri = ''
$script:hasTrack = $false
$script:playing = $false
$script:durationMs = 0.0
$script:progressMs = 0.0
$script:lastSample = [DateTime]::UtcNow
$script:coverUrl = ''
$script:lastMessageAt = [DateTime]::MinValue

$script:hideTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:hideTimer.Interval = [TimeSpan]::FromSeconds(5)
$script:hideTimer.Add_Tick({
    $script:hideTimer.Stop()
    $win.Opacity = 0
    $win.IsHitTestVisible = $false
})
$script:showToast = {
    if (-not $script:hasTrack -or ([DateTime]::UtcNow - $script:lastMessageAt).TotalSeconds -gt 20) { return }
    $script:hideTimer.Stop()
    $win.Opacity = 1
    $win.IsHitTestVisible = $false
    $win.Topmost = $true
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
    if ($message -eq 0x0312 -and $wparam.ToInt32() -eq $script:hotkeyId) {
        & $script:showToast
        $handled.Value = $true
    }
    return [IntPtr]::Zero
}

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
Write-Host 'Now Playing Toast v0.4 : compagnon Windows pret sur 127.0.0.1:43827' -ForegroundColor Green
Write-Host 'Demarrer Spotify avec l extension now-playing-toast.js active.'
Write-Host 'Le compagnon ne s affiche que lorsqu il recoit un morceau. Fermer PowerShell pour arreter.'
$app = New-Object System.Windows.Application
$app.ShutdownMode = [System.Windows.ShutdownMode]::OnMainWindowClose
[void]$app.Run($win)
