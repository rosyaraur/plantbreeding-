# agent_core/state.py
from typing import List, Optional
from pydantic import BaseModel

class AgentState(BaseModel):
    """Tracks the current context of the conversation."""
    session_id: str
    chat_history: List[dict] = []
    current_active_dataset: Optional[str] = None  # e.g., "workspace/inputs/yield_trial_2026.csv"
    last_generated_plot: Optional[str] = None     # e.g., "workspace/outputs/gge_biplot.png"

    def update_dataset(self, filepath: str):
        self.current_active_dataset = filepath
        
    def add_message(self, role: str, content: str):
        self.chat_history.append({"role": role, "content": content})