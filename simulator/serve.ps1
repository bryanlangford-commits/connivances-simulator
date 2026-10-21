param(
  [int]$Port = 8791,
  [string]$Root = $PSScriptRoot
)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $Root on http://localhost:$Port/"

$mime = @{
  ".html" = "text/html"; ".htm" = "text/html"; ".js" = "application/javascript"
  ".css" = "text/css"; ".json" = "application/json"; ".png" = "image/png"
  ".jpg" = "image/jpeg"; ".jpeg" = "image/jpeg"; ".svg" = "image/svg+xml"
  ".ico" = "image/x-icon"
}

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $request = $context.Request
  $response = $context.Response
  try {
    $path = $request.Url.AbsolutePath.TrimStart("/")
    if ($request.HttpMethod -eq 'POST' -and $path -like '__save/*') {
      # Dev-only export endpoint: POST body is written verbatim to <Root>\<filename>.
      $saveName = [System.IO.Path]::GetFileName($path.Substring(7))
      $savePath = Join-Path $Root $saveName
      $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
      $body = $reader.ReadToEnd(); $reader.Close()
      [System.IO.File]::WriteAllText($savePath, $body, (New-Object System.Text.UTF8Encoding($false)))
      $response.StatusCode = 200
      $ok = [System.Text.Encoding]::UTF8.GetBytes("saved $saveName")
      $response.OutputStream.Write($ok, 0, $ok.Length)
    } else {
      if ([string]::IsNullOrEmpty($path)) { $path = "connivances_simulator_v11_6_4.html" }
      $fullPath = Join-Path $Root $path
      if (Test-Path $fullPath -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
        $contentType = $mime[$ext]
        if (-not $contentType) { $contentType = "application/octet-stream" }
        $bytes = [System.IO.File]::ReadAllBytes($fullPath)
        $response.ContentType = $contentType
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
      } else {
        $response.StatusCode = 404
        $notFound = [System.Text.Encoding]::UTF8.GetBytes("Not found: $path")
        $response.OutputStream.Write($notFound, 0, $notFound.Length)
      }
    }
  } catch {
    $response.StatusCode = 500
  } finally {
    $response.OutputStream.Close()
  }
}
