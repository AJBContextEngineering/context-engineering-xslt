### 🔄 Project Awareness & Context
- **Check `TASK.md`** before starting a new task. If the task isn’t listed, add it with a brief description and today's date.
- **Use the package and project manager uv** for installing and working with the Python environment.
- **Use venv** (the virtual environment) whenever executing Python commands, including for unit tests.

### Project Goals
The goals of this project are:
- **To create an MCP Server** using FastMCP2
- **To create a series of Behaviour Driven Development Tests** that test the correct behaviour of the MCP Server tools.
### Project Architecture
### Architecture Patterns

### 🧱 Code Structure & Modularity
- **Organize code into clearly separated modules**, grouped by feature or responsibility.
  This looks like:
    - `server.py` - MCP Server implementation
    - `tools.py` - Tool functions used by the agent 
    - `prompts.py` - System prompts
- **Use clear, consistent imports** (prefer relative imports within packages).
- **Use python_dotenv and load_env()** for environment variables.

### 🧪 Testing & Reliability
- **Use the behave BDD library for Python to write BDD tests**
- **After updating any logic**, check whether existing unit tests need to be updated. If so, do it.
- **Tests should live in a `/tests` folder** mirroring the main app structure.
  - Include at least:
    - 1 test for expected use
    - 1 edge case
    - 1 failure case

### ✅ Task Completion
- **Mark completed tasks in `TASK.md`** immediately after finishing them.
- Add new sub-tasks or TODOs discovered during development to `TASK.md` under a “Discovered During Work” section.

### 📎 Style & Conventions
- **Use Python library lxml** for processing XML and XSD

- Use Python library fastmcp2 to

- **Use Python** as the primary language for all coding.

- **Follow PEP8**, use type hints, and format with `black`.

- **Use `pydantic`** for data validation.

- Use `FastAPI` for APIs and `SQLAlchemy` or `SQLModel` for ORM if applicable.

- Write **docstrings for every function** using the Google style:
  ```python
  def example():
      """
      Brief summary.
  
      Args:
          param1 (type): Description.
  
      Returns:
          type: Description.
      """
  ```
  
- **docstrings for MCP Tools need to clearly specify in plain English what the purpose of the tool is, as well as using the Google style**
### Constraints

### 📚 Documentation & Explainability
- **Update `README.md`** when new features are added, dependencies change, or setup steps are modified.
- **Comment non-obvious code** and ensure everything is understandable to a mid-level developer.
- When writing complex logic in the Python files, **add an inline `# Reason:` comment** explaining the why, not just the what.

### 🧠 AI Behavior Rules
- **Never assume missing context. Ask questions if uncertain.**
- **Never hallucinate libraries or functions** – only use known, verified Python packages.
- **Always confirm file paths and module names** exist before referencing them in code or tests.
- **Never delete or overwrite existing code** unless explicitly instructed to or if part of a task from `TASK.md`.