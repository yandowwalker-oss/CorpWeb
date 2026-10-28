$ErrorActionPreference = 'Stop'
$page = (Invoke-RestMethod http://localhost:9222/json/list)[0]
$socket = [Net.WebSockets.ClientWebSocket]::new()
$socket.ConnectAsync([Uri]$page.webSocketDebuggerUrl, [Threading.CancellationToken]::None).GetAwaiter().GetResult() | Out-Null
$script:sequence = 0
$script:errors = [Collections.Generic.List[string]]::new()
function Cdp($Method, $Params = @{}) {
    $script:sequence++
    $id = $script:sequence
    $payload = @{ id=$id; method=$Method; params=$Params } | ConvertTo-Json -Depth 30 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($payload)
    $socket.SendAsync([ArraySegment[byte]]::new($bytes), [Net.WebSockets.WebSocketMessageType]::Text, $true, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
    while ($true) {
        $buffer = New-Object byte[] 262144
        $message = [IO.MemoryStream]::new()
        do {
            $received = $socket.ReceiveAsync([ArraySegment[byte]]::new($buffer), [Threading.CancellationToken]::None).GetAwaiter().GetResult()
            $message.Write($buffer, 0, $received.Count)
        } until ($received.EndOfMessage)
        $response = [Text.Encoding]::UTF8.GetString($message.ToArray()) | ConvertFrom-Json
        $message.Dispose()
        if ($response.method -eq 'Runtime.exceptionThrown') { $script:errors.Add(($response.params | ConvertTo-Json -Depth 10 -Compress)) }
        if ($response.method -eq 'Log.entryAdded' -and $response.params.entry.level -eq 'error') { $script:errors.Add($response.params.entry.text) }
        if ($response.id -eq $id) {
            if ($response.error) { throw ($response.error | ConvertTo-Json) }
            return $response.result
        }
    }
}
function Evaluate($Expression) {
    $answer = Cdp 'Runtime.evaluate' @{expression=$Expression; awaitPromise=$true; returnByValue=$true; userGesture=$true}
    if ($answer.exceptionDetails) { throw ($answer.exceptionDetails | ConvertTo-Json -Depth 12) }
    return $answer.result.value
}
function Key($Value, $Modifiers = 0) {
    Cdp 'Input.dispatchKeyEvent' @{type='keyDown'; key=$Value; modifiers=$Modifiers; windowsVirtualKeyCode= $(if($Value -eq 'Tab'){9}else{27})} | Out-Null
    Cdp 'Input.dispatchKeyEvent' @{type='keyUp'; key=$Value; modifiers=$Modifiers; windowsVirtualKeyCode= $(if($Value -eq 'Tab'){9}else{27})} | Out-Null
    Evaluate 'new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(()=>resolve(true))))' | Out-Null
}
function Assert($Condition, $Label) { if (!$Condition) { throw "FAIL: $Label" }; Write-Output "PASS: $Label" }
Cdp 'Runtime.enable' | Out-Null
Cdp 'Log.enable' | Out-Null
Cdp 'Page.enable' | Out-Null
foreach ($base in @('http://localhost:8080/', 'http://localhost:8080/CorpWeb/')) {
    Cdp 'Page.navigate' @{url=$base} | Out-Null
    Evaluate 'new Promise(resolve => { if (document.readyState === "complete") resolve(true); else window.addEventListener("load", () => resolve(true), {once:true}); })' | Out-Null
    $references = Evaluate @'
(async () => {
  const urls = [...document.querySelectorAll('[src],link[href]')].map(e => e.src || e.href);
  for (const e of document.querySelectorAll('[srcset]')) for (const candidate of e.srcset.split(',')) urls.push(new URL(candidate.trim().split(/\s+/)[0], document.baseURI).href);
  const failed = [];
  for (const url of new Set(urls)) if (!(await fetch(url)).ok) failed.push(url);
  const anchors = [...document.querySelectorAll('a[href^="#"]')].filter(e => !document.getElementById(e.hash.slice(1))).map(e => e.hash);
  return {failed, anchors, images: [...document.images].every(e => !e.complete || e.naturalWidth > 0), scripts: typeof closeMenu === 'function'};
})()
'@
    Assert ($references.failed.Count -eq 0 -and $references.anchors.Count -eq 0 -and $references.images -and $references.scripts) "Assets, anchors, image decoding, JavaScript at $base"
}
foreach ($width in @(1440, 1024, 768, 760, 390, 320)) {
    Cdp 'Emulation.setDeviceMetricsOverride' @{width=$width; height=900; deviceScaleFactor=1; mobile=$false} | Out-Null
    Evaluate 'new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(() => resolve(true))))' | Out-Null
    $layout = Evaluate @'
(() => ({width:innerWidth, document:document.documentElement.scrollWidth, collisions:[...document.querySelectorAll('main *, header *')].filter(e=>{const r=e.getBoundingClientRect();return r.width>0 && (r.right>innerWidth+1 || r.left < -1)}).map(e=>e.className)}))()
'@
    Assert ($layout.document -le $width -and $layout.collisions.Count -eq 0) "No horizontal overflow at ${width}px"
    if ($width -in @(1440,768,390)) {
        Evaluate '(async()=>{window.scrollTo({top:document.body.scrollHeight,behavior:"instant"});await new Promise(r=>setTimeout(r,150));await Promise.all([...document.images].map(i=>i.decode()));window.scrollTo({top:0,behavior:"instant"});return true;})()' | Out-Null
        $metrics = Cdp 'Page.getLayoutMetrics'
        $shot = Cdp 'Page.captureScreenshot' @{format='png'; captureBeyondViewport=$true; clip=@{x=0;y=0;width=$width;height=$metrics.cssContentSize.height;scale=1}}
        [IO.File]::WriteAllBytes((Join-Path $PWD ".local-preview/layout-$width.png"), [Convert]::FromBase64String($shot.data))
    }
}
Evaluate 'menu.click(); true' | Out-Null
Assert (Evaluate 'menu.getAttribute("aria-expanded")==="true" && getComputedStyle(nav).display!=="none"') 'Mobile menu opens'
Key 'Escape'
Assert (Evaluate 'menu.getAttribute("aria-expanded")==="false" && document.activeElement===menu') 'Menu Escape closes and restores focus'
Evaluate 'menu.click(); nav.querySelector("a").click(); true' | Out-Null
Assert (Evaluate 'menu.getAttribute("aria-expanded")==="false"') 'Mobile anchor closes menu'
Evaluate 'menu.click(); document.querySelector(".hero-copy").click(); true' | Out-Null
Assert (Evaluate 'menu.getAttribute("aria-expanded")==="false"') 'Outside click closes menu'
Evaluate 'menu.click(); true' | Out-Null
Cdp 'Emulation.setDeviceMetricsOverride' @{width=1024; height=900; deviceScaleFactor=1; mobile=$false} | Out-Null
Evaluate 'new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(()=>resolve(true))))' | Out-Null
Assert (Evaluate 'menu.getAttribute("aria-expanded")==="false" && getComputedStyle(nav).display!=="none"') 'Desktop resize resets mobile menu state'
Cdp 'Emulation.setDeviceMetricsOverride' @{width=320; height=900; deviceScaleFactor=1; mobile=$false} | Out-Null
Evaluate 'new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(()=>resolve(true))))' | Out-Null
Evaluate 'menu.click(); nav.querySelector("button").click(); true' | Out-Null
Assert (Evaluate 'dialog.open && document.activeElement.id==="dialog-title"') 'Mobile header CTA opens dialog at title'
Key 'Tab' 8
Assert (Evaluate 'document.activeElement===document.querySelector("#project-form [type=submit]")') 'Shift+Tab wraps focus from dialog title'
Key 'Tab'
Assert (Evaluate 'document.activeElement===document.querySelector(".close")') 'Tab wraps focus within dialog'
Key 'Escape'
Assert (Evaluate '!dialog.open && document.activeElement===menu && !document.body.classList.contains("dialog-open")') 'Dialog Escape restores visible mobile opener'
$ctas = Evaluate @'
(async () => {
  const failures=[];
  for (const trigger of document.querySelectorAll('[data-contact], [data-type]')) {
    trigger.click();
    if (!dialog.open || (trigger.dataset.type && projectType.value!==trigger.dataset.type)) failures.push(trigger.textContent);
    dialog.close();
    await new Promise(resolve=>requestAnimationFrame(resolve));
  }
  return {count:document.querySelectorAll('[data-contact], [data-type]').length,failures};
})()
'@
Assert ($ctas.failures.Count -eq 0) "All $($ctas.count) project CTAs open; service types preselected"
Evaluate 'document.querySelector(".contact button").click(); true' | Out-Null
Assert (Evaluate '!form.checkValidity()') 'Empty form blocked'
Evaluate 'document.getElementById("name").value="Preview Tester"; document.getElementById("email").value="invalid"; document.getElementById("details").value="A shaded lanai."; true' | Out-Null
Assert (Evaluate '!form.checkValidity()') 'Invalid email blocked'
Evaluate 'document.getElementById("email").value="preview@example.com"; form.requestSubmit(); true' | Out-Null
Assert (Evaluate '!result.hidden && output.value.includes("Preview Tester") && output.value.includes("A shaded lanai.") && document.activeElement===output && status.textContent.includes("Nothing has been sent")') 'Valid brief generated, focus set, no false sending claim'
Cdp 'Browser.grantPermissions' @{origin='http://localhost:8080';permissions=@('clipboardReadWrite','clipboardSanitizedWrite')} | Out-Null
$copy = Evaluate '(async()=>{document.getElementById("copy").click(); for(let i=0;i<30;i++){await new Promise(r=>setTimeout(r,100));if(status.textContent.includes("Brief copied"))return true;}return false;})()'
Assert $copy 'Native clipboard write resolves and confirms copy'
$fallback = Evaluate @'
(async()=>{
  const original=navigator.clipboard;
  Object.defineProperty(navigator,'clipboard',{configurable:true,value:{writeText:async()=>{throw Error('denied')}}});
  document.getElementById('copy').click();
  await new Promise(r=>setTimeout(r,100));
  const passed=status.textContent.includes('Automatic copying is unavailable') && document.activeElement===output && output.selectionEnd===output.value.length;
  Object.defineProperty(navigator,'clipboard',{configurable:true,value:original});
  return passed;
})()
'@
Assert $fallback 'Clipboard denial selects text and gives manual copy instructions'
Evaluate 'document.getElementById("details").value="Changed details"; document.getElementById("details").dispatchEvent(new Event("input",{bubbles:true})); true' | Out-Null
Assert (Evaluate 'result.hidden && !output.value') 'Editing invalidates stale brief'
Evaluate 'document.getElementById("name").value="   "; document.getElementById("name").dispatchEvent(new Event("input",{bubbles:true})); true' | Out-Null
Assert (Evaluate '!form.checkValidity()') 'Whitespace-only name blocked'
Evaluate 'document.querySelector(".close").click(); new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(()=>resolve(true))))' | Out-Null
Assert (Evaluate '!dialog.open && document.activeElement===document.querySelector(".contact button")') 'Close button restores original CTA'
Evaluate 'document.querySelector(".contact button").click(); true' | Out-Null
Cdp 'Input.dispatchMouseEvent' @{type='mousePressed';x=1;y=1;button='left';clickCount=1} | Out-Null
Cdp 'Input.dispatchMouseEvent' @{type='mouseReleased';x=1;y=1;button='left';clickCount=1} | Out-Null
Evaluate 'new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(()=>resolve(true))))' | Out-Null
Assert (Evaluate '!dialog.open') 'Backdrop click closes dialog'
Evaluate 'window.scrollTo(0,0); true' | Out-Null
Cdp 'Page.navigate' @{url='http://localhost:8080/CorpWeb/'} | Out-Null
Evaluate 'new Promise(resolve=>window.addEventListener("load",()=>resolve(true),{once:true}))' | Out-Null
Key 'Tab'
Assert (Evaluate 'document.activeElement.classList.contains("skip-link")') 'Keyboard starts with skip link'
Evaluate 'document.querySelector(".skip-link").click(); true' | Out-Null
Assert (Evaluate 'document.activeElement.id==="main"') 'Skip link focuses main content'
Assert ($script:errors.Count -eq 0) 'No page JavaScript exceptions or console errors'
$socket.Dispose()
