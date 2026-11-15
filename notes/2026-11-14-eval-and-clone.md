> **In short:** `clone` is just a variable name — a second copy of the model. `.eval()` is a method inherited from `nn.Module` that flips the module into evaluation mode: dropout stops dropping and batch norm uses running statistics instead of batch statistics.

- **日期:** 2026-11-14
- **章节:** 5.5.2 加载和保存模型参数
- **来源:** 看书

## 我的问题

5.5.2 里这几行看着不像 Python：

```python
clone = MLP()
clone.load_state_dict(torch.load('mlp.params'))
clone.eval()
```

`clone.eval` 是什么语法？

## 第一反应

以为是某种特殊关键字，或者框架自创的写法。

## 卡在哪

分不清 `clone`、`.eval()`、`state_dict` 各是什么东西。

## 想通了

### 1. 都是普通 Python

`clone` 只是个**变量名**。作者给“复制出来的模型”起名叫 clone，跟 `net`、`model` 没区别。

`.eval()` 是**方法调用**，和 `[].append()` 一个形式。

```python
obj.method()      # 标准方法调用
clone.eval()      # 一样，只是 clone 是模型对象
```

没有任何新语法。

### 2. eval() 做什么

它是个开关，把模型切到“评估模式”。

内部只做一件事：

```python
self.training = False
```

对应地，`model.train()` 设回 `True`。

`nn.Module` 里所有子模块都能读到这个标志，行为跟着变。

### 3. 为什么重要

两个层受影响最大：

**Dropout**：训练时随机丢弃一部分神经元，评估时必须全留。

**BatchNorm**：训练时用当前批次算均值方差，评估时用训练期累积的滑动统计量。

不切 eval 模式直接预测，结果会抖动，甚至明显偏差。

### 4. state_dict 是什么

```python
net.state_dict()
```

是一个普通字典：`{参数名: 张量}`。

```python
{
 'hidden.weight': tensor(...),
 'hidden.bias': tensor(...),
 'out.weight': tensor(...),
 'out.bias': tensor(...)
}
```

`torch.save` 存的就是这个字典，`load_state_dict` 按名字填回去。

### 5. 为什么不保存整个模型

`torch.save(net)` 也能存，但它用 pickle，把类的定义路径也写进去。

换个目录、改个类名、升级版本，就加载不了。

存 `state_dict` 只存数字，比较稳。类是代码，本来就在你手里。

### 6. 完整流程

```python
torch.save(net.state_dict(), 'mlp.params')   # 存参数

clone = MLP()                                 # 重建同样结构
clone.load_state_dict(torch.load('mlp.params'))  # 填参数
clone.eval()                                  # 切评估模式
Y_clone = clone(X)                            # 预测
```

先有结构，再填参数。顺序不能反。

### 7. 常和 no_grad 一起用

```python
with torch.no_grad():
    y = model(x)
```

`eval()` 管“层的行为”，`no_grad` 管“要不要建图”。两件事，通常一起写。

## 代码验证

```python
import torch
from torch import nn

m = nn.Sequential(nn.Linear(4, 4), nn.Dropout(0.5))

x = torch.ones(2, 4)

m.train()
print('train 模式:', m(x))     # 有 0

m.eval()
print('eval 模式 :', m(x))     # 没有 0

print('training 标志:', m.training)
```

## 一句话

`clone` 是变量名，`.eval()` 是方法调用。它只是把模型从“训练状态”拨到“考试状态”。

