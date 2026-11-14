# Progress

Self-studying *Dive into Deep Learning* (d2l.ai), PyTorch edition.

## Note index

| Date | Section | Note |
| --- | --- | --- |
| 2026-10-07 | Prerequisites / Environment | [What a PyTorch environment actually is](notes/2026-10-07-pytorch-environment.md) |
| 2026-10-07 | Prerequisites / Environment | [Why the book never writes `import PyTorch`](notes/2026-10-07-import-torch.md) |
| 2026-10-07 | Prerequisites / Environment | [What `import d2l` gives you, and what it does not](notes/2026-10-07-import-d2l-scope.md) |
| 2026-10-07 | Prerequisites / Environment | [What `from ... import ...` does](notes/2026-10-07-from-import.md) |
| 2026-10-07 | Prerequisites / Environment | [How to set the environment up](notes/2026-10-07-environment-setup.md) |
| 2026-10-07 | Prerequisites / Math | [`torch.exp`: how many times do you multiply?](notes/2026-10-07-torch-exp.md) |
| 2026-10-07 | Prerequisites / Math | [Why `exp(1.0)` prints as `2.7183e+00`](notes/2026-10-07-scientific-notation.md) |
| 2026-10-07 | 2.5.3 Detaching computation | [What `z.sum().backward()` means](notes/2026-10-07-sum-backward.md) |
| 2026-10-07 | 2.5 Automatic differentiation | [What `backward()` actually does](notes/2026-10-07-backward.md) |
| 2026-10-07 | Python syntax | [`for ... in ...`: what can go after `in`](notes/2026-10-07-python-for-loop.md) |
| 2026-10-07 | 3.1.3 Normal distribution and squared loss | [Likelihood, and why the loss is squared](notes/2026-10-07-likelihood.md) |
| 2026-10-07 | 3.2.1 Generating the dataset | [What `#@save` means](notes/2026-10-07-save-directive.md) |
| 2026-10-07 | 3.2 Implementation from scratch | [What `net` and `loss` are](notes/2026-10-07-net-loss.md) |
| 2026-10-07 | 3.2 Implementation from scratch | [`torch.matmul`, `with`, and `sgd`](notes/2026-10-07-matmul-with-sgd.md) |
| 2026-10-17 | 2.2 Data preprocessing | [`iloc` and `fillna`](notes/2026-10-17-iloc-fillna.md) |
| 2026-10-17 | 2.3.6 / 2.3.8 | [Row sum vs matrix-vector, and the 1-D trap](notes/2026-10-17-row-sum-vs-matvec.md) |
| 2026-10-17 | 2.3.8 Matrix-vector | [`torch.mv` and friends](notes/2026-10-17-torch-mv.md) |
| 2026-10-17 | 2.3.9 Matrix-matrix | [Shape rule and three properties](notes/2026-10-17-matmul.md) |
| 2026-11-14 | 2.1.5 Saving memory | [`id()` and `Y[:]` are plain Python](notes/2026-11-14-id-and-slice-assign.md) |
| 2026-11-14 | 2.1.2 Indexing and slicing | [0-based, half-open, comma = axis](notes/2026-11-14-indexing-slices.md) |
| 2026-11-14 | 2.1 Exercises (discussion) | [Data vs algorithm: evidence vs compression](notes/2026-11-14-data-and-algorithm.md) |
| 2026-11-14 | 2.1 code / Jupyter | [`%matplotlib inline` is a magic, not Python](notes/2026-11-14-matplotlib-inline.md) |
| 2026-11-14 | 3.2.1–3.2.2 code | [synthetic_data, labels, scatter, shuffle, yield](notes/2026-11-14-3.2-code-walkthrough.md) |
| 2026-11-14 | Python syntax | [`yield` and generators, in detail](notes/2026-11-14-yield-generator.md) |
| 2026-11-14 | 3.2.6 Defining the optimization algorithm | [`sgd`: no_grad, /batch_size, zero_()](notes/2026-11-14-3.2.6-sgd.md) |

## Where I stopped

**2026-10-07 — finished 3.2, linear regression from scratch.**

I wrote the whole pipeline by hand: data generation, data iterator, model, loss, mini-batch SGD, training loop. The loop itself now runs:

```python
l = loss(net(X, w, b), y)
l.sum().backward()
sgd([w, b], lr, batch_size)
```

## Next

**Do the 3.2 exercises.**

- First choice: next weekend (10/10–10/11)
- Might only have one day, so it may not fit -> fallback: 10/17–10/18

## Todo

- [ ] 3.2 exercises
- [ ] 3.3 Concise implementation (swap `net` / `loss` for framework objects; the training loop barely changes)
- [ ] Run the setup script on the new machine (after the November build)

## Conventions

- One file per question, `YYYY-MM-DD-topic.md`
- English summary at the top, Chinese detail below
- Keep the wrong turns; do not rewrite history
