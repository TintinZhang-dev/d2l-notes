# z.sum().backward() 是什么意思?

> **In short:** `backward()` needs a scalar, so `.sum()` hands it a seed vector of all ones. It is exactly `z.backward(torch.ones_like(z))`.

- **日期:** 2026-10-07
- **章节:** 2.5.3 分离计算(自动微分)
- **来源:** 看书卡住

## 我的问题

> 2.5.3 没看懂。`z.sum().backward` 这个命令不理解。

## 卡在哪

`.sum()` 看起来就是个无关紧要的加法。求导就求导,为什么先把 z 加起来?

## 想通了

### 一句话:backward() 只吃标量

**梯度是「标量对向量的导数」。输出必须是标量。**

如果输出是向量 y,那 ∂y/∂x 是个**矩阵**(雅可比矩阵),不是向量。PyTorch 不直接算矩阵,它算的是**向量-雅可比乘积**:

$$v^\top \frac{\partial y}{\partial x}$$

所以你得给它一个「种子向量」v。

**`.sum()` = 种子向量取全 1。**

### 最直观的等价写法

```python
z.sum().backward()
# 完全等价于
z.backward(torch.ones_like(z))
```

书里 2.5.2 自己写得很清楚:

> 对非标量调用 backward 需要传入一个 gradient 参数……本例只想求偏导数的和,所以传递一个 1 的梯度是合适的

### 数学上发生了什么

z = u * x,逐元素相乘,所以 z_i = u_i · x_i。

$$\sum_i z_i = \sum_i u_i x_i$$

$$\frac{\partial \sum_i z_i}{\partial x_j} = u_j$$

因为求和式里,只有 i = j 那一项含 x_j。

所以 `x.grad == u` ✓

### sum() 不是唯一选法

| 写法 | 等价于种子向量 |
| --- | --- |
| `z.sum().backward()` | 全 1 |
| `z.mean().backward()` | 全 1/n |
| `z.backward(torch.ones_like(z))` | 全 1 |
| `z.backward(torch.tensor([0., 1., 0., 0.]))` | 只留第 1 项 |

核心只有一件事:**先把输出变成标量。**

## 顺带两个坑

1. **`.grad` 是累加的,不是覆盖** → 所以书里反复写 `x.grad.zero_()`
2. **detach 才是 2.5.3 的主线**:`u = y.detach()` 让 y 断掉梯度、当常数处理。所以对 x 求导得到 u,而不是 2x。最后一段不 detach 的版本得到的就是 `2*x`

## 代码验证

```python
import torch

x = torch.arange(4.0, requires_grad=True)   # [0, 1, 2, 3]
y = x * x
u = y.detach()
z = u * x

# 写法 1:书里的
x.grad = None
z.sum().backward()
print(x.grad)     # tensor([0., 1., 4., 9.])  == u

# 写法 2:显式传种子向量,结果一样
x.grad = None
z.backward(torch.ones_like(z))
print(x.grad)     # tensor([0., 1., 4., 9.])

# 写法 3:种子只留第 1 项
x.grad = None
z.backward(torch.tensor([0., 1., 0., 0.]))
print(x.grad)     # tensor([0., 1., 0., 0.])  ← 只收到 z[1] 的贡献

# 对比:不 detach
x.grad = None
y.sum().backward()
print(x.grad)     # tensor([0., 2., 4., 6.])  == 2*x
```

## 还没解决的

无。
