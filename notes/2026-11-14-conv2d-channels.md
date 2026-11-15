> **In short:** Yes — `nn.Conv2d(in_channels, out_channels, kernel_size, ...)`. `1, 1` means one input channel and one output channel, i.e. one convolution kernel. The weight tensor is then `(1, 1, 5, 3)`.

- **日期:** 2026-11-14
- **章节:** 6.3 填充和步幅
- **来源:** 看书

## 我的问题

`nn.Conv2d(1, 1, kernel_size=(5, 3), padding=(2, 1))` 里最先的两个 `1, 1` 是什么？是输入和输出的通道吗？

## 第一反应

猜是通道数，但不确定顺序。

## 卡在哪

三个参数挤在一起，不知道哪个管什么。

## 想通了

### 1. 是的，就是输入和输出通道

签名：

```python
nn.Conv2d(in_channels, out_channels, kernel_size,
          stride=1, padding=0, dilation=1, groups=1, bias=True)
```

所以：

- 第一个 `1` → `in_channels=1`：输入是单通道（灰度图）
- 第二个 `1` → `out_channels=1`：输出一张特征图，也就是只有一个卷积核

如果是彩色图接 64 个核：

```python
nn.Conv2d(3, 64, kernel_size=3)
```

### 2. 参数张量的形状

```python
conv = nn.Conv2d(1, 1, kernel_size=(5, 3))
print(conv.weight.shape)   # torch.Size([1, 1, 5, 3])
print(conv.bias.shape)     # torch.Size([1])
```

权重是四维：`(out_channels, in_channels, kH, kW)`。

偏置是一维，长度等于 `out_channels`。

为什么权重是四维：每个输出通道对每个输入通道都有一个独立的核。1×1 的情况下就是一张 5×3 的图。

### 3. padding=(2, 1) 在干什么

高方向两边各补 2 行，宽方向两边各补 1 列。

核是 5×3，所以补完正好对齐：

```
输出高 = (H + 2×2 − 5) / 1 + 1 = H
输出宽 = (W + 2×1 − 3) / 1 + 1 = W
```

尺寸不变。这种补法叫 same padding：`p = (k-1)/2`，要求核尺寸是奇数。

5 的高配 2，3 的宽配 1，正好对上。

### 4. 一个 8×8 的例子

```python
X = torch.rand(size=(8, 8))
conv2d = nn.Conv2d(1, 1, kernel_size=(5, 3), padding=(2, 1))
comp_conv2d(conv2d, X).shape
```

输出还是 `torch.Size([8, 8])`。

注意输入要写成四维 `(batch, channel, H, W)`，`comp_conv2d` 内部会帮你补上前面两维。

### 5. 怎么读这类签名

记顺序：**输入通道 → 输出通道 → 核 → 步幅 → 填充**。

前两个永远在一起，因为它们是“数据从哪来、到哪去”。

## 一句话

前两个参数就是输入通道数和输出通道数。输出通道数等于这一层用了几个卷积核。

