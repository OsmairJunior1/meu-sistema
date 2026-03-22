$html = [System.IO.File]::ReadAllText('C:\Users\Junior\Desktop\versao 1.0\1.1\1.2\1.3\sistema.html', [System.Text.Encoding]::UTF8)

# ── 1. CSS ──────────────────────────────────────────────────────────────────
$css = @"

  /* ── PWA Install Banner ── */
  #pwa-banner{
    display:none;position:fixed;left:0;right:0;
    bottom:calc(64px + env(safe-area-inset-bottom,0px));
    z-index:500;padding:0 12px 8px;
    pointer-events:none;
  }
  #pwa-banner-inner{
    background:#fff;border-radius:18px;
    box-shadow:0 4px 24px rgba(15,42,68,.18),0 1px 6px rgba(0,0,0,.08);
    border:1px solid rgba(15,42,68,.08);
    padding:12px 14px;display:flex;align-items:center;gap:10px;
    pointer-events:all;
    transition:opacity .3s,transform .3s;
  }
  #pwa-banner.hide #pwa-banner-inner{opacity:0;transform:translateY(16px)}

"@

$html = $html.Replace('</style>', $css + '</style>')

# ── 2. HTML banner ──────────────────────────────────────────────────────────
$bannerHtml = @"
<!-- ── PWA INSTALL BANNER — mobile only ── -->
<div id="pwa-banner">
  <div id="pwa-banner-inner">
    <img src="192x192.png" width="42" height="42" style="border-radius:11px;flex-shrink:0" alt="">
    <div id="pwa-banner-text" style="flex:1;min-width:0">
      <div style="font-size:14px;font-weight:800;color:#0F2A44;letter-spacing:-.02em;line-height:1.2">Instale o MonBluu</div>
      <div style="font-size:11.5px;color:#64748b;margin-top:2px">Acesso rapido, sem abrir o navegador</div>
    </div>
    <div id="pwa-ios-hint" style="display:none;flex:1;font-size:11.5px;color:#0F2A44;line-height:1.45">
      Toque em <strong>Compartilhar</strong> e depois em <strong>Adicionar a Tela de Inicio</strong>
    </div>
    <button id="pwa-install-btn" onclick="installPWA()" style="background:#0F2A44;color:#fff;border:none;border-radius:10px;padding:8px 14px;font-size:13px;font-weight:700;cursor:pointer;flex-shrink:0;font-family:inherit;white-space:nowrap">Instalar</button>
    <button onclick="dismissPWABanner()" style="background:none;border:none;color:#94a3b8;font-size:22px;line-height:1;cursor:pointer;padding:2px 6px;flex-shrink:0">&times;</button>
  </div>
</div>

"@

$swMarker = "if('serviceWorker' in navigator){"
$html = $html.Replace($swMarker, $bannerHtml + $swMarker)

# ── 3. JS logic ─────────────────────────────────────────────────────────────
$jsMarker = "navigator.serviceWorker.register('sw.js').catch(function(){});"

$pwaJs = @"

// ── PWA INSTALL BANNER LOGIC ──────────────────────────────────────────────
(function(){
  var inPWA = window.matchMedia('(display-mode: standalone)').matches
            || window.navigator.standalone === true;
  if(inPWA) return;
  if(localStorage.getItem('pwa-dismissed')) return;
  if(window.innerWidth > 600) return;

  var isIOS = /iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase());
  var banner = document.getElementById('pwa-banner');

  window.addEventListener('beforeinstallprompt', function(e){
    e.preventDefault();
    window._pwaPrompt = e;
    if(banner) banner.style.display = 'flex';
  });

  if(isIOS){
    setTimeout(function(){
      if(banner) banner.style.display = 'flex';
    }, 3000);
  }

  window.addEventListener('appinstalled', function(){
    dismissPWABanner();
  });
})();

window.installPWA = function(){
  var isIOS = /iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase());
  if(window._pwaPrompt){
    window._pwaPrompt.prompt();
    window._pwaPrompt.userChoice.then(function(){ dismissPWABanner(); });
    window._pwaPrompt = null;
  } else if(isIOS){
    var btn = document.getElementById('pwa-install-btn');
    var text = document.getElementById('pwa-banner-text');
    var hint = document.getElementById('pwa-ios-hint');
    if(btn) btn.style.display = 'none';
    if(text) text.style.display = 'none';
    if(hint){ hint.style.display = 'block'; }
  }
};

window.dismissPWABanner = function(){
  try{ localStorage.setItem('pwa-dismissed','1'); }catch(e){}
  var b = document.getElementById('pwa-banner');
  if(b){
    b.classList.add('hide');
    setTimeout(function(){ b.style.display='none'; b.classList.remove('hide'); }, 320);
  }
};

"@

$html = $html.Replace($jsMarker, $jsMarker + $pwaJs)

[System.IO.File]::WriteAllText('C:\Users\Junior\Desktop\versao 1.0\1.1\1.2\1.3\sistema.html', $html, [System.Text.Encoding]::UTF8)
Write-Host 'PWA banner inserted successfully.'
