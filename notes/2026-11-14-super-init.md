> **In short:** `super()` gives you the next class in the inheritance chain. In PyTorch you must call `super().__init__()` first because `nn.Module.__init__` creates the dictionaries that store parameters and submodules; skip it and assigning `self.hidden = nn.Linear(...)` raises an error.

- **日期:** 2026-11-14
- **章节:** 5.1 层和块 / 4.x 自定义模型
- **来源:** 看书

## 我的问题

`class` 里的 `super()` 是什么？为什么每个模型开头都要写 `super().__init__()`？

## 第一反应

以为是个固定仪式，抄就完了。

## 卡在哪

不知道不写会怎样，也不知道它调的是谁。

## 想通了

### 1. 继承先说清楚

```python
class Animal:
    def __init__(self, name):
        self.name = name
    def speak(self):
        return '...'

class Dog(Animal):          # Dog 继承 Animal
    def speak(self):
        return 'woof'
```

`Dog` 自动拥有 `Animal` 的所有方法。子类可以覆盖（重写同名方法）。

### 2. super() 是什么

`super()` 返回**父类对象**，用来调用父类的方法。

```python
class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name)     # 调 Animal.__init__
        self.breed = breed
```

不写 `super().__init__(name)` 的话，`self.name` 永远不会被设置。

### 3. 为什么 PyTorch 里必须写

`nn.Module.__init__` 干的事不只是赋值。它创建了几个内部字典：

```python
self._parameters = {}
self._modules = {}
self._buffers = {}
```

之后你写 `self.hidden = nn.Linear(20, 256)` 时，PyTorch 会重载 `__setattr__`，把这些层登记进 `_modules`。

字典不存在，登记就失败，报错：

```
AttributeError: cannot assign module before Module.__init__() call
```

所以 `super().__init__()` 必须是第一行。

### 4. 标准样子

```python
class MLP(nn.Module):
    def __init__(self):
        super().__init__()              # 必须第一行
        self.hidden = nn.Linear(20, 256)
        self.out = nn.Linear(256, 10)

    def forward(self, X):
        return self.out(F.relu(self.hidden(X)))
```

### 5. 为什么不是 super(MLP, self)

老写法 `super(MLP, self).__init__()` 是 Python 2 的遗留。Python 3 里 `super()` 自动取当前类和 self，不用写参数。

### 6. 多继承时它调的是“下一个”

`super()` 的准确含义不是“父类”，而是 **MRO（方法解析顺序）里的下一个类**。

单继承时两者一样。多继承时按 `class C(A, B)` 的顺序找，`super()` 只走一步，不会一次调完所有父类。

现在用不到，知道有这回事就行。

## 代码验证

```python
class A:
    def __init__(self):
        print('A.__init__')
        self.x = 1

class B(A):
    def __init__(self):
        print('B.__init__ 开始')
        super().__init__()
        print('B.__init__ 结束, x =', self.x)

b = B()
```

输出顺序：

```
B.__init__ 开始
A.__init__
B.__init__ 结束, x = 1
```

## 一句话

`super().__init__()` 是“先把父类那部分装好，再装我自己的”。PyTorch 的父类装的是参数登记表，少了它就没地方放层。

