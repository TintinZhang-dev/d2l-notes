# import d2l 之后,math / torch 还需要导入吗?

> **In short:** `import d2l` and `from d2l import torch as d2l` are different statements, and imports live in one file's namespace only.

- **日期:** 2026-10-07
- **章节:** 前置 / 环境准备
- **来源:** 接着上一条问题

## 我的问题

> 那也就是说,我 import d2l 之后,math、os、torch 都不需要导入了?但我看书中还是多次导入 math、torch。

## 卡在哪

两个误解:一是把 `import d2l` 和书里的写法当成同一件事;二是以为 import 是「全局生效」的开关。

## 想通了

### 一、书里从来不是 `import d2l`

书里写的是:

```python
from d2l import torch as d2l
```

两个**完全不同**的语句:

| 写法 | 拿到什么 |
| --- | --- |
| `import d2l` | 一个空壳包。`d2l/__init__.py` 里除了注释,只有一行 `__version__ = "2.0.0"` |
| `from d2l import torch as d2l` | 子模块 `d2l/torch.py`,并把它绑到名字 `d2l` |

### 二、那个子模块自己导了一堆东西

实测 `d2l/torch.py` 开头:

```python
import math
import os
import torch
import numpy as np
from matplotlib import pyplot as plt
```

模块级的 import 把名字绑在**那个模块自己的命名空间**里。所以技术上:

```python
d2l.math.pi        # 能用
d2l.os.path        # 能用
d2l.torch.tensor   # 能用(注意是 d2l.torch,不是 torch)
d2l.np.array       # 能用
d2l.plt.plot       # 能用 ← 书里最常见的就是这个
```

### 三、但它管不到你自己的文件

```python
from d2l import torch as d2l

print(math.pi)              # ❌ NameError
print(torch.tensor([1, 2])) # ❌ NameError
print(d2l.math.pi)          # ✅ 必须带前缀
```

**import 的作用域是「文件」,不是全局开关。** d2l 里 import 了 torch,不等于你的文件里也有 `torch` 这个名字。

### 四、这是副作用,不是设计意图

d2l 只承诺给你 `d2l.Timer`、`d2l.plot`、`d2l.synthetic_data` 这类书的辅助函数。`d2l.math` 能用纯属巧合,**别依赖**。

### 那书里为什么还反复导入?

1. **每章 notebook 独立可跑** — 单独打开某一章就能运行,不依赖前面章节的状态,所以每章都带完整导入
2. **可读性** — `d2l.math.pi` 比 `math.pi` 啰嗦,作者宁可多写一行 import
3. `d2l.torch.xxx` 也少见,书里一般直接 `import torch` 然后写 `torch.tensor`

## 代码验证

```python
from d2l import torch as d2l

print(type(d2l))    # <class 'module'> → 就是 d2l/torch.py
print(d2l.__name__) # d2l.torch
print(d2l.math.pi)  # 3.141592653589793
print(d2l.torch is __import__("torch"))  # True
```

## 还没解决的

无。
