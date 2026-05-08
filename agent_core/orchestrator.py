# agent_core/orchestrator.py
from langchain_community.chat_models import ChatOllama
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
"""

class PlantbreedAIAgent:
    def __init__(self, model_name="llama3"):
        # Initialize local LLM via Ollama
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
