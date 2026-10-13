# Automatic Skill Invocation Rules

To maintain high software engineering rigor, clean minimal architecture, and token efficiency, the agent MUST automatically invoke and follow these specialized skills for the corresponding tasks:

## 1. Codebase Architecture & Navigation
- **`graphify`**: Automatically invoke whenever answering architectural questions, identifying dependencies, exploring god nodes / community structure in `graphify-out/`, or querying code relationships. Run `graphify update .` after code modifications to keep AST up to date.

## 2. Document & Multi-Modal File Conversion
- **`markitdown`**: Automatically invoke whenever reading, extracting, summarizing, or converting non-markdown documents (PDF, DOCX, PPTX, XLSX, XLS, CSV, HTML, JSON, EPUB, audio, or images) to Markdown.

## 3. Prompt Engineering & AI Optimization
- **`prompt-master`**: Automatically invoke whenever creating, optimizing, fixing, or refining prompts for LLMs, AI agents, Midjourney, coding assistants, or system instructions.

## 4. Minimalist & Senior Engineering (Anti-Bloat)
- **`ponytail` / `ponytail-review` / `ponytail-audit`**: Automatically invoke before proposing large new abstractions or when reviewing PRs. Prioritize the least complex solution, reuse existing components in `lib/component/`, and avoid boilerplate or premature abstractions.
- **`ponytail-debt`**: Automatically invoke when refactoring or identifying unused/redundant code.

## 5. Software Development & Execution Rigor (Superpowers)
- **`systematic-debugging`**: Automatically invoke whenever investigating a bug, unexpected runtime error, or test failure. Follow root-cause isolation before applying fixes.
- **`test-driven-development`**: Automatically invoke when creating new business logic, models, or repositories.
- **`writing-plans` & `executing-plans`**: Automatically invoke when designing or executing multi-step feature changes or large refactorings.
- **`subagent-driven-development` & `dispatching-parallel-agents`**: Automatically invoke when orchestrating subagents or parallel independent modules.
- **`verification-before-completion`**: Automatically invoke before concluding any task to verify that tests pass, analysis is clean, and implementation satisfies all user requirements.
- **`requesting-code-review` & `receiving-code-review`**: Automatically invoke when conducting or addressing code review feedback.
- **`brainstorming`**: Automatically invoke during initial design exploration, feature ideation, or architectural decision phases.
