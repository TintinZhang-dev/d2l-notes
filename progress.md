# 学习进度

自学《动手学深度学习》(d2l.ai),PyTorch 版。

## 笔记索引

| 日期 | 章节 | 笔记 |
| --- | --- | --- |
| 2026-10-07 | 前置 / 环境准备 | [PyTorch 环境是什么](notes/2026-10-07-pytorch-environment.md) |
| 2026-10-07 | 前置 / 环境准备 | [书里为什么没有 import PyTorch](notes/2026-10-07-import-torch.md) |
| 2026-10-07 | 前置 / 环境准备 | [import d2l 的作用域](notes/2026-10-07-import-d2l-scope.md) |
| 2026-10-07 | 前置 / 环境准备 | [from ... import ... 是什么意思](notes/2026-10-07-from-import.md) |
| 2026-10-07 | 前置 / 环境准备 | [环境怎么搭](notes/2026-10-07-environment-setup.md) |
| 2026-10-07 | 前置 / 数学基础 | [torch.exp 求幂是求几次](notes/2026-10-07-torch-exp.md) |
| 2026-10-07 | 前置 / 数学基础 | [exp(1.0)=2.7183e+00 是科学计数法](notes/2026-10-07-scientific-notation.md) |
| 2026-10-07 | 2.5.3 分离计算 | [z.sum().backward() 是什么意思](notes/2026-10-07-sum-backward.md) |
| 2026-10-07 | 2.5 自动微分 | [backward() 到底是什么](notes/2026-10-07-backward.md) |
| 2026-10-07 | Python 语法 | [for 的 in 后面能放什么](notes/2026-10-07-python-for-loop.md) |
| 2026-10-07 | 3.1.3 正态分布与平方损失 | [似然看不懂(为什么用平方损失)](notes/2026-10-07-likelihood.md) |
| 2026-10-07 | 3.2.1 生成数据集 | [#@save 是什么意思](notes/2026-10-07-save-directive.md) |
| 2026-10-07 | 3.2 从零开始实现 | [net() 和 loss() 是什么](notes/2026-10-07-net-loss.md) |
| 2026-10-07 | 3.2 从零开始实现 | [torch.matmul()、with、sgd()](notes/2026-10-07-matmul-with-sgd.md) |

## 停在哪

**2026-10-07:读完 3.2(线性回归的从零开始实现)。**

3.2 里亲手写了一遍:数据生成 → 数据迭代器 → 模型 → 损失 → 小批量 SGD → 训练循环。训练循环的骨架已经跑通:

```python
l = loss(net(X, w, b), y)
l.sum().backward()
sgd([w, b], lr, batch_size)
```

## 下次

**做 3.2 的习题。**

- 首选:下个周末(10/10–10/11)
- ⚠️ 但可能只有一天,来不及 → 备选:下下个周末(10/17–10/18)

## 待办

- [ ] 3.2 习题
- [ ] 3.3 线性回归的简洁实现(把 `net`/`loss` 换成框架对象,训练循环几乎不变)
- [ ] 环境脚本在新机器上实测(双十一装机后)
