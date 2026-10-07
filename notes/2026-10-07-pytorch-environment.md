# PyTorch 是 Python 的插件,还是一套独立环境?

> **In short:** PyTorch is a Python *package*, not a separate environment: one interpreter, many virtualenvs, and the package sitting inside one of them.

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

## 买电脑的落点(对齐已有计划)

计划在 `projects/pc-build/`:双十一装机,目标 **RTX 5060 Ti 16GB**。

- **NVIDIA 独显是硬门槛**,选卡优先级:**显存 > 显存带宽 > 算力**
- d2l 书里的模型很小,4 GB 显存就能跑完全书——但那是「最低能跑」,不是「该买」
- 计划里 **16 GB 是质变门槛**:CNN 训练 + 本地 14B 级 LLM 一次满足
- 内存 32 GB 起(64 GB 更稳),1 TB NVMe——模型文件很大
- Windows 11 + WSL2 **支持 NVIDIA GPU 直通** → CUDA/PyTorch 不用双系统
- 手头这台(HP AiO,i5-8500T + Radeon 535)`nvidia-smi` 找不到 → 和计划里「暂无可用 N 卡」一致

**和这条问题的真正交集**:机器买回来只是第一步。PyTorch 装错构建、或驱动不够新,`torch.cuda.is_available()` 照样是 False。显卡是硬件,环境是软件,两边都得对。

## 还没解决的

- 双十一最终配置单:等 10/28 自动核价(10 月显卡涨了 45–75%,未必更便宜)
- 新机到手后的环境搭建步骤,到时单独记一条
