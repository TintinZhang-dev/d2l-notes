# 到时候环境怎么搭?

> **In short:** Three packages are enough. Use a venv, drive it from VSCode, and keep the project inside WSL (`~/`), never `/mnt/c/`.

- **日期:** 2026-10-07
- **章节:** 前置 / 环境准备
- **来源:** 自己想到的实操问题

## 我的问题

> 我到时候的环境怎么搭建?是要把所有这些库全都下载下来吗?python 环境呢,总不能一直 cli 吧,还是得有像 vscode 这样的吧。

## 结论先看

**不用全下。只需要三个包,一条命令。日常也不是 CLI,是 VSCode + notebook。CLI 只在建环境和装包时出现。**

## 一、到底要装多少

书的 PyTorch 版只需要三个包:

```
torch        # PyTorch 本体
torchvision  # 图像工具,书里处理图像数据要用
d2l          # 书的辅助包
```

剩下全是**依赖**,pip 自动带。

```bash
pip install torch torchvision d2l
```

⚠️ 装完约 **2–3 GB**,第一次慢是正常的。

CUDA 方面:PyTorch 自带 runtime,**不用单独装 CUDA Toolkit**。但机器要有驱动。

## 二、Python 环境:虚拟环境必须有

不建虚拟环境 = 所有项目共用一套库 = 迟早互相打架。

```bash
cd ~/d2l-work
python3 -m venv .venv          # 建
source .venv/bin/activate      # 激活(WSL / Linux)
python -m pip install -U pip
pip install torch torchvision d2l
```

Windows 原生激活命令是 `.venv\Scripts\activate`。

**为什么值得**:搞坏了 `rm -rf .venv` 重建就行,系统 Python 毫发无伤。

## 三、IDE:VSCode 就对了

装 VSCode + 两个扩展:

- **Python**(Microsoft)
- **Jupyter**

核心动作**只有一步**:

> Ctrl+Shift+P → `Python: Select Interpreter` → 选中 `.venv` 里的 python

选完就有补全、跳转、变量面板,能直接跑 notebook。

替代品:PyCharm Community(免费)、JupyterLab(浏览器里跑)、Cursor。

**日常长这样**:VSCode 里写 notebook → 点运行 → 看图 → 改。CLI 只在建环境和装包时冒头。

## 四、WSL2 的三个坑

1. **VSCode 装 Windows 版 + WSL 扩展** → 在 WSL 里 `code .` 直接打开,不用维护两套
2. **项目别放 `/mnt/c/`** → 跨文件系统 IO 慢一个数量级。放 WSL 内的 `~/d2l-work/`
3. **`.wslconfig` 限制内存** → WSL2 默认吃内存不归还

## 五、实操清单(新机到手后照做)

脚本见 [`code/setup.sh`](../code/setup.sh)。手动版:

1. WSL2 里装 Ubuntu
2. `sudo apt update && sudo apt install -y python3-venv python3-pip git`
3. `mkdir -p ~/d2l-work && cd ~/d2l-work && python3 -m venv .venv`
4. `source .venv/bin/activate && python -m pip install -U pip`
5. `pip install torch torchvision d2l jupyter`
6. 验证(见下)
7. VSCode 装 WSL + Python + Jupyter 扩展,`code ~/d2l-work`,选解释器

## 六、验证

```bash
python -c "import torch, d2l; print(torch.__version__, torch.cuda.is_available())"
```

期望:版本号 + `True`(有 N 卡且驱动版本够新的话)。

## 七、锁版本

装完存一份,换机器直接复原:

```bash
pip freeze > requirements.txt
# 新机器上
pip install -r requirements.txt
```

## 还没解决的

- 等新机到手实测,补真实命令输出
- Windows 原生 vs WSL2 的最终选择(计划是 WSL2)
