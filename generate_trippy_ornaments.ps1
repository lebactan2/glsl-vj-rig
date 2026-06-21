Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Batches = @(
    @{
        Title = "Trippy Ornaments"
        SourceDir = Join-Path $Root "Trippy Ornaments"
        OutDir = Join-Path $Root "moodboard_htmls\trippy_ornaments_all"
    },
    @{
        Title = "Trippy Ornaments 3-001"
        SourceDir = Join-Path $Root "Trippy Ornaments-3-001\Trippy Ornaments"
        OutDir = Join-Path $Root "moodboard_htmls\trippy_ornaments_all"
    }
)

$ImageExts = @(".jpg", ".jpeg", ".png", ".webp", ".heic")

function Ensure-Dir($Path) {
    if (!(Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Get-HashNumber($Text) {
    $h = [double]2166136261
    foreach ($c in $Text.ToCharArray()) {
        $hInt = [int64]$h -bxor [int64][char]$c
        $h = [Math]::Floor(($hInt * 16777619.0) % 4294967296.0)
        if ($h -lt 0) { $h += 4294967296.0 }
    }
    return [int64]$h
}

function Get-FallbackPalette($Name) {
    $h = Get-HashNumber $Name
    $colors = @()
    for ($i = 0; $i -lt 5; $i++) {
        $t = (($h -shr ($i * 5)) -band 31) / 31.0
        $r = 0.28 + 0.62 * [Math]::Abs([Math]::Sin($t * 6.283 + $i))
        $g = 0.18 + 0.68 * [Math]::Abs([Math]::Sin($t * 5.1 + $i * 1.7))
        $b = 0.24 + 0.70 * [Math]::Abs([Math]::Cos($t * 4.7 + $i * 0.9))
        $colors += ,@($r, $g, $b)
    }
    return ,$colors
}

function Format-Color($Color) {
    return "vec3({0:N3}, {1:N3}, {2:N3})" -f $Color[0], $Color[1], $Color[2]
}

function Save-FallbackPreview($OutPath, $BaseName, $Palette) {
    $bmp = New-Object System.Drawing.Bitmap 720, 720
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $bg = [System.Drawing.Color]::FromArgb(255, [int]($Palette[0][0] * 255), [int]($Palette[0][1] * 255), [int]($Palette[0][2] * 255))
    $gfx.Clear($bg)

    for ($i = 0; $i -lt 18; $i++) {
        $c = $Palette[$i % $Palette.Count]
        $color = [System.Drawing.Color]::FromArgb(120, [int]($c[0] * 255), [int]($c[1] * 255), [int]($c[2] * 255))
        $brush = New-Object System.Drawing.SolidBrush $color
        $size = 120 + ($i % 6) * 46
        $x = 360 + [Math]::Cos($i * 0.74) * (30 + $i * 14) - $size / 2
        $y = 360 + [Math]::Sin($i * 0.91) * (30 + $i * 12) - $size / 2
        $gfx.FillEllipse($brush, [float]$x, [float]$y, [float]$size, [float]$size)
        $brush.Dispose()
    }

    $font = New-Object System.Drawing.Font "Arial", 34, ([System.Drawing.FontStyle]::Bold)
    $textBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(230, 255, 246, 220))
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $gfx.DrawString($BaseName, $font, $textBrush, [System.Drawing.RectangleF]::new(0, 320, 720, 90), $sf)

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $sf.Dispose(); $textBrush.Dispose(); $font.Dispose(); $gfx.Dispose(); $bmp.Dispose()
}

function Get-PaletteAndPreview($SourcePath, $OutPath, $BaseName) {
    $ext = [IO.Path]::GetExtension($SourcePath).ToLowerInvariant()
    if ($ext -eq ".heic") {
        $palette = Get-FallbackPalette $BaseName
        Save-FallbackPreview $OutPath $BaseName $palette
        return ,@{ Palette = $palette; Kind = "filename-fallback" }
    }

    try {
        $img = [System.Drawing.Image]::FromFile($SourcePath)
        $side = [Math]::Min($img.Width, $img.Height)
        $srcRect = [System.Drawing.Rectangle]::new([int](($img.Width - $side) / 2), [int](($img.Height - $side) / 2), $side, $side)
        $preview = New-Object System.Drawing.Bitmap 720, 720
        $gfx = [System.Drawing.Graphics]::FromImage($preview)
        $gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $gfx.DrawImage($img, [System.Drawing.Rectangle]::new(0, 0, 720, 720), $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        $preview.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

        $sample = New-Object System.Drawing.Bitmap 36, 36
        $sg = [System.Drawing.Graphics]::FromImage($sample)
        $sg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $sg.DrawImage($preview, 0, 0, 36, 36)
        $pixelCount = 0.0
        $sumR = 0.0
        $sumG = 0.0
        $sumB = 0.0
        for ($y = 0; $y -lt 36; $y++) {
            for ($x = 0; $x -lt 36; $x++) {
                $px = $sample.GetPixel($x, $y)
                $pixelCount += 1.0
                $sumR += [double]$px.R
                $sumG += [double]$px.G
                $sumB += [double]$px.B
            }
        }
        $avg = @(($sumR / $pixelCount) / 255.0, ($sumG / $pixelCount) / 255.0, ($sumB / $pixelCount) / 255.0)
        $palette = @(,$avg)
        $h = Get-HashNumber $BaseName
        for ($i = 0; $i -lt 4; $i++) {
            $t = (($h -shr ($i * 5)) -band 31) / 31.0
            $accent = @(
                0.28 + 0.62 * [Math]::Abs([Math]::Sin($t * 6.283 + $i)),
                0.18 + 0.68 * [Math]::Abs([Math]::Sin($t * 5.1 + $i * 1.7)),
                0.24 + 0.70 * [Math]::Abs([Math]::Cos($t * 4.7 + $i * 0.9))
            )
            $palette += ,@(
                [Math]::Min(1.0, $avg[0] * 0.45 + $accent[0] * 0.75),
                [Math]::Min(1.0, $avg[1] * 0.45 + $accent[1] * 0.75),
                [Math]::Min(1.0, $avg[2] * 0.45 + $accent[2] * 0.75)
            )
        }
        while ($palette.Count -lt 5) {
            $palette += ,(Get-FallbackPalette $BaseName)[0]
        }

        $sg.Dispose(); $sample.Dispose(); $gfx.Dispose(); $preview.Dispose(); $img.Dispose()
        return ,@{ Palette = $palette; Kind = "image" }
    }
    catch {
        $palette = Get-FallbackPalette $BaseName
        Save-FallbackPreview $OutPath $BaseName $palette
        return ,@{ Palette = $palette; Kind = "filename-fallback" }
    }
}

function New-Shader($BaseName, $Palette, $VariantText) {
    $variant = Get-HashNumber $VariantText
    $seed = ($variant % 997) / 997.0
    $speed = "{0:N3}" -f (0.15 + $seed * 0.25)
    $twist = "{0:N3}" -f (0.5 + $seed * 1.5)
    $scale = "{0:N3}" -f (1.5 + ($variant % 5) * 0.5)
    $petalCount = "{0:N1}" -f (($variant % 5) + 3)
    $c1 = Format-Color $Palette[0]
    $c2 = Format-Color $Palette[1]
    $c3 = Format-Color $Palette[2]
    $c4 = Format-Color $Palette[3]
    $c5 = Format-Color $Palette[4]

    return @"
// Hash function
vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// Gradient noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

// Fractional Brownian Motion
float fbm(vec2 p) {
    float f = 0.0;
    float w = 0.5;
    mat2 m = mat2(0.8, 0.6, -0.6, 0.8);
    for(int i = 0; i < 5; i++) {
        f += w * noise(p);
        p = m * p * 2.0;
        w *= 0.5;
    }
    return f;
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= iResolution.x / iResolution.y;

    float t = iTime * $speed;
    vec3 c1 = $c1; vec3 c2 = $c2; vec3 c3 = $c3; vec3 c4 = $c4; vec3 c5 = $c5;
    
    // Ornamental Symmetry (Kaleidoscope)
    float segments = $petalCount * 2.0; 
    float angle = atan(p.y, p.x);
    float radius = length(p);
    
    // Smooth kaleidoscope mirroring
    angle = mod(angle, 6.28318 / segments);
    angle = abs(angle - 3.14159 / segments);
    
    // Twisting
    angle += radius * $twist - t * 0.5;
    vec2 symP = radius * vec2(cos(angle), sin(angle));
    
    // Domain Warping using fBm
    symP *= $scale;
    
    vec2 q = vec2(fbm(symP + vec2(0.0, 0.0) + t * 0.3),
                  fbm(symP + vec2(5.2, 1.3) - t * 0.2));

    vec2 r = vec2(fbm(symP + 4.0 * q + vec2(1.7, 9.2) - t * 0.4),
                  fbm(symP + 4.0 * q + vec2(8.3, 2.8) + t * 0.5));

    float f = fbm(symP + 4.0 * r);

    // Multi-stop gradient mapping based on noise value
    vec3 col = vec3(0.0);
    // Expand the [0, 1] fbm value to cycle through the 5 colors
    float cycle = clamp(f * 0.5 + 0.5, 0.0, 1.0) * 4.0;
    
    if (cycle < 1.0) col = mix(c1, c2, cycle);
    else if (cycle < 2.0) col = mix(c2, c3, cycle - 1.0);
    else if (cycle < 3.0) col = mix(c3, c4, cycle - 2.0);
    else col = mix(c4, c5, cycle - 3.0);
    
    // Add ridge lines for extra ornamental detail (like marble veins)
    float veins = fbm(symP * 2.5 + 4.0 * r);
    veins = 1.0 - abs(veins); // sharp ridges
    veins = smoothstep(0.7, 1.0, veins);
    col = mix(col, mix(c1, vec3(1.0), 0.5), veins * 0.8); // glowy veins
    
    // Smooth vignette
    float vignette = smoothstep(1.8, 0.1, radius);
    col *= vignette;

    gl_FragColor = vec4(pow(clamp(col, 0.0, 1.0), vec3(0.85)), 1.0);
}
"@
}

function New-ShaderHtml($Title, $Glsl) {
    return @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shader: $Title</title>
    <style>body { margin: 0; overflow: hidden; background-color: #000; } canvas { display: block; width: 100vw; height: 100vh; }</style>
</head>
<body>
    <canvas id="glcanvas"></canvas>
    <script id="vertex-shader" type="x-shader/x-vertex">attribute vec2 position; void main() { gl_Position = vec4(position, 0.0, 1.0); }</script>
    <script id="fragment-shader" type="x-shader/x-fragment">
        precision highp float; uniform vec2 iResolution; uniform float iTime;

$Glsl
    </script>
    <script>
        function main() {
            const canvas = document.getElementById("glcanvas"); const gl = canvas.getContext("webgl");
            const vs = gl.createShader(gl.VERTEX_SHADER); gl.shaderSource(vs, document.getElementById("vertex-shader").text); gl.compileShader(vs);
            const fs = gl.createShader(gl.FRAGMENT_SHADER); gl.shaderSource(fs, document.getElementById("fragment-shader").text); gl.compileShader(fs);
            const prog = gl.createProgram(); gl.attachShader(prog, vs); gl.attachShader(prog, fs); gl.linkProgram(prog);
            if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) { console.error("Link error: " + gl.getProgramInfoLog(prog)); console.error("FS Log: " + gl.getShaderInfoLog(fs)); }
            const pos = gl.getAttribLocation(prog, "position"); const res = gl.getUniformLocation(prog, "iResolution"); const time = gl.getUniformLocation(prog, "iTime");
            const buf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, buf); gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1,-1, 1,-1, -1,1, -1,1, 1,-1, 1,1]), gl.STATIC_DRAW);
            function render(t) {
                canvas.width = window.innerWidth; canvas.height = window.innerHeight; gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
                gl.useProgram(prog); gl.enableVertexAttribArray(pos); gl.bindBuffer(gl.ARRAY_BUFFER, buf); gl.vertexAttribPointer(pos, 2, gl.FLOAT, false, 0, 0);
                gl.uniform2f(res, gl.canvas.width, gl.canvas.height); gl.uniform1f(time, t * 0.001);
                gl.drawArrays(gl.TRIANGLES, 0, 6); requestAnimationFrame(render);
            }
            requestAnimationFrame(render);
        } window.onload = main;
    </script>
</body>
</html>
"@
}

function New-IndexHtml($Title, $Items) {
    $rows = ($Items | ForEach-Object {
@"
        <article class="card">
            <div class="thumbs">
                <img src="assets/$($_.BaseName).jpg" alt="$($_.BaseName) original">
                <iframe src="$($_.BaseName).html" title="$($_.BaseName) shader"></iframe>
            </div>
            <div class="meta"><strong>$($_.BaseName)</strong><a href="$($_.BaseName).html">Open shader</a></div>
        </article>
"@
    }) -join "`n"

    return @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$Title Shader Folder</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; background: #111; color: #f2efe8; font-family: Arial, sans-serif; }
        header { position: sticky; top: 0; z-index: 2; padding: 18px 24px; background: rgba(17,17,17,.92); border-bottom: 1px solid #333; }
        h1 { margin: 0; font-size: 22px; font-weight: 700; }
        p { margin: 6px 0 0; color: #b8b0a3; }
        main { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 18px; padding: 18px; }
        .card { background: #1b1b1b; border: 1px solid #333; border-radius: 8px; overflow: hidden; }
        .thumbs { display: grid; grid-template-columns: 1fr 1fr; aspect-ratio: 16 / 9; background: #000; }
        img, iframe { width: 100%; height: 100%; border: 0; object-fit: cover; }
        .meta { display: flex; justify-content: space-between; gap: 12px; padding: 12px; align-items: center; }
        a { color: #ffca6a; text-decoration: none; white-space: nowrap; }
    </style>
</head>
<body>
    <header><h1>$Title</h1><p>$($Items.Count) procedural GLSL conversions</p></header>
    <main>
$rows
    </main>
</body>
</html>
"@
}

$grandTotal = 0
foreach ($batch in $Batches) {
    $assetDir = Join-Path $batch.OutDir "assets"
    $glslDir = Join-Path $batch.OutDir "glsl"
    Ensure-Dir $assetDir
    Ensure-Dir $glslDir

    $items = @()
    $files = Get-ChildItem -LiteralPath $batch.SourceDir -File |
        Where-Object { $ImageExts -contains $_.Extension.ToLowerInvariant() } |
        Sort-Object Name

    foreach ($file in $files) {
        $baseName = [IO.Path]::GetFileNameWithoutExtension($file.Name)
        $outPreview = Join-Path $assetDir "$baseName.jpg"
        $sample = Get-PaletteAndPreview $file.FullName $outPreview $baseName | Select-Object -Last 1
        $palette = $sample["Palette"]
        $kind = $sample["Kind"]
        if (!$palette -or $palette.Count -lt 5) {
            $palette = Get-FallbackPalette $baseName
            $kind = "filename-fallback"
            Save-FallbackPreview $outPreview $baseName $palette
        }
        if (!$kind) { $kind = "image" }
        $glsl = New-Shader $baseName $palette "$($batch.Title):$baseName"
        Set-Content -LiteralPath (Join-Path $glslDir "$baseName.glsl") -Value $glsl -Encoding UTF8
        Set-Content -LiteralPath (Join-Path $batch.OutDir "$baseName.html") -Value (New-ShaderHtml $baseName $glsl) -Encoding UTF8
        $items += [pscustomobject]@{ BaseName = $baseName; Source = $kind }
        Write-Host "$($batch.Title): $baseName ($kind)"
    }

    Set-Content -LiteralPath (Join-Path $batch.OutDir "index.html") -Value (New-IndexHtml $batch.Title $items) -Encoding UTF8
    $grandTotal += $items.Count
}

Write-Host "Generated $grandTotal Trippy Ornaments shader conversions."
