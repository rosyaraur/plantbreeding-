# =====================================================================
# THE BULLETPROOF BOOTLOADER: Run this ONCE at the start of every session
# =====================================================================
import os
import time
from IPython.display import clear_output
from google.colab import output

print("🚀 Starting Automated Environment Setup...")

# 1. Safe Download Sequence
%cd /content/
!rm -rf PlantbreedAIAgent
print("📦 Downloading repository...")
!git clone https://github.com/rosyaraur/PlantbreedAIAgent.git > /dev/null 2>&1
%cd /content/PlantbreedAIAgent
!apt-get update -qq && apt-get install -y -qq zstd > /dev/null 2>&1

# 2. Install Stable Python Dependencies (Locked to 0.2.0 for AgentExecutor)
print("🐍 Installing Python frameworks...")
!pip install -q "langchain~=0.2.0" "langchain-community~=0.2.0" "langchain-core~=0.2.0" "langchain-ollama~=0.1.0"
!pip install -q fastapi uvicorn streamlit rpy2 pandas

# 3. Install R Packages (Optimized: Required dependencies ONLY)
print("📊 Installing R packages...")
!Rscript -e 'install.packages(c("agricolae", "multcomp", "lmPerm", "AGHmatrix", "dplyr", "emmeans", "factoextra", "FNN", "ggplot2", "gridExtra", "gstat", "lattice", "leaflet", "lme4", "lmerTest", "magrittr", "MASS", "Matrix", "metan", "mgcv", "patchwork", "plotly", "randomForest", "rlang", "sommer", "sp", "SpATS", "tidyr", "visNetwork"), repos="https://packagemanager.posit.co/cran/__linux__/jammy/latest", dependencies=NA)'

# 4. Apply the Bulletproof Patches
print("🔧 Patching code for Llama 3.2 and Colab compatibility...")

# Patch 4a: Fix the Orchestrator (Upgrade to Llama 3.2, fix imports, disable verbose bug)
orch = "/content/PlantbreedAIAgent/agent_core/orchestrator.py"
with open(orch, "r") as f: d = f.read()
d = d.replace("from langchain_community.chat_models import ChatOllama", "from langchain_ollama import ChatOllama")
d = d.replace('model_name="llama3"', 'model_name="llama3.2"')
d = d.replace('verbose=True', 'verbose=False')
with open(orch, "w") as f: f.write(d)

# Patch 4b: Fix the __init__ typo
init_file = "/content/PlantbreedAIAgent/agent_core/__init__.py"
with open(init_file, "r") as f: d = f.read()
with open(init_file, "w") as f: f.write(d.replace("PlantBreedingAgent", "PlantbreedAIAgent"))

# Patch 4c: Fix R Wrapper Paths
wrap = "/content/PlantbreedAIAgent/tools/r_wrappers.py"
with open(wrap, "r") as f: d = f.read()
with open(wrap, "w") as f: f.write(d.replace('R_DIR = "./core_logic/r_package/plantbreeding/R"', 'R_DIR = "/content/PlantbreedAIAgent/core_logic/r_package/plantbreeding/R"'))

# Patch 4d: Mute local R testing code
!sed -i 's|.*~/Downloads/.*|# &|' /content/PlantbreedAIAgent/core_logic/r_package/plantbreeding/R/*.R

# 5. Start the Local AI Engine (Llama 3.2!)
print("🧠 Booting LLM Engine (Llama 3.2)...")
!curl -fsSL https://ollama.com/install.sh | sh > /dev/null 2>&1
!nohup ollama serve > ollama.log 2>&1 &
!ollama pull llama3.2 > /dev/null 2>&1

# 6. Clean Slate & Launch Servers
print("🌐 Launching Backend API and Frontend UI...")
os.system("pkill -f uvicorn")
os.system("pkill -f streamlit")
time.sleep(2)

os.system("nohup uvicorn api.server:app > backend.log 2>&1 &")
time.sleep(5)

os.system("nohup streamlit run frontend/app.py --server.port 8501 --server.enableCORS=false --server.enableXsrfProtection=false > frontend.log 2>&1 &")
time.sleep(5)

# 7. Generate Secure Access Link
clear_output()
port = 8501
proxy_url = output.eval_js(f"google.colab.kernel.proxyPort({port})")
print("✅ SYSTEM IS FULLY ONLINE WITH LLAMA 3.2!")
print(f"🔗 Click here to open PlantbreedAIAgent: {proxy_url}")






