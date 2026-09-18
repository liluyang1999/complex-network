# 接口与兼容契约

## 输入和资源边界

优化入口 N=2..200；随机 G(N,p) 允许 N=1；种群大小 1..1000，独立生成函数允许 0 个样本。Generations=0..10000，MutationAttempts=1..10000。MaxEvaluations 为 Inf 或不小于初始种群大小的整数；到达代数或评估预算之一即结束。限制用于课堂规模，非大型稀疏网络引擎。

Seed 为 [] 或 0..2^32-1 的整数，支持整数数值类型并转换为 double 后计算。未知选项拼写直接报错，避免悄悄使用默认值。概率与权重必须有限实数，溢出/下溢导致无效分数时要求重缩放权重。

所有种群入口接收 cell 向量并规范为行向量；优化适应度要求所有图同阶且连通。图指标本身可以检查断连图。错误使用 `cn:*` 标识符，见 tests 中的错误路径用例。

## 文件职责

| 原入口 | 维护后的职责 |
|---|---|
| cal_avg_path_len / cal_diameter / cal_link_num | L / D / E；边数直接计数，无需最短路 |
| check_connected | 基于连通分量，单点 true |
| fitness | D-L 行向量 |
| weighted_fitness | 加权成本倒数行向量 |
| multi_obj_fitness | `{1/L,1/D,1/E}` 三个行向量 |
| init_population | 先生成树再加边，有限步骤初始化 |
| gen_N_p_random_graphs | 真正独立 Bernoulli 边，不过滤断连 |
| mutation | 加边/删边/重连，概率和连通性检查，有界尝试 |
| selection | 二元锦标赛，可显式传第三参数 fitness；单个体不再死循环 |
| non_dominated_sorting | 全部前沿和每个个体的 rank |
| crowding_distance | 按前沿计算，验证完整且无重复的分区 |
| crow_tour_selection | rank/拥挤距离锦标赛 |
| elite_preservation | 严格填满指定大小，拒绝越界和坏分区 |
| EA / EA_weighted_fitness / MOEA | 共用 cn.evolve 的缓存评估和记账 |

`+cn` 中的矩阵选择助手分离了数学逻辑与图评估，使退化分数、重复值、NaN、缺失前沿等情况能独立测试。包名为教学内部实现组织，并不表示全部助手都是通用数值库。

## info 第三输出

- Options：实际默认值和规范化后的设置；Mode/Weights/N/P1/P2：问题参数。
- Evaluations、Generations：实际评估数量和完成的子代迭代次数。
- Costs：返回图的原始成本，每行 [L D E]；PopulationCosts：最终整个种群成本。
- EvaluationHistory：包含初代和末次实际完成步骤。
- BestScoreHistory：单目标最大分数，MOEA 下为 NaN。
- FrontSizeHistory：MOEA 最终种群每步第一前沿大小，单目标下为 NaN。

每一代评估子代一次，亲代值随精英索引保留；最后返回已缓存的值，不把重新计算偷偷加在预算外。

## 与历史实验的差异

MOEA 的长度可变；旧 `ones(1,10)./values{k}` 应改成 `1./values{k}`。最终前沿不代表全搜索空间的 Pareto 真前沿。重复个体保留，允许种群大小 1，允许零迭代，支持部分末代。

初始化分布、变异邻域、恒定目标距离和并列规则均已明确，运行结果可能与原作业不同。加权父代选择纠正为同一目标。参数验证拒绝此前悄悄接受的自环/权重图和无效概率；这属于本次契约收紧。

导出在全部运行成功后才创建新目录，并在创建前再检查是否出现同名路径。普通单进程教学使用中拒绝覆盖；导出中磁盘故障可留下本次创建的部分目录，保留用于诊断，之后必须换新目录重试。它不是对恶意并发文件替换的事务安全存储。
