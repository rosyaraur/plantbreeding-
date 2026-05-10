### 1. The Imports (The Blueprint)

This section brings in the necessary external libraries, primarily from LangChain, which handles the complex routing between the AI and your tools.

```python
# FIXED: Now using the official tool-calling Ollama integration
from langchain.agents.format_scratchpad.tools import format_to_tool_messages
from langchain.agents.output_parsers.tools import ToolsAgentOutputParser
from langchain_ollama import ChatOllama
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate
from tools.tool_registry import get_all_tools

```

* **`format_to_tool_messages` & `ToolsAgentOutputParser`:** These specific parsers force the agent to actually execute tools instead of just printing raw JSON text to the screen.
* **`ChatOllama`:** The official bridge that allows Python to talk to your local Llama 3.2 engine.
* **`create_tool_calling_agent` & `AgentExecutor`:** The core engine components that create the "Thought -> Action -> Observation" loop.

### 2. The `SYSTEM_PROMPT` (The Agent's Rules)

This multi-line string is the permanent psychological framework for the AI. Every time it thinks, it reads these rules first.

```python
SYSTEM_PROMPT = """
You are PlantbreedAIAgent, an expert agronomic, biometric, and quantitative genetics AI.
You have access to a robust suite of R-powered statistical tools.
When a user asks for an analysis:
1. Identify the correct tool based on their experimental design or genomic data.
2. Ensure the required dataset is referenced in the workspace.
3. Execute the tool.
4. Summarize the findings based on the tool's output. Do not hallucinate or make up statistical results.

CRITICAL RULE: You are an execution agent. NEVER output raw JSON tool calls, python dictionaries, or raw code blocks to the user.
You must execute the tools silently in the background and only provide the user with a conversational, human-readable summary of the final results.

CRITICAL RULE: All user datasets are securely located in the 'workspace/inputs/' directory. If a user asks you
to analyze a file like 'data.csv',
you MUST automatically prepend the path and tell the R-tool to look for 'workspace/inputs/data.csv'
"""

```

* **The Persona & Workflow:** Sets the agent up as an expert AI and gives it a strict 4-step execution process.
* **CRITICAL RULE 1:** Forbids the "lazy intern" behavior of dumping code on the screen, forcing it to summarize the results cleanly.
* **CRITICAL RULE 2:** Solves the "File Not Found" error by forcing the agent to automatically map paths to your `/workspace/inputs/` directory.

### 3. The `PlantbreedAIAgent` Class (The Engine)

This is the main object you import into your FastAPI server. The `__init__` function builds the agent the moment your server starts up.

```python
class PlantbreedAIAgent:
    def __init__(self, model_name="llama3.2"):
        # Initialize local LLM via official Ollama package
        self.llm = ChatOllama(model=model_name, temperature=0)
        
        self.tools = get_all_tools()
        
        self.prompt = ChatPromptTemplate.from_messages([
            ("system", SYSTEM_PROMPT),
            ("placeholder", "{chat_history}"),
            ("human", "{input}"),
            ("placeholder", "{agent_scratchpad}"),
        ])
        
        # Create the agent
        agent = create_tool_calling_agent(self.llm, self.tools, self.prompt)
        self.agent_executor = AgentExecutor(agent=agent, tools=self.tools, verbose=True)

```

* **`temperature=0`:** Crucial for data science. It removes the AI's "creativity," ensuring it maps variables to tools deterministically without guessing.
* **`self.prompt`:** Stacks your system rules, the user's prompt, and the `agent_scratchpad` (the AI's internal notepad where it tracks errors before talking to the user).
* **`AgentExecutor(..., verbose=True)`:** Binds everything into a continuous loop and prints the internal thought process to your Colab terminal.

### 4. The Action Loop (`chat` method)

This is the entry point for actual conversations. When a user types a message in Streamlit, it gets passed here.

```python
    def chat(self, user_input: str, chat_history: list = None):
        """Entry point for handling user queries."""
        if chat_history is None:
            chat_history = []
            
        response = self.agent_executor.invoke({
            "input": user_input,
            "chat_history": chat_history
        })
        
        return response["output"]

```

* **`invoke(...)`:** Takes the user's message and fires up the entire LangChain pipeline. It waits for the AI to think, run the R-scripts, read the outputs, and generate a final text summary.
* **`return response["output"]`:** Extracts the final human-readable text and sends it back to your FastAPI server to display on the Streamlit screen.