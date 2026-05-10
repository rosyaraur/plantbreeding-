# agent_core/orchestrator.py

# FIXED: Now using the official tool-calling Ollama integration
from langchain.agents.format_scratchpad.tools import format_to_tool_messages
from langchain.agents.output_parsers.tools import ToolsAgentOutputParser
from langchain_ollama import ChatOllama
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate
from tools.tool_registry import get_all_tools

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

    def chat(self, user_input: str, chat_history: list = None):
        """Entry point for handling user queries."""
        if chat_history is None:
            chat_history = []
            
        response = self.agent_executor.invoke({
            "input": user_input,
            "chat_history": chat_history
        })
        
        return response["output"]
