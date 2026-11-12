#!/usr/bin/env bash
# TCAMP 一键推送：在 Git Bash 里运行  ./push.sh
set -euo pipefail
cd "$(dirname "$0")"

REPO="tcamp-vocab"
PUBKEY="$HOME/.ssh/id_ed25519_tcamp.pub"

echo "=== TCAMP 一键推送 ==="
read -rp "GitHub 用户名: " GH_USER
if [ -z "$GH_USER" ]; then
  echo "用户名不能为空。"; exit 1
fi

# 主文件改过就同步 Pages 入口
if [ -f "背单词.html" ]; then
  cp "背单词.html" index.html
  echo "[ok] index.html 已同步"
fi

echo
echo "--- 检查 SSH 认证（走 ssh.github.com:443）---"
AUTH="$(ssh -o BatchMode=yes -o ConnectTimeout=15 -T git@github.com 2>&1 || true)"
echo "$AUTH"
if ! echo "$AUTH" | grep -q "successfully authenticated"; then
  echo
  echo "认证没通过。请把下面这把公钥添加到 GitHub → Settings → SSH and GPG keys → New SSH key："
  echo
  if [ -f "$PUBKEY" ]; then cat "$PUBKEY"; else echo "（找不到 $PUBKEY）"; fi
  echo
  echo "加好之后重新运行 ./push.sh"
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "当前目录不是 git 仓库。"; exit 1
fi

if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
  echo "还没设置 git 提交身份，请先运行："
  echo "  git config user.name  \"你的名字\""
  echo "  git config user.email \"你的邮箱\""
  exit 1
fi

git add -A
if ! git diff --cached --quiet; then
  git commit -m "Update TCAMP vocabulary app"
  echo "[ok] 已提交本次改动"
else
  echo "[ok] 没有新改动，直接推送"
fi

git branch -M main
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "git@github.com:$GH_USER/$REPO.git"
else
  git remote add origin "git@github.com:$GH_USER/$REPO.git"
fi

echo
echo "--- 推送到 origin/main ---"
git push -u origin main

echo
echo "仓库： https://github.com/$GH_USER/$REPO"
echo "Pages：https://$GH_USER.github.io/$REPO/"
echo "首次部署请在 Settings → Pages → Source 选择 GitHub Actions。"
