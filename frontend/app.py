import streamlit as st
import requests
import os
import pandas as pd
from PIL import Image

# Configuration
st.set_page_config(page_title="PlantbreedAIAgent", layout="wide")
API_URL = "http://127.0.0.1:8000/chat"
WORKSPACE_IN = "/content/PlantbreedAIAgent/workspace/inputs/"
WORKSPACE_OUT = "/content/PlantbreedAIAgent/workspace/outputs/"

# Assets Configuration
ASSETS_DIR = "/content/PlantbreedAIAgent/assets/"
LOGO_PATH = os.path.join(ASSETS_DIR, "logo.png")
BANNER_PATH = os.path.join(ASSETS_DIR, "banner.jpeg")

# --- Helper Functions ---
def fetch_ai_response(user_message):
    """Sends the message to your FastAPI backend."""
    try:
        response = requests.post(API_URL, json={"message": user_message})
        if response.status_code == 200:
            return response.json().get("response")
        else:
            return f"Error connecting to engine: {response.text}"
    except Exception as e:
        return f"Backend is offline. Start it with `uvicorn api.server:app`."

# ==========================================
# HEADER: BANNER 
# ==========================================
if os.path.exists(BANNER_PATH):
    st.image(BANNER_PATH, use_container_width=True)
else:
    st.warning("Banner image not found in assets folder. Please check the path.")

st.divider()

# --- App Layout: 2 Columns ---
# Left column gets 65% of screen (Chat), Right gets 35% (Workspace)
chat_col, workspace_col = st.columns([2.2, 1])

# ==========================================
# LEFT COLUMN: THE CHAT INTERFACE
# ==========================================
with chat_col:
    # Title row with Logo
    title_col1, title_col2 = st.columns([1, 10])
    with title_col1:
        if os.path.exists(LOGO_PATH):
            st.image(LOGO_PATH, width=60)
    with title_col2:
        st.title("PlantbreedAIAgent Engine")
    
    # Initialize chat history in session state
    if "messages" not in st.session_state:
        st.session_state.messages = [
            {"role": "assistant", "content": "Hi there! I am the PlantbreedAIAgent. Upload a dataset to the workspace or ask me to run an analysis."}
        ]

    # Display chat history
    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])

    # User Input
    if prompt := st.chat_input("Ask me to analyze your trial data..."):
        # 1. Show user message
        st.session_state.messages.append({"role": "user", "content": prompt})
        with st.chat_message("user"):
            st.markdown(prompt)

        # 2. Get and show AI response
        with st.chat_message("assistant"):
            with st.spinner("Analyzing..."):
                ai_reply = fetch_ai_response(prompt)
                st.markdown(ai_reply)
        st.session_state.messages.append({"role": "assistant", "content": ai_reply})

# ==========================================
# RIGHT COLUMN: THE ACTIVE WORKSPACE
# ==========================================
with workspace_col:
    st.header("📂 Active Workspace")
    
    # 1. Force the system to create the input folder if it is missing
    os.makedirs(WORKSPACE_IN, exist_ok=True)
    
    # 2. Render the upload widget
    uploaded_file = st.file_uploader("Upload a new dataset here:", type=["csv", "xlsx"])
    
    # 3. Save the file to the input folder when dropped
    if uploaded_file is not None:
        file_path = os.path.join(WORKSPACE_IN, uploaded_file.name)
        with open(file_path, "wb") as f:
            f.write(uploaded_file.getbuffer())
        st.success(f"✅ Successfully saved {uploaded_file.name} to inputs!")
    
    # Section 1: Inputs
    st.subheader("Input Datasets")
    if os.path.exists(WORKSPACE_IN):
        inputs = os.listdir(WORKSPACE_IN)
        if inputs:
            for file in inputs:
                st.markdown(f"📄 **{file}**")
        else:
            st.caption("No datasets uploaded yet.")
    else:
        st.caption("Workspace input directory missing.")

    st.divider()

    # Section 2: Outputs (Plots and Tables)
    st.subheader("Output Visualizations")
    os.makedirs(WORKSPACE_OUT, exist_ok=True) # Ensure outputs dir exists too
    if os.path.exists(WORKSPACE_OUT):
        outputs = os.listdir(WORKSPACE_OUT)
        
        # Display PDFs/PNGs
        images = [f for f in outputs if f.endswith(('.png', '.jpg', '.jpeg'))]
        for img in images:
            st.image(os.path.join(WORKSPACE_OUT, img), caption=img, use_container_width=True)
            
        # Display PDFs
        pdfs = [f for f in outputs if f.endswith('.pdf')]
        for pdf in pdfs:
            with open(os.path.join(WORKSPACE_OUT, pdf), "rb") as file:
                st.download_button(label=f"📥 Download {pdf}", data=file, file_name=pdf, mime="application/pdf")
                
        # Display short previews of generated CSVs
        csvs = [f for f in outputs if f.endswith('.csv')]
        for csv in csvs:
            with st.expander(f"📊 {csv}"):
                df = pd.read_csv(os.path.join(WORKSPACE_OUT, csv))
                st.dataframe(df.head(10)) 
    else:
        st.caption("Waiting for analysis outputs...")
