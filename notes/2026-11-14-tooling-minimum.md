> **In short:** d2l assumes you already know Python, numpy and matplotlib — it never teaches them. What blocks you at 3.5 is tooling, not deep learning. Learn five plotting calls and three shape facts; skip the rest until needed.

- **日期:** 2026-11-14
- **章节:** 工具链（非正文）
- **来源:** 自查

## 为什么卡住

d2l 第 2 章开头默认你会：

- Python 基础（函数、列表、字典、类）
- matplotlib 画图
- 一点 numpy

它一句都没教，直接用。你没学过，所以 3.5 卡在画图上，不是卡在深度学习上。

## 先分清主线和支线

**主线**：张量的形状、梯度、损失、优化器、前向反向。

**支线**：画图、读写文件、写类。

支线看不懂不影响你理解训练过程。可以先放着。

## 画图只要五个调用

```python
fig, axes = plt.subplots(2, 3, figsize=(9, 6))  # 造 2×3 个格子
ax = axes[0][0]                                  # 拿左上角那格
ax.imshow(img)                                   # 把数组当图片画
ax.set_title('label')                            # 加标题
ax.axis('off')                                   # 关掉坐标轴
plt.show()                                       # 显示整张画布
```

就这些。d2l 里那些 `get_xaxis().set_visible(False)` 等价于 `ax.axis('off')`，只是写得啰嗦。

## 三件必须记住的形状事实

1. **PIL 图片**：`(H, W)`，灰度图没有通道维，取值 0–255 的整数
2. **ToTensor 之后**：`(C, H, W)`，灰度图 C=1，取值 0–1 的浮点
3. **一批数据**：`(B, C, H, W)`，B 是 batch size

把这三条记住，3.5 之后所有形状都能推。

## 现在可以先跳过的东西

- `d2l.use_svg_display()` —— 只是让图更清晰
- `axes.flatten()` —— 二维转一维，知道有这回事就行
- 各种 `figsize`、`scale` 参数 —— 纯审美
- `transforms.ToTensor()` 之外的所有 transform

## 补的顺序

1. **画图**：上面那五个调用，30 分钟够
2. **类与对象**：读懂 `class X(nn.Module)` 需要，30 分钟
3. **numpy**：只需要知道 `np.array` 和 `.shape`，其余用 torch 代替

## 一句话

不是所有东西都得先学会才能往下走。画图看不懂，就把画图那几行当黑盒，先跑训练循环。

