# 文章分析笔记：《Agents和Workflows孰好孰坏，LangChain创始人和OpenAI杠上了》

**文章来源**: Founder Park (微信公众号)
**原始链接**: https://mp.weixin.qq.com/s/hWON23L4WD_1vRZGbTgKbw
**发布日期**: 2025-04-21 (根据frontmatter `created` 字段)

## 1. 文章核心内容总结
本文主要围绕OpenAI发布的《构建AI Agents实用指南》与LangChain创始人Harrison Chase对此提出的异议展开。核心争论点在于构建Agentic系统时，是应该更倾向于由LLM主导的、结构最少的Agent模式（OpenAI观点），还是更强调通过显式代码、模块化工作流（Workflow）来构建，并允许在Workflow和Agent之间灵活切换的模式（Harrison Chase观点，以LangGraph为例）。文章探讨了Agent的定义、构建Agentic系统的核心难点（确保LLM获得恰当上下文）、不同框架类型（声明式 vs 命令式，Workflows vs Agents封装）以及LangGraph的设计理念。

## 2. 关键论点与洞察
- **OpenAI观点**: 倾向于通过LLM主导Agent，采用代码优先的Agent SDK，认为声明式工作流在动态性和复杂性增加时会变得繁琐。
- **Harrison Chase (LangChain)观点**:
    -   大多数Agentic系统是Workflows和Agents的结合。
    -   理想框架应允许从结构化工作流逐步过渡到模型驱动，并灵活切换。
    -   更认同Anthropic对"Agentic系统"的定义，将Workflows和Agents视为其不同表现形式。
    -   强调LangGraph通过显式代码、模块化工作流构建智能体，认为结构化流程更可控、易调试，适合复杂任务。
    -   构建可靠Agentic系统的核心难点在于确保LLM在每一步都能拿到恰当的上下文信息。
    -   Agent封装虽易入门，但可能隐藏底层细节，增加上下文控制难度。
- **Anthropic观点 (被Chase引用和认同)**:
    -   提出"Agentic系统"概念，包含Workflows（预写代码路径协调LLM和工具）和Agents（LLM动态决定流程和工具使用）。
    -   建议从最简单方案入手，Workflows处理界定清晰任务，Agents处理需灵活性和模型驱动决策的规模化场景。
- **核心矛盾**: 大模型派（Big Model，依赖模型升级，通用结构少的智能体） vs 工作流派（Big Workflow，显式代码、模块化工作流，如LangGraph）。
- **构建Agent的实际难点**: 确保LLM在每一步获得正确的上下文信息，包括控制输入内容和执行正确步骤生成有用内容。

## 3. 提及的关键概念、框架与公司/人物
*   **核心概念**:
    *   [[AI Agent (智能体)]]
    *   [[Agentic 系统]]
    *   [[Workflows (工作流)]] (在AI Agent语境下)
    *   [[声明式编排 (Declarative Orchestration)]]
    *   [[命令式编排 (Imperative Orchestration)]] / [[代码优先 (Code-first)]]
    *   [[Agent 封装 (Agent Wrappers)]]
    *   [[LLM上下文信息精确控制]]
    *   [[模型驱动决策 (Model-driven decision making)]]
    *   [[结构化流程 (Structured flows)]]
*   **提及的框架/工具**:
    *   [[LangChain]]
    *   [[LangGraph]]
    *   [[OpenAI Agents SDK (概念)]]
*   **提及公司**:
    *   [[OpenAI]]
    *   [[LangChain (公司)]]
    *   [[Anthropic]]
*   **提及人物**:
    *   [[Harrison Chase]] (LangChain 创始人)
    *   [[Andrew Ng]] (被引用，关于"多大程度上像Agent"的思考方式)

## 4. 可提取用于知识库的信息类型
*   **趋势**:
    *   [[AI Agent构建范式之争：LLM主导 vs. 工作流主导]]
    *   [[Agentic系统向混合模式发展 (Workflow+Agent)]]
    *   [[AI框架对上下文控制能力的强调]]
*   **公司标签**:
    *   [[OpenAI]]: 关于Agent构建的观点和指南。
    *   [[LangChain (公司)]]: 对OpenAI观点的回应，LangGraph的设计理念和定位。
    *   [[Anthropic]]: 关于Agentic系统和构建高效Agent的观点。
*   **概念标签**:
    *   上述所有"核心概念"均可作为独立的AI技术、理论模型或开发范式概念进行记录。
    *   特别是 [[Agentic 系统]], [[AI Workflows (Agentic语境)]], [[LangGraph设计理念]]。
*   **人物观点**:
    *   [[Harrison Chase 关于Agent和Workflow的观点]]
    *   [[OpenAI 关于Agent构建的观点 (指南核心内容)]]
    *   [[Anthropic 关于Agentic系统和高效Agent构建的观点]]
*   **客观事件**:
    *   [[OpenAI发布《构建AI Agents实用指南》事件 (约2025年4月)]]
    *   [[LangChain创始人Harrison Chase回应OpenAI Agent指南事件 (约2025年4月)]]

## 5. 文章价值与启发
*   **价值**: 清晰呈现了当前AI Agent构建领域中两种主流思路（模型驱动 vs. 工作流驱动）的代表观点和核心论据，有助于理解不同Agent框架的设计哲学和适用场景。强调了在Agent构建中上下文信息控制的核心重要性。
*   **启发**:
    *   选择或设计Agent框架时，需关注其对上下文信息控制的粒度和灵活性。
    *   "Agentic"程度是一个谱系，多数实用系统可能是Workflow和Agent的混合体。
    *   对于复杂、可靠性要求高的任务，结构化的Workflow可能仍是重要组成部分。
    *   框架的易用性（低门槛）和能力上限（高天花板）需要权衡。

## 6. 后续处理建议
- **已完成**: 文章来源、原始链接、发布日期已确认并记录。核心内容、关键论点、提及概念、公司、人物已初步提取。
- **下一步**:
    - 将提取的**趋势**添加到 `@趋势数据汇总.md`。
    - 更新/添加相关**公司信息**到 `@公司标签数据汇总.md`。
    - 将提取的**核心概念**添加到 `@AI技术与模型概念汇总.md` 和/或 `@理论与模型概念汇总.md`。
    - 将提取的**客观事件**添加到 `c1_1_事件_events.md`。
    - 将**人物观点**整合到对应人物标签或概念标签中。
    - 为本文章在 `@信息来源标签数据汇总.md` 中创建条目。
    - 更新`@工作清单_Input_to_Processed.md`中对应文章的状态和提取摘要。 