> **In short:** `reduction` decides how the per-element losses are combined. `'mean'` averages them into a scalar, `'sum'` adds them, `'none'` leaves the tensor as-is so the caller can accumulate correctly over batches of different sizes.

- **日期:** 2026-11-14
- **章节:** 4.4 模型选择 / 4.5 权重衰减
- **来源:** 看书 + 查源码

## 我的问题

`loss = nn.MSELoss(reduction='none')` 什么意思？

## 第一反应

以为 `none` 是“不做损失”，或者“关掉”。

## 卡在哪

不知道它和默认值差在哪。

## 想通了

### 1. reduction 是“怎么合并”

MSE 对每个元素算平方差，得到一个和输入同形状的张量。

`reduction` 决定接下来怎么把它变成一个数：

| 取值 | 输出 | 形状 |
| --- | --- | --- |
| `'mean'`（默认） | 所有元素平均 | 标量 |
| `'sum'` | 所有元素相加 | 标量 |
| `'none'` | 不合并 | 和输入一样 |

举例，预测和真实差 `[1, 2, 3]`：

```
'none' → tensor([1., 4., 9.])
'sum'  → tensor(14.)
'mean' → tensor(4.6667)
```

### 2. 书里为什么用 none

看 4.4 的 `evaluate_loss`：

```python
def evaluate_loss(net, data_iter, loss):
    metric = d2l.Accumulator(2)          # 损失总和, 样本数
    for X, y in data_iter:
        out = net(X)
        y = y.reshape(out.shape)
        l = loss(out, y)
        metric.add(l.sum(), l.numel())
    return metric[0] / metric[1]
```

它要的是：

1. 每一批的损失**总和**（`l.sum()`）
2. 每一批的**元素个数**（`l.numel()`）

最后用总和除以总个数，得到整个数据集上的平均损失。

如果 `reduction='mean'`，每批已经除过一次批量大小，再除就错了。

### 3. 不用 none 会错在哪

假设两个批次：一批 10 个，一批 3 个。

`reduction='mean'` 时，两批各得到一个平均值。若直接再平均，等于给 3 个样本的批次和 10 个样本的批次一样的权重。

真实平均应该是：

```
(10 个的总和 + 3 个的总和) / 13
```

不是：

```
(10 个的平均 + 3 个的平均) / 2
```

批次大小不一致时（比如最后一批不满），这两种算法差别明显。

用 `'none'` 自己累加总和与个数，就不会有这个问题。

### 4. 训练时用哪个

- 训练：跟着框架走，用默认 `'mean'` 最省事
- 自己统计指标：用 `'none'`，自己 sum 和 count

### 5. 别和“关掉损失”混淆

`reduction='none'` 不是不计算损失。它照样算，只是不算总账。

## 代码验证

```python
import torch
import torch.nn as nn

pred = torch.tensor([[1.0], [2.0], [3.0]])
true = torch.tensor([[0.0], [0.0], [0.0]])

for r in ('none', 'sum', 'mean'):
    print(r, nn.MSELoss(reduction=r)(pred, true))
```

输出：

```
none tensor([[1.], [4.], [9.]])
sum  tensor(14.)
mean tensor(4.6667)
```

## 一句话

`reduction` 管的是“要不要替你合并成一个数”。`'none'` 说的是：别合并，我自己来。

