> **In short:** matplotlib has three objects: Figure (the canvas), Axes (one plotting area), Artist (anything drawn). `plt` is a module of state-based functions that act on "the current Axes"; `ax` is that Axes object, and its methods are explicit. Prefer `ax` once there is more than one subplot.

- **日期:** 2026-11-14
- **章节:** matplotlib 心智模型
- **来源:** 从零补

## 我的问题

Python 会，但 `plt` 和 `ax` 从没碰过。它们是什么关系？

## 第一反应

以为 `ax` 是某个库的缩写，或者是数组。

## 卡在哪

不知道谁控制谁，也不知道为什么有时用 `plt.`，有时用 `ax.`。

## 想通了

### 1. 三层结构

```
Figure（画布）
 └── Axes（坐标系，一块绘图区）
      └── Artist（线、点、图、文字）
```

一张 Figure 可以有多个 Axes。每个 Axes 有自己的一套坐标轴。

d2l 里的“子图”，就是一个 Axes。

### 2. plt 是什么

`matplotlib.pyplot` 是一组**模块级函数**，背后维护一个“当前 Figure / 当前 Axes”的全局状态。

```python
import matplotlib.pyplot as plt

plt.plot([1, 2, 3])     # 画在“当前 Axes”上
plt.title('hi')         # 改“当前 Axes”的标题
plt.show()
```

问题：当前 Axes 是哪个，取决于你上一步干了什么。多子图时很容易画错地方。

### 3. ax 是什么

`ax` 是一个 **Axes 对象**。所有操作都是它的方法：

```python
fig, ax = plt.subplots()
ax.plot([1, 2, 3])
ax.set_title('hi')
fig.show()
```

没有“当前”这种隐式状态，指哪打哪。

### 4. subplots 的返回值

```python
fig, ax = plt.subplots()            # 1×1，ax 是单个对象
fig, axes = plt.subplots(2, 3)      # 2×3，axes 是二维数组
fig, axes = plt.subplots(2)         # 2×1 会压成一维
```

所以 d2l 里写 `axes.flatten()`——不管几行几列，压成一维就能一个循环走完。

### 5. 五个高频方法

```python
ax.plot(x, y)            # 折线
ax.scatter(x, y)         # 散点
ax.imshow(img)           # 把二维数组当图片
ax.set_title('...')      # 标题
ax.axis('off')           # 关坐标轴
```

再加三个不常用但会遇到的：

```python
ax.set_xlabel('x')       # 轴标签
ax.set_xlim(0, 10)       # 轴范围
ax.legend()              # 图例
```

### 6. imshow 和 plot 的区别

- `plot`：把一串数字当折线
- `imshow`：把二维数组的**每个元素当一个像素的亮度**

一张 28×28 的图，就是一个 28×28 的数组，所以用 `imshow`。

### 7. 为什么 d2l 混着写

`d2l.plt.subplots(...)` 用的是模块函数（造画布），后面用 `ax.xxx`（在指定格子里画）。

造画布只能走 `plt`，画内容走 `ax`。分工明确。

### 8. 最小可跑

```python
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(6, 3))

axes[0].plot([1, 2, 3], [1, 4, 9])
axes[0].set_title('plot')

axes[1].imshow([[0, 1], [1, 0]])
axes[1].set_title('imshow')

for ax in axes:
    ax.axis('off')

plt.show()
```

## 一句话

`plt` 是遥控器，按的是“当前那台电视”。`ax` 是直接走到某台电视前面按。

多台电视时，用 `ax`。

