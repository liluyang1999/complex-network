# 复杂网络上的进化算法：可复现教学版

学习简单无向图的平均最短路 L、直径 D、边数 E，以及单目标进化算法、加权目标和 NSGA-II 风格的多目标选择。保留原 18 个 `.m` 入口，将共享逻辑放在 `+cn/`。

**验证状态：当前机器没有 MATLAB，也没有安装或下载 MATLAB、Octave 或额外工具箱。此次完成源码审查、辅助源文件检查和数学用例设计；MATLAB 测试与图形输出尚未执行。不能据此声称算法的 MATLAB 运行门禁已通过。**

## 在已有 MATLAB 的环境运行

建议 MATLAB R2020b 或更新版，仅使用 MATLAB 本体的 graph、table、functiontests 等功能；最低版本是文档目标，尚无实际版本矩阵验证。将当前目录切到项目根目录，不需要 `addpath(genpath(...))`。

```matlab
results = run_demo(42, false);       % 小规模、固定种子、不弹图、不写文件
results.MOEA.Info.Costs              % 每行一个最终非支配解，列为 [L D E]
run_demo(42, true);                  % 如需图形，显式开启
tests = runtests('tests');
assertSuccess(tests);
```

有 MATLAB 命令行时可使用 `matlab -batch "assertSuccess(runtests('tests'))"`。这是供已有环境使用的命令，本次未执行。

## 原有入口与新增选项

```matlab
opts = struct('PopulationSize', 20, 'Generations', 30, ...
              'Seed', 42, 'MaxEvaluations', 405, 'MutationAttempts', 100);
[G, score, info] = EA(8, .3, .3, opts);                           % 最大化 D-L
[G, cost, info] = EA_weighted_fitness(8,.3,.3,.34,.33,.33,opts); % 最小化加权成本
[graphs, values, info] = MOEA(8, .3, .3, opts);                  % 最终非支配前沿
```

不传 opts 时保留种群 80、迭代 80、使用调用者 RNG 的习惯。传入 Seed 时使用 twister，并在正常返回或异常退出时恢复调用者随机状态。第二输出的原始含义保持：EA 返回 D-L；加权 EA 返回加权**成本**；MOEA 返回 `{1/L,1/D,1/E}` 三个行向量。

MOEA 现在返回最终种群全部 rank=1 个体，**数量可变，不再固定 10 个**。重复图或目标相同的图可能保留；这是当前种群的非支配集合，不是全局最优性的证明。请用 `numel(graphs)` 和 `1 ./ values{k}` 处理长度。

## 学习与实验

- [理论、流程与练习](docs/learning-guide.md)
- [接口契约与维护记录](docs/contracts.md)
- [验证清单与历史材料](docs/validation.md)

```matlab
summary = analyze_random_graphs(15, 0:.1:1, 50, 42);
[runs, points] = run_experiments(fullfile(pwd,'results','class-01'), 1:5, 400, 10);
```

实验出口必须是一个**全新目录**，创建 `runs.csv`、`points.csv`、`experiment.mat`，记录参数、平台版本、图、成本和历史，不覆盖已有路径。三种算法的目标不同；评估预算一致不意味着能把它们排成一个通用优劣榜。

原 `.mlx` 是未改动的历史作业，不作为维护版的运行入口。它们有旧输出、固定 10 个解、对前沿数量的假设，`self_test.mlx` 还包含会遮蔽维护代码的局部 mutation；请先阅读迁移说明。
