# #@save 是什么意思?

> **In short:** `#@save` is a d2l book-build directive that copies the cell into the `d2l` package. It is not Python syntax.

- **日期:** 2026-10-07
- **章节:** 3.2.1 生成数据集
- **来源:** 看书时的疑问

## 我的问题

> 3.2.1 告诉我 synthetic_data(w, b, num_examples) 的写法,但标注 #@save,也就是说他这里只是让我了解一下,实际写代码的时候可以直接从 d2l 用?

## 结论

**后半句对:实际代码里可以直接 `d2l.synthetic_data(...)`。**

**前半句要改:`#@save` 不是「只是了解一下」,而是「这段代码会被收进 d2l 包」。**

## 一、#@save 是什么

**它不是 Python 语法。**

`#` 开头,Python 解释器当注释直接忽略。它是给 **d2l 书的构建工具(d2lbook)** 看的指令。

构建时的动作:

1. 扫描全书代码单元格
2. 凡是标了 `#@save` 的函数 / 类,抽出来
3. 拼进 `d2l` 包(对应后端文件 `d2l/torch.py`)
4. 读者 `pip install d2l` 后就能直接用

## 二、实测验证

扒 d2l 包源码:

```bash
$ grep -n "def synthetic_data" d2l/torch.py
137:def synthetic_data(w, b, num_examples):
```

书里 3.2.1 的定义:

```python
def synthetic_data(w, b, num_examples):  #@save
    """生成 y = Xw + b + 噪声"""
    ...
```

3.3 简洁实现里直接这么用:

```python
features, labels = d2l.synthetic_data(true_w, true_b, 1000)
```

**完全对上。** 你的判断没错。

## 三、但「只是了解一下」不太准确

3.2 是**「从零开始实现」**章节,3.3 才是**「简洁实现」**。

书的设计是:先在 3.2 手动走一遍(数据管道 → 模型 → 损失 → 优化器),再在 3.3 换成框架的现成写法。所以:

| | 你要做的 |
| --- | --- |
| 3.2 里的 synthetic_data | **看懂**它怎么造数据:为什么加噪声、为什么 reshape |
| 以后写代码 | **直接用** `d2l.synthetic_data` |

两件事不冲突。**理解原理 + 知道有现成的,同时做到。**

## 四、一个容易误解的点

**`#@save` 是 d2l 项目特有的,不是 Python / PyTorch 的功能。**

你自己写代码时标 `#@save`,什么都不会发生,它就是个普通注释。

## 五、一个实用后遗症

读 d2l 时,某个函数在某章「凭空出现」,八成是在前面某章被 `#@save` 过。

想确认它从哪来:

```python
from d2l import torch as d2l
print(d2l.synthetic_data.__module__)   # 'd2l.torch'
```

## 还没解决的

无。
