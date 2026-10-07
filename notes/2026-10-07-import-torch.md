# 书里为什么没有 `import PyTorch`?

> **In short:** The import name is `torch`, not `PyTorch`. A pip distribution name and its import name do not have to match.

- **日期:** 2026-10-07
- **章节:** 前置 / 环境准备
- **来源:** 翻书时发现的疑点

## 我的问题

> 我在书中没看到过 import PyTorch 这样的语句。

## 第一反应

是不是书里用了别的方式引入?还是我漏看了?

## 卡在哪

把**项目名**当成了**包名**。PyTorch 是品牌名,不是能 import 的东西。

## 想通了

**PyTorch 的导入名是 `torch`,不是 `PyTorch`。**

书里其实到处都是,长这样:

```python
import torch
from d2l import torch as d2l
```

第二行值得单独说:`d2l` 是书作者写的辅助包,它把 torch / numpy / matplotlib **重导出**了一遍,还附赠绘图函数。所以书里写 `d2l.plt`、`d2l.numpy`。

### 这是一整类坑:pip 名 ≠ import 名

| 安装 | 导入 |
| --- | --- |
| `pip install torch` | `import torch` |
| `pip install d2l` | `from d2l import torch as d2l` |
| `pip install opencv-python` | `import cv2` |
| `pip install scikit-learn` | `import sklearn` |
| `pip install pillow` | `import PIL` |

记法:**pip 装的是分发名(distribution name),import 用的是导入名(import name),两者不保证一致。**

### 为什么叫 torch

PyTorch 是从 Lua 的老框架 **Torch** 演化来的,命名空间继承了 `torch`。所以 `torch` 和 PyTorch 指的是同一个东西,只是一个是包名、一个是项目名。

## 代码验证

```python
import torch
print(torch.__name__)   # torch
print(torch.__file__)   # 装在哪个虚拟环境里
```

## 还没解决的

无。
