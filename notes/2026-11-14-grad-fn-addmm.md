> **In short:** `grad_fn` records which operation produced a tensor; backward walks that chain. `AddmmBackward` appears because `nn.Linear` fuses `x @ W.T + b` into one `addmm` call, and that is the last operation before the output.

- **日期:** 2026-11-14
- **章节:** 5.1 层和块
- **来源:** 看书

## 我的问题

5.1 第一个例子的输出后面跟着：

```
grad_fn=<AddmmBackward0>
```

这是什么？为什么不是别的名字？

## 第一反应

以为是报错或者警告，想关掉。

## 卡在哪

不知道它在说什么，也不知道有没有用。

## 想通了

### 1. 那行代码

```python
net = nn.Sequential(nn.Linear(20, 256), nn.ReLU(), nn.Linear(256, 10))
X = torch.rand(2, 20)
net(X)
```

输出：

```
tensor([[-0.0563, -0.0339, 0.0635, ..., -0.0023, 0.0284, -0.1036],
        [-0.0159, -0.0474, 0.0031, ..., 0.0321, 0.0353, -0.1292]],
       grad_fn=<AddmmBackward0>)
```

### 2. grad_fn 是“出身记录”

每个张量可以带一个 `grad_fn`，记录“我是由哪个运算算出来的”。

反向传播时，就从输出出发，顺着 `grad_fn` 一路往回走，把梯度算到每个参数上。

没有 `grad_fn`，就没有反向传播。

### 3. 为什么叫 Addmm

`nn.Linear` 内部做的事是：

```
y = x @ W.T + b
```

PyTorch 把“矩阵乘 + 加偏置”融合成一个底层算子 `addmm`（add matrix multiply）。

网络最后一步就是第二个 `nn.Linear`，所以输出张量的 `grad_fn` 是 `AddmmBackward`。

后面那个 `0` 是版本编号，表示这个反向节点在同类型里是第几个，不影响理解。

### 4. 完整的链条

```
输出
 AddmmBackward      <- 第二个 Linear
  ReluBackward      <- ReLU
   AddmmBackward    <- 第一个 Linear
    AccumulateGrad  <- 权重（叶子张量）
```

训练时 `loss.backward()` 就是沿这条链反向走一遍。

### 5. 为什么 X 不需要梯度，输出却有 grad_fn

`X = torch.rand(2, 20)` 默认 `requires_grad=False`。

但 `nn.Linear` 的权重是 `Parameter`，`requires_grad=True`。

只要链上有一个需要梯度的东西，输出就会带上 `grad_fn`。

### 6. 什么时候没有 grad_fn

- 叶子张量：`X.grad_fn` 是 `None`
- 用了 `.detach()`
- 在 `with torch.no_grad():` 里算出来的

这就是为什么画图时要 `.detach().numpy()`——matplotlib 不需要计算图，也不认。

## 代码验证

```python
import torch

x = torch.ones(2, 3, requires_grad=True)
print('x.grad_fn      =', x.grad_fn)        # None
print('x.is_leaf      =', x.is_leaf)        # True

y = x * 2
print('y.grad_fn      =', y.grad_fn)        # MulBackward0

z = y + 1
print('z.grad_fn      =', z.grad_fn)        # AddBackward0
print('z 的上游       =', z.grad_fn.next_functions)

print('detach 之后     =', z.detach().grad_fn)   # None
```

## 一句话

`grad_fn` 是张量随身带的“我是怎么算出来的”标签。`AddmmBackward` 只是说：最后一次运算是矩阵乘加偏置。

