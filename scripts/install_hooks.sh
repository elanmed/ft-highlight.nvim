#!/bin/bash
cd "$(git rev-parse --show-toplevel)" || exit 1
git config core.hooksPath scripts || exit 1
chmod +x scripts/pre-push || exit 1
echo "pre-push hook installed via core.hooksPath"
