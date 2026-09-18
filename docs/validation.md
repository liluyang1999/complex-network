# 维护证据、未验证项与历史材料

基线提交：`41f3281aea42f0e60342ca313e3e79f9393140d6`。

## 当前证据边界

本机未安装 MATLAB/Octave；遵照约束，未下载运行时、包、工具箱或语法分析器。没有执行 MATLAB 编译/Code Analyzer、13 组 functiontests、图形显示、CSV/MAT 导出或性能测量。下面用例是**已编写、未运行**，静态辅助脚本不是 MATLAB 解析器，也不能替代 MATLAB 门禁。

已逐份阅读原 18 个 .m 文件、5 个 .mlx 的代码 XML，检查调用链、输出格式、数值方向、有限循环和历史兼容点。MATLAB 没有可用的本地语言专项指南，本次遵循通用工程约束并核对 MathWorks 原始文档。

## 待执行门禁

```matlab
results = runtests('tests');
assertSuccess(results);
run_demo(42, true); % 人工核对两张网络图及 L/D/E 三维散点，关闭窗口
```

`tests/test_network.m` 包含 13 组：

1. 手算路径/完全/星形/单点/断连指标。
2. 图边界拒绝、连通性与种群维度。
3. N=2/3 的初始化、Bernoulli p=0/1。
4. 三种变异及连通/对称/零对角/边数不变量。
5. 目标方向、加权选择、单个体、非法权重。
6. Pareto 关系、重复分数、常数目标和极端数值拥挤距离。
7. 原始种群助手的形状与精英索引一致性。
8. 相同种子、预算 19/种群 6、缓存成本与随机状态恢复。
9. 零迭代、小种群、可变长度最终非支配前沿。
10. 选项错误和异常路径的 RNG 恢复。
11. 随机图无条件与条件统计。
12. 无图示例和真实临时目录导出/重载/拒绝覆盖/清理。

13. 枚举 4 顶点全部 64 种带标号简单图：38 个连通，其中 26 个非支配；成本类型和数量与独立 BFS/有理数穷举参照一致。

独立参照用本机已有 Python 标准库实际计算，使用有理数求均值和直接两两支配定义。它建立数学期望，不执行或验证 MATLAB 实现；MATLAB 对照用例仍未运行。

辅助检查可用已有 Python 运行 `python tools/check_source.py`，仅核对文件名、cn 调用引用、文档相对链接与历史材料哈希。

测试使用 MATLAB 内置的 [functiontests](https://www.mathworks.com/help/matlab/matlab_prog/function-based-unit-tests.html)，不依赖第三方测试包。不建立会自动下载 MATLAB 的 CI，GitHub 状态为空不能解释成测试通过。

## Live Script 迁移

- `self_test.mlx` 与 `test_question5.mlx` 固定访问 10 个结果，前者还有局部旧 mutation，后者用连线画点会暗示未求解的连续前沿。改用 run_demo 的散点和真实结果长度。
- `self_test.mlx` 固定访问前 5 个前沿，少于 5 个时越界；应按 numel(fronts) 遍历。
- `test_question2.mlx` 的断连示例最后一个对角元素是 1，包含自环，不符合当前图契约；使用 `zeros(4)` 等零对角断连图。
- `test_question4.mlx` 的基本入口兼容，但未固定随机种子，旧输出没有本次重复性保证。
- `test_question6.mlx` 对不同指标重新采样，且平均值里可能有 Inf。改用 analyze_random_graphs 的共享样本与明确连通比例。

原二进制材料原样保留，不重写 XML 或伪造实验输出。维护前后的 SHA-256 应一致：

| 历史文件 | SHA-256 |
|---|---|
| self_test.mlx | `07d986efdad668e92fcc282b9d21b19cb639cb5a2e5c0612dc2462128beecf9d` |
| test_question2.mlx | `3c545d98c5f2c350f8a8bd7b08c6fc1803b2cd2305f2f31407d394898107143a` |
| test_question4.mlx | `d5b4b05de4b062bdda691aca002314dd6496c109bc8db7a64cd7d09284255c74` |
| test_question5.mlx | `24011fbeee6c0f1efb97beb4583602a65caa1e40098a7873ca1f3d76da1b3121` |
| test_question6.mlx | `636afd1a51e491f7b32d7c5c8e71fb6504a5107caca6c4f8bd61604239ec970e` |

后续若发现 MATLAB Code Analyzer 或运行时错误，应以实际错误与失败测试继续修复，并更新本文件证据；不得把其他语言中的公式对照称作 MATLAB 已验证结果。
