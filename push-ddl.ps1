# 发布 叠叠乐 到 GitHub (仓库 Olivia-1590/1999xran)
# 用法: 在 PowerShell 里执行   & "D:\Software\Dsh\小瑞安侬小游戏\github\push-ddl.ps1"

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

# 1) 确保最新改动都被提交
git add -A | Out-Null
$pending = git status --porcelain
if ($pending) {
  git commit -m 'update ddl: 叠叠乐' | Out-Null
  Write-Host '已自动提交本地新改动' -ForegroundColor Yellow
}

Write-Host ''
Write-Host '本次要推送的提交:' -ForegroundColor Gray
git --no-pager log --oneline -1

# 2) 推送
Write-Host ''
Write-Host '正在推送... 如果弹出登录窗口:' -ForegroundColor Yellow
Write-Host '   用户名 = Olivia-1590'
Write-Host '   密码   = 你的 Personal Access Token (不是登录密码)' -ForegroundColor Yellow
Write-Host '   Token 生成页: https://github.com/settings/tokens  (classic, 勾选 repo)' -ForegroundColor DarkGray
Write-Host ''

git push -u origin main
$code = $LASTEXITCODE

Write-Host ''
if ($code -eq 0) {
  Write-Host '推送成功！' -ForegroundColor Green
  Write-Host ''
  Write-Host '最后一步: 开启 GitHub Pages (只需一次)' -ForegroundColor Cyan
  Write-Host '   1) 打开 Settings -> Pages'
  Write-Host '   2) Source 选 Deploy from a branch'
  Write-Host '   3) Branch 选 main, 目录 / (root), 点 Save'
  Write-Host ''
  Write-Host '开启后等 1 分钟，游戏网址就是:' -ForegroundColor Green
  Write-Host $GameUrl -ForegroundColor White
  Write-Host ''
  $open = Read-Host '现在帮你打开 Pages 设置页和仓库页吗? (y/n)'
  if ($open -eq 'y') {
    Start-Process ($Remote + '/settings/pages')
    Start-Sleep -Milliseconds 600
    Start-Process $Remote
  }
  $open2 = Read-Host '要顺便打开游戏网址看看吗? (y/n)'
  if ($open2 -eq 'y') { Start-Process $GameUrl }
} else {
  Write-Host ('推送失败 (退出码 ' + $code + ')') -ForegroundColor Red
  Write-Host ''
  Write-Host '常见原因:' -ForegroundColor Yellow
  Write-Host '   1) 没有输 Token，或 Token 没有勾选 repo 权限'
  Write-Host '   2) 网络无法访问 github.com'
  Write-Host '   3) 远程有新提交(网页上改过文件): 先执行 git pull --rebase origin main 再重试'
  Write-Host ''
  Write-Host '手动重试命令:  cd D:\Software\Dsh\小瑞安侬小游戏\github ; git push -u origin main' -ForegroundColor DarkGray
}
