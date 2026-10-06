# 发布 叠叠乐 到 GitHub (仓库 Olivia-1590/1999xran)
# 用法: 双击同目录的 "发布到GitHub.bat"   (或 PowerShell 里跑 .\push-ddl.ps1)

$ErrorActionPreference = 'Continue'
$RepoDir = 'D:\Software\Dsh\小瑞安侬小游戏\github'
$Remote  = 'https://github.com/Olivia-1590/1999xran'
$GameUrl = 'https://olivia-1590.github.io/1999xran/'

Write-Host ''
Write-Host '========================================' -ForegroundColor DarkGray
Write-Host '  发布 叠叠乐 · 小瑞安侬与尘酿鹰' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor DarkGray

if (-not (Test-Path (Join-Path $RepoDir '.git'))) {
  Write-Host '找不到本地仓库，请检查路径:' -ForegroundColor Red
  Write-Host $RepoDir
  exit 1
}
Set-Location $RepoDir

# ---------- 0) 提交尚未提交的改动 ----------
git add -A | Out-Null
if (git status --porcelain) {
  git commit -m 'update: 叠叠乐' | Out-Null
  Write-Host '已自动提交本地新改动' -ForegroundColor Yellow
}

# ---------- 1) 修好网络设置 ----------
# 之前是 sslVerify=false(不校验证书) + postBuffer=500MB, 会被 GitHub 重置连接
git config http.sslVerify true
git config http.version HTTP/1.1
git config http.postBuffer 52428800
git config core.compression 6
Write-Host ''
Write-Host '网络参数已修正: 证书校验开启 / HTTP1.1 / postBuffer 50MB' -ForegroundColor Gray
Write-Host '本次要推送的提交:' -ForegroundColor Gray
git --no-pager log --oneline -1

Write-Host ''
Write-Host '正在推送... 若弹出登录窗口:' -ForegroundColor Yellow
Write-Host '   用户名 = Olivia-1590'
Write-Host '   密码   = Personal Access Token (不是登录密码)' -ForegroundColor Yellow
Write-Host '   Token 生成: https://github.com/settings/tokens  (classic, 勾选 repo)' -ForegroundColor DarkGray

# ---------- 2) 三次尝试, 逐次更保守 ----------
$ok = $false
$plans = @(
  @{ name = '第 1 次: 常规推送';           args = @() },
  @{ name = '第 2 次: 不压缩 + 小分块';    args = @('-c','core.compression=0','-c','http.postBuffer=10485760') },
  @{ name = '第 3 次: 低速容忍更久';       args = @('-c','http.lowSpeedLimit=1000','-c','http.lowSpeedTime=120','-c','http.postBuffer=5242880') }
)
foreach ($p in $plans) {
  Write-Host ''
  Write-Host ('-- ' + $p.name + ' --') -ForegroundColor Cyan
  & git @($p.args) push -u origin main
  if ($LASTEXITCODE -eq 0) { $ok = $true; break }
  Write-Host '这次没成功，换更保守的方式重试…' -ForegroundColor Yellow
  Start-Sleep -Seconds 3
}

Write-Host ''
if ($ok) {
  Write-Host '推送成功！' -ForegroundColor Green
  Write-Host ''
  Write-Host '接下来在网页上开启 Pages (只需一次):' -ForegroundColor Cyan
  Write-Host '   Settings -> Pages -> Source: Deploy from a branch'
  Write-Host '   Branch: main , 目录: / (root) , 点 Save'
  Write-Host ''
  Write-Host '开启后等 1 分钟，游戏网址:' -ForegroundColor Green
  Write-Host $GameUrl -ForegroundColor White
  Write-Host ''
  if ((Read-Host '现在帮你打开 Pages 设置页和仓库页吗? (y/n)') -eq 'y') {
    Start-Process ($Remote + '/settings/pages')
    Start-Sleep -Milliseconds 600
    Start-Process $Remote
  }
  if ((Read-Host '要顺便打开游戏网址看看吗? (y/n)') -eq 'y') { Start-Process $GameUrl }
} else {
  Write-Host '三次都没推上去，多半是到 GitHub 的网络不稳。' -ForegroundColor Red
  Write-Host ''
  Write-Host '可以按顺序试:' -ForegroundColor Yellow
  Write-Host '  1) 挂上代理后重新双击本脚本'
  Write-Host '  2) 换网络(手机热点)再双击本脚本'
  Write-Host '  3) 网页手动传: 仓库页 -> Add file -> Upload files'
  Write-Host '     只传 index.html 和 叠叠乐.html 两个文件就够玩'
  Write-Host '  4) 对我说“出个不带 BGM 的精简版”，首屏只有 600 KB，更好传'
  Write-Host ''
  Write-Host '仓库位置: ' -NoNewline -ForegroundColor DarkGray
  Write-Host $RepoDir -ForegroundColor DarkGray
}
