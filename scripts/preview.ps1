param([int]$Port = 8080)
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path (Split-Path $PSScriptRoot -Parent) 'docs'))
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $Port)
$types = @{ '.html'='text/html; charset=utf-8'; '.css'='text/css; charset=utf-8'; '.js'='text/javascript; charset=utf-8'; '.png'='image/png'; '.jpg'='image/jpeg' }
$listener.Start()
Write-Output "Local preview: http://localhost:$Port/ (subpath test: http://localhost:$Port/CorpWeb/)"
try {
    while ($true) {
        $client = $listener.AcceptTcpClient()
        try {
            $stream = $client.GetStream()
            $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::ASCII, $false, 1024, $true)
            $request = $reader.ReadLine()
            if (!$request) { continue }
            while ($reader.ReadLine()) {}
            $path = [Uri]::UnescapeDataString(($request.Split(' ')[1].Split('?')[0]))
            if ($path.StartsWith('/CorpWeb/')) { $path = $path.Substring(8) }
            if ($path.EndsWith('/')) { $path += 'index.html' }
            $file = [IO.Path]::GetFullPath((Join-Path $root $path.TrimStart('/')))
            if ($file.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -and [IO.File]::Exists($file)) {
                $body = [IO.File]::ReadAllBytes($file)
                $mime = $types[[IO.Path]::GetExtension($file)]
                if (!$mime) { $mime = 'application/octet-stream' }
                $status = '200 OK'
            } else {
                $body = [Text.Encoding]::UTF8.GetBytes('Not found')
                $mime = 'text/plain; charset=utf-8'
                $status = '404 Not Found'
            }
            $header = [Text.Encoding]::ASCII.GetBytes("HTTP/1.1 $status`r`nContent-Type: $mime`r`nContent-Length: $($body.Length)`r`nConnection: close`r`nX-Content-Type-Options: nosniff`r`n`r`n")
            $stream.Write($header, 0, $header.Length)
            $stream.Write($body, 0, $body.Length)
            $reader.Dispose()
        } catch [IO.IOException] {
            # A browser can cancel a pending image request on navigation or exit.
            # Keep the preview available for the next request.
        } finally { $client.Dispose() }
    }
} finally { $listener.Stop() }
