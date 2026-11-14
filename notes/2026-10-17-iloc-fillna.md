# iloc 与 fillna：按位置取列，按列名填缺失

> **In short:** `iloc` selects by integer position (`0:2` = first two columns, end-exclusive); `fillna(series)` fills each column by matching its name; `mean(numeric_only=True)` only averages numeric columns, so category columns stay empty.

- **日期:** 2026-10-17
- **章节:** 2.2 数据预处理
- **来源:** 看书时读不懂两行代码

## 我的问题

`data.iloc[:, 0:2]` 和 `inputs.fillna(inputs.mean(numeric_only=True))` 到底在做什么？

## 想通了

### 1. `iloc` 按位置取

- 格式 `iloc[行, 列]`，`:` 表示全部
- `0:2` 取第 0、1 列（Python 切片**左闭右开**）
- 对比 `loc`：按标签取（列名、索引名）
- **`iloc` 认数字，`loc` 认名字**，混用是最常见报错来源

### 2. `fillna` + `mean`

- `mean(numeric_only=True)`：只对数值列求均值
- `numeric_only` 不能省：pandas 对字符串列求均值会报错
- `fillna(Series)` 按**列名匹配**填充；Series 里没有的列（Alley）保持 NaN

### 3. 背后的设计逻辑（比语法重要）

- **数值缺失** → 填均值 / 中位数（有「平均」这个概念）
- **类别缺失** → 没有平均，只能**单独成一类**（`get_dummies(dummy_na=True)` 多出一列 `Alley_nan`）

⚠️ 均值填充会**压缩方差**（把数据往中间拉）。能跑通，但不是最优。

## 代码验证

```python
import pandas as pd
data = pd.DataFrame({
    'NumRooms': [None, 2.0, 4.0, None],
    'Alley': ['Pave', None, None, None],
    'Price': [127500, 106000, 178100, 140000],
})
inputs, outputs = data.iloc[:, 0:2], data.iloc[:, 2]
inputs = inputs.fillna(inputs.mean(numeric_only=True))
print(inputs)   # NumRooms 全变成 3.0；Alley 仍是 NaN
```

## 还没解决的

- 缺失值除了均值填充，还有哪些策略？（删行 / 中位数 / 模型预测）
