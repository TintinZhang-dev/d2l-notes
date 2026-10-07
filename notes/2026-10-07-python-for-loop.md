# Python 的 for 有初始值吗?为什么没有 x++?

- **日期:** 2026-10-07
- **章节:** Python 语法基础
- **来源:** 看 2.1 循环代码时想到的

## 我的问题

> 这是一个关于 python 语法的问题。for 里边不要写 x++ y++ 这类的,还有初始值吗。

## 一句话

**Python 根本没有 `++`;for 的「初始值 + 条件 + 递增」三件事,全被 range 接走了。**

## 一、Python 没有 ++

```python
x++     # ❌ SyntaxError
x += 1  # ✅ 只能这样
```

C / Java / JS 里 `x++` 是**表达式**,能嵌在别的地方用,比如 `y = x++`。Python 不要这套,只留 `x += 1`(语句)。

## 二、Python 的 for 是「遍历」,不是「计数」

C 风格:

```c
for (int i = 0; i < n; i++) { ... }
//     ↑初始值   ↑条件  ↑递增
```

Python:

```python
for i in range(n):
    ...
```

**没有三段式。** 你只写「遍历谁」,`range(n)` 负责依次给出 0, 1, 2, …, n-1。

## 三、初始值一直都在,只是藏在 range 里

| 写法 | i 取哪些值 | 「初始值」 |
| --- | --- | --- |
| `range(4)` | 0, 1, 2, 3 | 0(默认) |
| `range(1, 5)` | 1, 2, 3, 4 | 1 |
| `range(0, 10, 2)` | 0, 2, 4, 6, 8 | 0,步长 2 |

`range(起点, 终点, 步长)` —— **起点就是你想要的初始值**。

## 四、对照表

| C / Java / JS | Python |
| --- | --- |
| `for (i=0; i<n; i++)` | `for i in range(n)` |
| `for (i=1; i<=n; i++)` | `for i in range(1, n+1)` |
| `for (i=0; i<n; i+=2)` | `for i in range(0, n, 2)` |
| `x++` | `x += 1` |
| `for (x : arr)` | `for x in arr` |

## 五、什么时候才需要手写初始值?→ while

```python
i = 0            # 初始值:这里写
while i < n:
    ...
    i += 1       # 递增:这里写(忘了就死循环)
```

**for 把这三件事全接走了,所以更安全。** 这就是 Python 里大部分循环用 for 的原因。

## 六、书里的例子

```python
n = 100
a = torch.ones(n)
b = torch.ones(n)
c = torch.zeros(n)
for i in range(n):
    c[i] = a[i] + b[i]
```

- `i` 不用给初始值,range 给
- `c` 必须先 `torch.zeros(n)` —— 但这跟循环变量无关,是张量要先有地方放

**顺带:** 这段手动循环,后面直接写成 `c = a + b` 一行。**向量化才是 PyTorch 的正道**,手写循环是用来理解过程的。

## 七、一个坑

Python 没有「块作用域」。循环结束后 `i` 还活着,值是最后一个:

```python
for i in range(3):
    pass
print(i)   # 2
```

## 代码验证

```python
for i in range(4):
    print(i, end=" ")        # 0 1 2 3

for i in range(1, 5):
    print(i, end=" ")        # 1 2 3 4

for i in range(0, 10, 2):
    print(i, end=" ")        # 0 2 4 6 8

for x in [10, 20, 30]:       # 直接遍历元素
    print(x, end=" ")        # 10 20 30

for i, x in enumerate([10, 20, 30]):   # 又要下标又要元素
    print(i, x)              # 0 10 / 1 20 / 2 30
```

## 还没解决的

无。
