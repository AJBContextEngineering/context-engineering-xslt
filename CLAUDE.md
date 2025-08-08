### 🔄 Project Awareness & Context
- **Check `TASK.md`** before starting a new task. If the task isn’t listed, add it with a brief description and today's date.
- **Use the package and project manager uv** for installing and working with the Python environment.
- **Use venv** (the virtual environment) whenever executing Python commands, including for unit tests.

### Project Goals
The goals of this project are:
- **To create an XSLT mapping file** that is compliant with XSLT version 3.0.
- **To create a series of Behaviour Driven Development Tests** that tests each field specified to be mapped in the XSLT file that has been implemented in an `<xslt:apply-templates>` call to an `<xslt:template>`.
- To also create a series of Behaviour Driven Development tests for each instance of `<xslt:call-template>` generated.
### Project Architecture
- **Use `<xsl:apply-templates>` wherever possible** to map the source element to the target element.
- **Use `<xsl:call-template>`**  when XSL code needs to be produced that is not dependent upon finding a source match.

### Architecture Patterns

### 🧱 Code Structure & Modularity
- **Create a new `<xsl:template>` for every source field to be mapped to a target field and apply it with  `<xsl:apply-template>`.**
- **Organize code into clearly separated modules**, grouped by feature or responsibility.
  For agents this looks like:
    - `agent.py` - Main agent definition and execution logic 
    - `tools.py` - Tool functions used by the agent 
    - `prompts.py` - System prompts
- **Use clear, consistent imports** (prefer relative imports within packages).
- **Use python_dotenv and load_env()** for environment variables.

### 🧪 Testing & Reliability
- **Use SaxonHE Python library saxonche for running the XSLT transforms created**
- **Use the behave BDD library for Python to write BDD tests**
- ** Always create a BDD test for each source field of the XSLT mapped using `<xslt:apply-templates>`**
- ** Always create a BDD test for each instance of `<xslt:call-template>`**
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
- **Use XSLT 3.0** for all XSLT mappings.
- **Use saxonche** to execute all XSLT mappings
- **Use Python** as the primary language for all other coding apart from XSLT mapping..
- **Follow PEP8**, use type hints, and format with `black`.
- **Use `pydantic` for data validation**.
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
### Constraints

### 📚 Documentation & Explainability
- **Update `README.md`** when new features are added, dependencies change, or setup steps are modified.
- **Comment non-obvious code** and ensure everything is understandable to a mid-level developer.
- When writing complex logic in the Python files, **add an inline `# Reason:` comment** explaining the why, not just the what.
- Always add an `<xsl:comment>` to the XSL file to explain what is happening in each `<xsl:template>`

### 🧠 AI Behavior Rules
- **Never assume missing context. Ask questions if uncertain.**
- **Never hallucinate libraries or functions** – only use known, verified Python packages.
- **Always confirm file paths and module names** exist before referencing them in code or tests.
- **Never delete or overwrite existing code** unless explicitly instructed to or if part of a task from `TASK.md`.