# 行的和 ≠ 矩阵乘向量：还有 1 维与 2 维的坑

> **In short:** `A.sum(axis=1)` adds each row's elements; `A @ x` takes a dot product of each row with x. Both give length m, but PyTorch returns shape `(m,)`, not `(m, 1)` — use `keepdim=True` for a real column.

- **日期:** 2026-10-17
- **章节:** 2.3.6 降维 / 2.3.8 矩阵-向量积
- **来源:** 把两件事当成了一件

## 我的问题

2.3.8 里「行向量就是每一行的和组成的一列」吗？

## 想通了

**不是一回事。**

```
A = [[1, 2, 3],      x = [1, 10, 100]
     [4, 5, 6]]

A.sum(axis=1)  →  [1+2+3, 4+5+6]                    = [6, 15]
A @ x          →  [1*1+2*10+3*100, 4*1+5*10+6*100] = [321, 654]
```

- 求和：把元素加起来
- 点积：**先用 x 给每一列加权，再加**

### ⚠️ 形状陷阱

数学上写成一列，PyTorch 里却是**一维**：

```python
A.sum(axis=1).shape                  # torch.Size([2])     ← 不是 [2,1]
torch.matmul(A, x).shape             # torch.Size([2])
A.sum(axis=1, keepdim=True).shape    # torch.Size([2,1])   ← 真列向量
```

后面做广播、`cat`、拼接时，`[2]` 会被当成**行**，`[2,1]` 才是**列**。很多「维度对不上」的报错都出在这里。

## 代码验证

```python
import torch
A = torch.tensor([[1., 2., 3.], [4., 5., 6.]])
x = torch.tensor([1., 10., 100.])
A.sum(axis=1)                       # tensor([  6.,  15.])
torch.matmul(A, x)                  # tensor([321., 654.])
A.sum(axis=1, keepdim=True).shape   # torch.Size([2, 1])
```

## 还没解决的

- `axis=0` 的结果长度是多少？（答案：n，按列求和）
