> **In short:** `net` is not from torch. It is a plain Python function the book defines as `linreg`, then aliases with `net = linreg` right before the training loop, so that 3.2 and 3.3 can share the same loop code.

- **日期:** 2026-11-14
- **章节:** 3.2.4 定义模型 / 3.2.7 训练
- **来源:** 看书 + 查源码

## 我的问题

`l = loss(net(X, w, b), y)` 里的 `net()` 是 torch 提供的吗？

## 第一反应

看名字像框架里的东西，毕竟 `torch.` 开头的一大堆。

## 卡在哪

全文没有 `import net`，也没见它被定义。

## 想通了

### 1. 它是书里自己定义的

3.2.4 定义模型那一节：

```python
def linreg(X, w, b):  #@save
    """线性回归模型"""
    return d2l.matmul(X, w) + b
```

就一行：矩阵乘加偏置。

### 2. net 只是个别名

3.2.7 训练之前：

```python
lr = 0.03
num_epochs = 3
net = linreg
loss = squared_loss
```

Python 里函数是对象，可以赋给变量。所以：

```python
net(X, w, b)      # 等价于
linreg(X, w, b)   # 等价于
d2l.matmul(X, w) + b
```

### 3. 为什么要起这个别名

为了 3.3。

3.2 是手写模型，3.3 换成框架的 `nn.Sequential`。两节的训练循环一个字都不用改，因为都叫 `net`、都叫 `loss`。

```python
# 3.2
net = linreg

# 3.3
net = nn.Sequential(nn.Linear(2, 1))
```

### 4. 所以那行代码展开是

```python
l = loss(net(X, w, b), y)
```

等于：

```python
y_hat = torch.matmul(X, w) + b
l = squared_loss(y_hat, y)
```

先算预测，再算平方损失。没有隐藏的魔法。

### 5. loss 同理

`loss = squared_loss` 也是别名，指向 3.2.5 定义的函数：

```python
def squared_loss(y_hat, y):
    return (y_hat - y.reshape(y_hat.shape)) ** 2 / 2
```

## 代码验证

```python
import torch

def linreg(X, w, b):
    return torch.matmul(X, w) + b

net = linreg

X = torch.ones(3, 2)
w = torch.tensor([[2.0], [-3.4]])
b = torch.tensor([4.2])

print(net(X, w, b))
print(linreg(X, w, b))   # 完全一样
print(net is linreg)     # True
```

## 还没解决的

3.3 的 `nn.Sequential` 也是可调用的，调用时只传 X，不传 w、b——参数藏在模块里。这个差异到时候再看。
