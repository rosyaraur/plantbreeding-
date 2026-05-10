This file is short, but it is arguably one of the most important files in your entire project.

By moving this text into a dedicated `prompts.py` file, you are practicing **"Separation of Concerns"**—a core software engineering principle. Instead of clogging up your complex logic files (like `orchestrator.py`) with massive blocks of text, you store the AI's "brain" here, making it incredibly easy to tweak the agent's personality later without accidentally breaking your Python code.

Here is the line-by-line breakdown of how this prompt fundamentally shapes the behavior of Llama 3.2.

---

### 1. The Persona & Objective (Setting the Mindset)

Large Language Models are generalists by default. If you don't tell them who they are, they will act like a generic, overly enthusiastic chatbot.

```python
SYSTEM_PROMPT = """
You are the Plant Breeding Data Intelligence Engine, an expert agronomic and statistical AI. 
Your goal is to assist plant breeders and geneticists in analyzing their field trial data.

You have access to a suite of specialized tools for both R and Python. 
"""

```

* **The Persona:** By explicitly telling Llama 3.2 it is an "expert agronomic and statistical AI," you force the model to load its deep, domain-specific training weights regarding biometrics and genetics. It will automatically adopt a more professional, academic, and precise tone.
* **Tool Awareness:** You are explicitly reminding the model that it is not trapped in a chat window; it has hands (R and Python tools) that it can use to interact with the user's data.

### 2. The Chain of Thought (The Workflow)

LLMs perform significantly better when you force them to think in logical steps. This is called "Chain of Thought" prompting.

```python
When a user asks you to perform an analysis (e.g., AMMI, AUDPC, GGE Biplots):
1. Identify the correct tool for the job.
2. Check if you have the required dataset in the workspace. If not, ask the user for it.
3. Execute the tool.
4. Interpret the statistical output (like p-values, variance, or disease severity) and explain it to the user in clear, scientifically accurate language.

```

* **Step 1 (Planning):** Stops the AI from just guessing. It forces it to search its `tool_registry` first.
* **Step 2 (Validation):** This is your safeguard against the "File Not Found" hallucination. It tells the AI to actually check its surroundings before it tries to do math.
* **Step 3 & 4 (Execution & Translation):** It forces the AI to not just dump raw numbers on the screen, but to act as a translator, reading the complex R-script terminal outputs and turning them into readable insights (like translating a p-value into plain English).

### 3. The Guardrails (The Constraints)

Because Llama 3.2 is a "people pleaser," it will naturally try to invent answers if it gets confused just so it doesn't disappoint the user. These constraints act as a strict psychological fence.

```python
Constraints:
- Never make up statistical results. Only report what the tools output.
- If a tool fails, explain the error to the user and suggest how to fix the input data.
- Always be precise about whether you are reporting genotypic or phenotypic variances.
"""

```

* **Anti-Hallucination:** "Never make up statistical results." This is the most critical line in a scientific AI. If the R-script crashes, this rule tells the AI it is *okay* to admit failure rather than inventing fake ANOVA tables.
* **Graceful Degradation:** "Explain the error..." Instead of just saying "Error 500," the AI is instructed to read the Python/R traceback, figure out *why* it failed (e.g., "You have missing values in your block column"), and coach the user on how to fix their CSV.
* **Domain Accuracy:** "Always be precise..." This is a brilliant, highly specific rule for a plant breeding agent. It forces the LLM to pay close attention to the biological reality of the math, preventing it from carelessly mixing up $V_g$ and $V_p$ in its summaries.

### 💡 How to use this file in your architecture:

Because you have this saved in `agent_core/prompts.py`, you can now go into your `orchestrator.py` file, delete that massive block of text at the top, and replace it with a single, elegant line:

```python
# Inside agent_core/orchestrator.py
from agent_core.prompts import SYSTEM_PROMPT

```