#!/usr/bin/env bash
# 推送到 GitHub。用法：
#   GITHUB_USER=你的用户名 ./push.sh
# 或者直接把下面 OWNER= 的引号里填上用户名。
set -e
cd "$(dirname "$0")"

OWNER="${GITHUB_USER:-}"

if [ -z "$OWNER" ]; then
  echo "请提供 GitHub 用户名："
  echo "    GITHUB_USER=yourname ./push.sh"
  echo "或把本文件第 8 行改成 OWNER=\"yourname\""
  exit 1
fi

# README 里的占位用户名换成真实用户名
sed -i "s|<你的用户名>|$OWNER|g" README.md

# 提交者身份；想让 commit 关联你的 GitHub 头像，用 GIT_EMAIL 传入账号邮箱
git config user.name  "${GIT_NAME:-$OWNER}"
git config user.email "${GIT_EMAIL:-$OWNER@users.noreply.github.com}"

git add README.md
if ! git diff --cached --quiet; then
  git commit -m "docs: 填写 Pages 在线地址"
fi

git branch -M main
REMOTE="git@github.com:$OWNER/tcamp-vocab.git"
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE"
else
  git remote add origin "$REMOTE"
fi

git push -u origin main

echo
echo "推送完成。"
echo "最后一步：仓库 Settings → Pages → Deploy from a branch → main / (root) → Save"
echo "在线地址： https://$OWNER.github.io/tcamp-vocab/"
