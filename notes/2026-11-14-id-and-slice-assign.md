> **In short:** `id()` is a Python builtin that tells you whether two names point at the same object. `Y[:]` is an ordinary slice that selects every element; assigning to it writes into the existing tensor instead of creating a new one. None of this is PyTorch-specific syntax.

- **日期:** 2026-11-14
- **章节:** 2.1.5 节省内存
- **来源:** 看书

## 我的问题

2.1.5 那一节看着不像 Python。`id` 是什么？`Y[:]` 又是什么？

## 第一反应

以为是 PyTorch 自己的写法，或者某种索引语法糖。

## 卡在哪

两处卡住：

1. `id(Y)` 不知道在测什么
2. `Y[:] = X + Y` 里的 `[:]` 不知道怎么读

## 想通了

### 1. `id()` 是 Python 内置函数

`id(x)` 返回对象的身份标号。CPython 里就是内存地址。

它比的是“是不是同一个东西”，不比内容：

```python
a = [1, 2, 3]
b = a            # 同一个对象
id(a) == id(b)   # True
```

### 2. `Y = Y + X` 换了一个对象

`Y + X` 先算出一个新张量，占新内存。然后把名字 `Y` 指过去。

旧张量没人引用就回收了。所以 `id(Y)` 变了。

### 3. `Y[:]` 就是“整条轴全要”

Python 切片语法是 `seq[start:stop:step]`。三个都省略就是全体。

`Y[:]` 等于 `Y[0:n]`。

对 tensor 来说，`Y[:]` 取出来的是**视图**，和 `Y` 共用同一块内存，不是拷贝。

### 4. 赋值给切片 = 往原内存里写

`Y[:] = expr` 走 `__setitem__`。它把 `expr` 的值逐元素写进 `Y` 已有的缓冲区。

名字没换，对象没换，`id` 自然不变。等价写法是 `Y.copy_(expr)`。

四种写法对比：

```python
Y = Y + X      # 新对象，id 变
Y[:] = Y + X   # 原对象，id 不变
Y += X         # 原对象，id 不变（__iadd__）
Y.add_(X)      # 原对象，id 不变
```

一个细节：`Y[:] = Y + X` 还是会临时分配一个 `Y + X`，省的是 `Y` 那块。

`Y.add_(X)` 连临时张量都不分配。

### 5. 为什么书里在意这件事

参数一秒更新很多次，总量几百 MB。不想每次都重新分配内存。

更要命的是引用。模型和优化器别处还拿着参数的旧引用。你 `Y = Y + X` 换了对象，那些引用仍指着旧内存，参数其实没更新。

## 代码验证

纯 Python 就能看到 `id` 的行为（list 版）：

```python
L = [1, 2, 3]
b = id(L)
L = L + [4]
print(id(L) == b)   # False  换了对象

M = [0, 0, 0, 0]
b = id(M)
M[:] = [1, 2, 3, 4]
print(id(M) == b)   # True   还是那个对象
```

torch 版（书里的例子）：

```python
import torch
X = torch.arange(12).reshape(3, 4)
Y = torch.zeros_like(X)

before = id(Y)
Y = Y + X
print(id(Y) == before)      # False

Z = torch.zeros_like(Y)
before = id(Z)
Z[:] = X + Y
print(id(Z) == before)      # True

print(Z[:].data_ptr() == Z.data_ptr())       # True   视图，共用内存
print(Z.clone().data_ptr() == Z.data_ptr())  # False  拷贝
```

## 一个坑

同样的 `[:]`，list 和 tensor 意思不一样：

- `L[:]` → 浅拷贝，新列表
- `T[:]` → 视图，共用内存

`Y[:] = ...` 两边都是原地改。但 `Y[:]` 单独拿出来用，行为完全不同。

## 还没解决的

`id()` 和 `data_ptr()` 都跟内存有关。什么时候该用哪个？

书里只用 `id` 演示。真查共享内存要看 `data_ptr()`。
