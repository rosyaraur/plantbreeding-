# =====================================================================
# THE MASTER BOOTLOADER: Run this ONCE at the start of every session
# =====================================================================
import os
import time
from IPython.display import clear_output
from google.colab import output

print("🚀 Starting Automated Environment Setup...")

# 1. Safe Download Sequence (Go to base camp, delete old, clone fresh)
print("📦 Downloading repository...")
%cd /content/
!rm -rf PlantbreedAIAgent
!git clone https://github.com/rosyaraur/PlantbreedAIAgent.git > /dev/null 2>&1
%cd /content/PlantbreedAIAgent
!apt-get update -qq && apt-get install -y -qq zstd > /dev/null 2>&1

# 2. Install Stable Python Dependencies
print("🐍 Installing Python frameworks...")
!pip install -q "langchain<0.2.0" "langchain-community<0.2.0" "langchain-core<0.2.0"
!pip install -q fastapi uvicorn streamlit rpy2 pandas

# 3. Install R Packages (Optimized: Required dependencies ONLY)
print("📊 Installing R packages...")
!Rscript -e 'install.packages(c("agricolae", "multcomp", "lmPerm", "AGHmatrix", "dplyr", "emmeans", "factoextra", "FNN", "ggplot2", "gridExtra", "gstat", "lattice", "leaflet", "lme4", "lmerTest", "magrittr", "MASS", "Matrix", "metan", "mgcv", "patchwork", "plotly", "randomForest", "rlang", "sommer", "sp", "SpATS", "tidyr", "visNetwork"), repos="https://packagemanager.posit.co/cran/__linux__/jammy/latest", dependencies=NA)'

# 4. Apply Cloud-Compatibility Patches
print("🔧 Patching hardcoded paths for Colab compatibility...")
# Fix Langchain Import
orch = "/content/PlantbreedAIAgent/agent_core/orchestrator.py"
with open(orch, "r") as f: d = f.read()
with open(orch, "w") as f: f.write(d.replace("from langchain_ollama import ChatOllama", "from langchain_community.chat_models import ChatOllama"))

# Fix R_DIR absolute path
wrap = "/content/PlantbreedAIAgent/tools/r_wrappers.py"
with open(wrap, "r") as f: d = f.read()
with open(wrap, "w") as f: f.write(d.replace('R_DIR = "./core_logic/r_package/plantbreeding/R"', 'R_DIR = "/content/PlantbreedAIAgent/core_logic/r_package/plantbreeding/R"'))

# Mute local testing code in R scripts
!sed -i 's|.*~/Downloads/.*|# &|' /content/PlantbreedAIAgent/core_logic/r_package/plantbreeding/R/*.R

# 5. Start the Local AI Engine (Ollama)
print("🧠 Booting LLM Engine (Llama 3)...")
!curl -fsSL https://ollama.com/install.sh | sh > /dev/null 2>&1
!nohup ollama serve > ollama.log 2>&1 &
!ollama pull llama3 > /dev/null 2>&1

# 6. Clean Slate & Launch Servers
print("🌐 Launching Backend API and Frontend UI...")
os.system("pkill -f uvicorn")
os.system("pkill -f streamlit")
time.sleep(2)

# Start Backend
os.system("nohup uvicorn api.server:app > backend.log 2>&1 &")
time.sleep(5)

# Start Frontend (with Colab security bypasses)
os.system("nohup streamlit run frontend/app.py --server.port 8501 --server.enableCORS=false --server.enableXsrfProtection=false > frontend.log 2>&1 &")
time.sleep(5)

# 7. Generate Secure Access Link
clear_output()
port = 8501
proxy_url = output.eval_js(f"google.colab.kernel.proxyPort({port})")
print("✅ SYSTEM IS FULLY ONLINE!")
print(f"🔗 Click here to open PlantbreedAIAgent: {proxy_url}")
