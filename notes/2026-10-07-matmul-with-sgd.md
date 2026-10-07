# torch.matmul()、with 语句、sgd()

> **In short:** `torch.matmul` / `@` is matrix multiplication (`*` is element-wise); `with torch.no_grad()` stops graph recording; `sgd` is `param -= lr * grad / batch_size`.

- **日期:** 2026-10-07
- **章节:** 3.2 从零开始实现
- **来源:** 三个没看懂的写法

## 一、torch.matmul():矩阵乘法

```python
X = torch.randn(10, 2)              # 10 个样本 × 2 个特征
w = torch.tensor([[2.0], [-3.4]])   # 2 × 1
torch.matmul(X, w)                  # → (10, 1)
```

形状规则:$(m, n) \times (n, p) \to (m, p)$,中间那个 n 必须对上。

### ⚠️ 最容易混的三个写法

| 写法 | 意思 |
| --- | --- |
| `A * B` | **逐元素**相乘,形状要能对上 |
| `A @ B` | 矩阵乘法,等价 `torch.matmul(A, B)` |
| `A.matmul(B)` | 同上,方法写法 |

**`*` 和 `@` 完全是两回事。** 这是 PyTorch 里最高频的困惑点。

### 相关 API

| API | 说明 |
| --- | --- |
| `torch.matmul(A, B)` | 通用,支持批量 / 高维,会广播 |
| `torch.mm(A, B)` | 只支持 2D |
| 一维 × 一维 | 点积,返回标量 |

## 二、with 语句:Python 的「离开时自动收尾」

最熟的例子是开文件:

```python
with open("f.txt") as f:
    data = f.read()
# 出了缩进块,文件自动关
```

**机制**:进入时设置某个状态,退出时自动恢复——**哪怕中间报错也会恢复**。

### 在 PyTorch 里

```python
with torch.no_grad():      # 临时关掉梯度记录
    ...

with torch.enable_grad():  # 再打开
    ...
```

梯度记录是个**全局开关**。你只想在一段代码里关掉,出来还要恢复。`with` 保证这件事一定发生。

同类:`with torch.autocast(...)`(混合精度)。

## 三、sgd()

书里原代码:

```python
def sgd(params, lr, batch_size):  #@save
    """小批量随机梯度下降"""
    with torch.no_grad():
        for param in params:
            param -= lr * param.grad / batch_size
            param.grad.zero_()
```

**核心就一行:参数 ← 参数 − 学习率 × 梯度**

### 1. 为什么要 `/ batch_size`

`l = loss(...)` 是 batch 里所有样本损失的**和**(因为前面 `.sum()` 过)。要还原成平均,就除以 batch_size。

**`.sum()` 留下的账,在这里还上。** 两处是配套的。

### 2. 为什么要 `with torch.no_grad()`

更新参数是「改数据」,不是「算梯度」。

不加的话,PyTorch 会把这一步也记进计算图 → 每轮图都变长 → **内存爆炸**。

### 3. 为什么要 `param.grad.zero_()`

梯度是**累加**的。不清零,下一轮的 grad 会叠上这一轮。

### 4. 为什么用 `-=` 而不是 `param = param - ...`

`-=` 是**原地修改**。换成 `param = param - ...`,只是让局部变量指向新张量,外面 `params` 列表里那个还是旧的 → **参数根本没更新**。

这是从零实现里最容易被忽略的坑。

### 5. 对比 3.3

`trainer.step()` / `optimizer.step()` 干的事,就是这四行。只是封装成类,加了 momentum、weight decay 之类的选项。

## 代码验证

```python
import torch

# matmul vs *
A = torch.tensor([[1., 2.], [3., 4.]])
B = torch.tensor([[1.], [10.]])

print(A * B)          # 逐元素,广播成 2×2
# tensor([[ 1.,  2.], [30., 40.]])
print(A @ B)          # 矩阵乘
# tensor([[21.], [43.]])
```

```python
# 梯度不清零会怎样
x = torch.tensor([1.0, 2.0], requires_grad=True)

(x * x).sum().backward()
print(x.grad)          # tensor([2., 4.])

(x * x).sum().backward()   # 忘了清零
print(x.grad)          # tensor([4., 8.]) ← 叠上去了!

x.grad.zero_()
(x * x).sum().backward()
print(x.grad)          # tensor([2., 4.]) ← 清零后正常
```

## 还没解决的

无。
