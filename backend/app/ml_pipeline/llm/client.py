# app/llm/client.py

import openai
from dotenv import load_dotenv
import os

# Load the environment variables from the .env file
load_dotenv()

def get_llm_client():
    openai.api_key = os.getenv("OPENAI_API_KEY")
    client = openai
    return client
