# from ... import ... 是什么意思?

- **日期:** 2026-10-07
- **章节:** 前置 / 环境准备
- **来源:** 接着 import 那两条问题

## 我的问题

> from...import...又是什么意思。比如 from torch import nn。但明明已经有过 import torch 了,这句语句直观理解不就是从 torch 里导入什么吗,为什么要重复导入?

## 卡在哪

把 `import` 当成「一次性加载模块」。其实它同时还负责「在你的命名空间里起名字」。

## 想通了

### import 其实干两件事

1. **加载模块**(从磁盘取,或直接从缓存拿)
2. **在你的命名空间里绑定一个名字**

第 1 步全局只做一次,Python 缓存在 `sys.modules` 里。第 2 步**每个文件都得自己写**,因为命名空间是每个文件自己的。

所以「重复导入」是错觉:**模块没被重新加载,只是多绑了一个名字。**

### 几种写法的差别

| 语句 | 绑定了什么名字 | 之后怎么写 |
| --- | --- | --- |
| `import torch` | `torch` | `torch.nn.Linear(...)` |
| `import torch.nn` | `torch`(顺带加载 torch.nn) | `torch.nn.Linear(...)` |
| `import torch.nn as nn` | `nn` | `nn.Linear(...)` |
| `from torch import nn` | `nn` | `nn.Linear(...)` |
| `from torch.nn import Linear` | `Linear` | `Linear(...)` |

后三种拿到的是**同一个对象**,只是绑的名字不同。

### 「从 torch 里导入 nn」——对,就是这个意思

`nn` 是 `torch` 模块的一个**属性**,而它本身是个**模块对象**(`torch/nn/__init__.py`)。

```python
import torch
from torch import nn

print(nn.__name__)     # 'torch.nn'
print(torch.nn is nn)  # True ← 同一个对象
```

### 书里为什么写两行

```python
import torch
from torch import nn
from torch.nn import functional as F
```

三行给了三个名字,代码里三种写法都在用:

- `torch.tensor(...)` / `torch.zeros(...)`
- `nn.Linear(...)` / `nn.Sequential(...)`
- `F.relu(...)`

只写 `import torch` 也能跑,只是得写成 `torch.nn.Linear`、`torch.nn.functional.relu`——啰嗦。

**`as` 的作用**:只是给绑定的名字换个名。`import numpy as np` = 把 numpy 绑成 `np`。

## 代码验证

```python
import sys
import torch
from torch import nn
import torch.nn as nn2

print(sys.modules["torch.nn"] is nn)   # True
print(nn is nn2)                       # True
print(torch.nn.Linear is nn.Linear)    # True
```

## 还没解决的

无。
