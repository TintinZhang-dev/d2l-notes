> **In short:** `TensorDataset` packs aligned tensors into one indexable dataset; `DataLoader` wraps any dataset and hands out batches. `next(iter(loader))` gets the first batch because the loader is iterable, not itself an iterator — `iter()` creates a fresh iterator each call.

- **日期:** 2026-11-14
- **章节:** 3.3.2 读取数据集
- **来源:** 看书

## 我的问题

3.3 的 `data.TensorDataset`、`DataLoader`、`next()` 分别是什么？为什么写 `next(iter(...))`？

## 第一反应

三个名字都是框架的，看不出分工。

## 卡在哪

`next` 为什么要套一层 `iter`？直接 `next(data_iter)` 不行吗？

## 想通了

### 0. 代码原文

```python
from torch.utils import data

def load_array(data_arrays, batch_size, is_train=True):
    dataset = data.TensorDataset(*data_arrays)
    return data.DataLoader(dataset, batch_size, shuffle=is_train)

data_iter = load_array((features, labels), batch_size)
next(iter(data_iter))
```

### 1. TensorDataset：把几个张量按第一维绑在一起

```python
dataset = data.TensorDataset(features, labels)
```

它做的事很简单：

```python
len(dataset)      # 1000，等于 features 的行数
dataset[0]        # (features[0], labels[0])
dataset[7]        # (features[7], labels[7])
```

它有 `__len__` 和 `__getitem__`，所以叫“数据集”。

它不复制数据，只是记住几个张量的引用。取单个样本走的是基础索引，拿到的是视图。

### 2. DataLoader：给任何数据集套一层“按批取”

```python
loader = data.DataLoader(dataset, batch_size=10, shuffle=True)
```

它的活：

- 一批取 10 个
- `shuffle=True` 每次开始迭代都重新打乱
- 默认把 10 个样本 stack 成一个 (10, 2) 和 (10, 1) 的张量
- 还能开多进程 `num_workers=4` 并行读

它只要求输入对象有 `__len__` 和 `__getitem__`。所以 TensorDataset 能用，自己写的类也能用。

### 3. next 和 iter：为什么不能直接 next(loader)

```python
next(data_iter)   # TypeError: 'DataLoader' object is not an iterator
```

区别在协议：

- **iterable**：有 `__iter__`，能被 for 遍历。DataLoader 是这种。
- **iterator**：有 `__next__`，能被 `next()` 取下一个。需要 `iter()` 造出来。

```python
it = iter(data_iter)   # 造一个迭代器
next(it)               # 取第一批
next(it)               # 取第二批
```

`next(iter(data_iter))` 就是“造迭代器，然后取第一个”。

而 `for X, y in data_iter` 背后自动做了 `iter()`，所以平时不用写。

### 4. 每次 iter() 都从头开始

```python
it1 = iter(loader)
next(it1)      # 第一批
it2 = iter(loader)
next(it2)      # 又是第一批（而且 shuffle 重新洗过）
```

所以每个 epoch 的 for 循环都是新的顺序。这跟 3.2 手写生成器每次调用重建是同一个道理。

### 5. 和 3.2 手写版对照

| 3.2 手写 | 3.3 DataLoader |
| --- | --- |
| 自己切索引、自己 yield | 框架做 |
| 每次调用重新 shuffle | `shuffle=True` |
| 单进程 | `num_workers` 多进程 |
| 只能吃张量 | 任意 dataset |
| 自己要写 min() 防越界 | 自动处理，或 `drop_last` |

### 6. 三个坑

1. `next(loader)` 直接调用报 TypeError，必须先 `iter()`。
2. 最后一批不满时会照常返回（10, 3, 3, ...）。要丢掉就 `drop_last=True`。
3. 每个 batch 是 `stack` 出来的**新张量**，不是视图。改 batch 不会改原数据。

## 代码验证

```python
import torch
from torch.utils import data

X = torch.arange(12).reshape(6, 2).float()
y = torch.arange(6).float()

ds = data.TensorDataset(X, y)
print(len(ds), ds[0])

loader = data.DataLoader(ds, batch_size=2, shuffle=False)
print(type(loader))

for xb, yb in loader:
    print(xb.shape, yb.shape)

it = iter(loader)
print(next(it)[0])
```

## 还没解决的

`num_workers > 0` 在 WSL 里会不会因为 fork 出问题，没试。
