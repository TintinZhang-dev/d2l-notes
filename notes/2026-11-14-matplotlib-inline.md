> **In short:** `%matplotlib inline` is an IPython magic, not Python. It tells matplotlib to render figures as static images embedded in the notebook output instead of opening a separate window. In a plain `.py` script it is a syntax error.

- **日期:** 2026-11-14
- **章节:** 2.1 代码里的第一行
- **来源:** 看书

## 我的问题

`%matplotlib inline` 是什么？为什么前面有个 `%`？

## 第一反应

以为是 Python 的语法，或者是导入某个库的写法。

## 卡在哪

`%` 开头的东西在 Python 里不合法，可它又能跑。

## 想通了

### 1. 它是 IPython 的魔法命令

`%` 开头的是 IPython/Jupyter 的 magic，不是 Python 语法。解释器在把代码交给 Python 之前，先处理这些行。

- `%名字` → 行魔法，只作用这一行
- `%%名字` → 单元魔法，作用整个 cell

所以它只在 IPython、Jupyter、VS Code 的交互窗口里能用。写进 .py 文件跑，直接 SyntaxError。

### 2. 它干的事：换绘图的 backend

matplotlib 画图要有后端，后端决定图往哪输出：

- `inline` → 输出成静态图片，嵌在 notebook 结果里
- `qt` / `osx` / `tk` → 弹一个独立窗口
- `widget` → notebook 里的可交互图（要 ipympl）

`%matplotlib inline` 就是把后端切成 inline。图直接显示在 cell 下面，跟 notebook 文档一起保存。

### 3. 三个实际影响

1. 图是位图，不能在 notebook 里缩放拖动。
2. 每个 cell 结束时图会自动关掉，所以 inline 模式下 `plt.show()` 可以不写。
3. 想要矢量图更清楚，加一行 `%config InlineBackend.figure_format = 'svg'`。

### 4. 我该怎么用

d2l 的 notebook 第一格都有这一行，为了图能显示出来。

如果我把代码抄成 .py 脚本跑，这一行要删掉，改成显式调用 `d2l.plt.show()`。

## 代码验证

```python
# 在 Jupyter 里
%matplotlib inline
import matplotlib.pyplot as plt
plt.plot([1, 2, 3])
# 图直接出现在下面

# 在 .py 文件里这行会报错：
# SyntaxError: invalid syntax
```

## 还没解决的

`widget` 后端的交互图在 WSL 里能不能正常显示，没试。
