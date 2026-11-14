> **In short:** `yield` turns a function into a generator: calling it runs nothing, and each `next()` resumes where the last one paused. The paused frame keeps its local variables and loop position, so it can hand out one batch at a time without holding the dataset in memory.

- **日期:** 2026-11-14
- **章节:** 3.2.2 读取数据集 / Python 生成器
- **来源:** 看书 + 跑代码

## 我的问题

`yield` 到底怎么工作？函数里放了它，行为为什么完全变了？

## 第一反应

以为跟 `return` 差不多，只是能返回多次。

## 卡在哪

“返回多次”说不通。函数执行完就该结束，状态怎么留住的？

## 想通了

### 1. 最简对比

```python
def f():
    return 1
    print('这里永远不执行')

g = f()        # 立刻执行，g 是 1

def h():
    yield 1
    print('下次继续时执行')

g = h()        # 一行都不执行，g 是生成器对象
```

调用 `h()` 只是创建对象。要它动，得 `next(g)`。

### 2. 实测：暂停和继续

```python
def gen():
    print('A: 进入函数')
    for i in range(3):
        print('B: 循环体开始 i =', i)
        yield i * 10
        print('C: 从 yield 后面继续 i =', i)
    print('D: 循环结束')
    return 'done'
```

实际输出（我跑过）：

```
=== 创建后，什么都没打印 ===
A: 进入函数          <- 第一次 next
B: 循环体开始 i = 0
next1 = 0
C: 从 yield 后面继续 i = 0   <- 第二次 next 从这里接上
B: 循环体开始 i = 1
next2 = 10
C: 从 yield 后面继续 i = 1
B: 循环体开始 i = 2
next3 = 20
C: 从 yield 后面继续 i = 2
D: 循环结束
StopIteration, value = done
```

两个关键点：

1. 每次 `next` 从**上次 yield 的下一行**开始，不是从头。
2. `i` 的值还在，循环位置也还在。

### 3. 暂停时保存了什么

生成器对象里存着一个**冻结的函数帧**：

- 所有局部变量（`i`、`batch_indices`、`num_examples`……）
- 执行到哪一行的位置
- 循环的当前状态

所以它能接着跑。普通函数 `return` 时帧直接销毁，所以没有“下次”。

### 4. next / for / StopIteration

```python
for X, y in data_iter(batch_size, features, labels):
    ...
```

等价于：

```python
it = iter(data_iter(...))
while True:
    try:
        X, y = next(it)
    except StopIteration:
        break
    ...
```

函数体跑完（或遇到 `return`）就抛 `StopIteration`，for 循环收到就退出。

生成器自己就是迭代器，`iter(g) is g` 为 True。

### 5. 在 data_iter 里逐批走一遍

```python
def data_iter(batch_size, features, labels):
    num_examples = len(features)
    indices = list(range(num_examples))
    random.shuffle(indices)
    for i in range(0, num_examples, batch_size):
        batch_indices = torch.tensor(indices[i: min(i + batch_size, num_examples)])
        yield features[batch_indices], labels[batch_indices]
```

1000 条、batch 10：

| 第几次 next | i | 交出的批次 |
| --- | --- | --- |
| 1 | 0 | 索引 0–9 |
| 2 | 10 | 索引 10–19 |
| … | … | … |
| 100 | 990 | 索引 990–999 |
| 101 | — | StopIteration |

中间 99 次暂停期间，`indices` 一直活着，不会重排。这也是为什么每个 epoch 要重新调用一次 `data_iter`。

### 6. 为什么用生成器，不用 list

```python
# 版本 A：一次算完
def data_iter_list(bs, f, l):
    out = []
    for i in range(0, len(f), bs):
        out.append((f[i:i+bs], l[i:i+bs]))
    return out       # 100 个 batch 全在内存里

# 版本 B：生成器
def data_iter(bs, f, l):
    ...
    yield f[i:i+bs], l[i:i+bs]   # 一次只有一个 batch
```

差别在内存峰值。数据集 10 GB、内存 8 GB，版本 A 直接崩，版本 B 没事。

生成器还有个好处：**可以边读边算**。从文件流、数据库游标里读，不用先全加载。

### 7. 五个坑

1. **只能用一次。** 遍历完再遍历，得到空。实测 `list(g2)` 第二次是 `[]`。
2. **不能 len、不能下标。** 它不是容器。要长度就传进去，或者先 `list()`。
3. **什么都不做直到被迭代。** `g = data_iter(...)` 不报错也不计算，bug 会在很久以后才冒出来。
4. **`return` 的值藏在异常里。** `StopIteration.value`，普通 for 循环拿不到。
5. **生成器里改外部状态要小心。** 它可能永远跑不完，副作用发生的时间点很难预测。

### 8. 进阶：yield 还能接收值

`yield` 是表达式，`x = yield v` 配合 `g.send(...)` 能把值送回去。协程就是这么起头的。

3.2 用不到，知道有这回事就行。

## 追问：3.2.2 为什么非要用 yield

其实不是非用不可。1000×2 的数据就 8 KB，全物化也没事。

但有两层理由。

### 一层是真实的：花式索引会拷贝

```python
features[batch_indices]   # batch_indices 是张量/列表 → 高级索引 → 拷贝
features[0:10]            # 切片 → 视图
```

所以 list 版本：

```python
out = [(features[idx[i:i+10]], labels[idx[i:i+10]]) for i in ...]
```

每批都是一份新拷贝。100 批攒下来，等于把整个数据集再存一遍。内存峰值接近 2 倍数据。

生成器只留当前一批，用完就丢。

### 另一层是接口

生成器给的是“一个 batch 的可迭代对象”。这正是后面 `DataLoader` 的形状：`for X, y in loader`。

3.2 手写一遍，3.3 换成 `DataLoader` 时训练循环一个字都不用改。

### 什么时候该用 list

- 数据小，反复遍历多轮
- 需要 `len()`、下标、随机访问
- 需要多个 worker 并发读（其实 DataLoader 内部还是迭代，但接口不是生成器）

一句话：这里 yield 省的不是样本，是“先把 100 个批次全部物化”那一步。

## 代码验证

见第 2 节的实测输出。复现脚本：

```python
def gen():
    for i in range(3):
        print('B', i)
        yield i * 10
        print('C', i)

g = gen()
next(g); next(g); next(g)
try:
    next(g)
except StopIteration as e:
    print('done', e.value)
```

## 还没解决的

生成器在 `DataLoader` 多进程里怎么被 pickle 分发给 worker，这块没看。
