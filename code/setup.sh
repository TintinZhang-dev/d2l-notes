#!/usr/bin/env bash
# d2l 学习环境搭建(WSL2 / Ubuntu)
# 用途:新机到手后照着跑。建议逐步执行,别整个糊上去。
# 说明:第 1 步需要 sudo;其余都在用户目录里,不碰系统 Python。

set -e

# 1. 系统依赖(需要 sudo)
sudo apt update
sudo apt install -y python3-venv python3-pip git

# 2. 建工作目录 + 虚拟环境
mkdir -p ~/d2l-work
cd ~/d2l-work
python3 -m venv .venv

# 3. 激活并升级 pip
source .venv/bin/activate
python -m pip install -U pip

# 4. 装书需要的三个包(torch 约 2-3 GB,耐心等)
pip install torch torchvision d2l

# 5. 装 Jupyter(想在 VSCode 里跑 notebook 就装)
pip install jupyter

# 6. 验证
python -c "import torch, d2l; print('torch', torch.__version__, '| CUDA:', torch.cuda.is_available())"

# 7. 锁版本
pip freeze > requirements.txt

echo "完成。下一步:VSCode 装 WSL + Python + Jupyter 扩展,然后 code ~/d2l-work"
