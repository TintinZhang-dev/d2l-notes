# PyTorch 是 Python 的插件,还是一套独立环境?

- **日期:** 2026-10-07
- **章节:** 前置 / 环境准备(第 0 章)
- **来源:** 自学中冒出的问题,关系到之后买电脑

## 我的问题

> PyTorch 是否可以理解为基于 Python 的一种开发框架?它的环境是类似 Python 的一个插件,还是一套独立的环境?

主要和之后要买电脑有关,想落到代码层、实现层的环境配置上看。

## 提问里的假设

「插件」还是「独立环境」——两个都不太准,但更接近前者。

## 卡在哪

- 「环境」这个词被混用了三次:Python 解释器本身 / 虚拟环境 / PyTorch 包
- 搞不清 CUDA 到底该谁装,是系统装的还是 PyTorch 带的

## 想通了

**PyTorch 就是一个 Python 包(package)。** 不是独立环境,是装在某一个 Python 环境里的库。

三层拆开看:

| 层 | 是什么 | 谁提供 |
| --- | --- | --- |
| Python 解释器 | 跑代码的本体 | 系统 / pyenv / conda |
| 虚拟环境 | 隔离出来的 site-packages 目录 | venv / conda / uv |
| PyTorch | 装进某个虚拟环境的包 | pip / conda |

类比:Python 是手机系统,虚拟环境是 App 沙盒,PyTorch 是沙盒里最重的那个 App。它自己还捎带一个 2–3 GB 的「驱动包」(CUDA runtime)。

**为什么会有「独立环境」的错觉**:conda 习惯把 python 和 torch 一起装,一次装出整套,看起来像独立环境。其实是 conda 帮你装了两个包。

### 最容易踩的坑:CPU 版 vs CUDA 版

- pip 装的 PyTorch **自带 CUDA runtime**,不需要单独装 CUDA Toolkit
- 但机器上**必须有 NVIDIA 驱动**,版本还要够新
- 系统级 CUDA Toolkit 只有自己编译算子时才用得上
- 装错构建 → `torch.cuda.is_available()` 永远是 False,容易误判成驱动问题

## 代码验证

```python
import torch

print(torch.__version__)          # 装到的版本,写这条时最新是 2.14.1
print(torch.cuda.is_available())  # True 才算显卡真跑通
print(torch.version.cuda)         # PyTorch 编译时绑定的 CUDA 版本
if torch.cuda.is_available():
    print(torch.cuda.get_device_name(0))
```

命令行侧:

```bash
nvidia-smi               # 看驱动版本 + 显存
python -m venv .venv     # 建虚拟环境
```

当前稳定版要求 **Python >= 3.10**。

## 买电脑的落点

- **NVIDIA 独显是硬门槛**,显存比算力重要
- d2l 书里的模型很小,4 GB 显存能跑完全书
- 要碰真实模型(微调 / diffusion / LLM):12 GB 起步,16–24 GB 舒服
- 台式机 >> 笔记本,同价钱显存翻倍
- 内存 32 GB+,SSD 1 TB+(数据集很占地方)
- 苹果 M 系:MPS 后端能跑,但 CUDA-only 的代码会踩坑
- 手头这台(Windows + WSL2)`nvidia-smi` 找不到 → 目前没有可用的 NVIDIA 显卡

## 还没解决的

买什么机器、什么时候买,待定。
