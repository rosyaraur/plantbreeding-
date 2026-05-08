# api/server.py
from fastapi import FastAPI
from pydantic import BaseModel
from agent_core.orchestrator import PlantbreedAIAgent

app = FastAPI(title="PlantbreedAIAgent API")

# Initialize the engine once when the server starts
engine = PlantbreedAIAgent(model_name="llama3") 

class ChatRequest(BaseModel):
    message: str
    # chat_history: list = [] # Can be added later for multi-turn conversations

@app.post("/chat")
async def chat_endpoint(request: ChatRequest):
    """Send a message to PlantbreedAIAgent and trigger tools."""
    try:
        reply = engine.chat(user_input=request.message)
        return {"response": reply, "status": "success"}
    except Exception as e:
        return {"response": str(e), "status": "error"}

# Run with: uvicorn api.server:app --reload