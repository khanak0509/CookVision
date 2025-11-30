from click import prompt
import requests
from fastapi import FastAPI
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
import os 
from fastapi.responses import JSONResponse
import sqlite3
import json
import os
import time
from typing import List
from uuid import uuid4
from langchain_core.prompts import PromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.tools import tool
from deepagents import create_deep_agent
from pydantic import BaseModel, Field
from fastapi import FastAPI
from langgraph.checkpoint.sqlite import SqliteSaver
from dotenv import load_dotenv


load_dotenv()
PRODUCTS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'products.json')

api_key = os.getenv("GEMINI_API_KEY")
os.environ["GOOGLE_API_KEY"] = api_key
with open(PRODUCTS_FILE, 'r') as f:
    PRODUCTS_DATA = json.load(f)
llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

app = FastAPI()

conn = sqlite3.connect("checkpoints.sqlite", check_same_thread=False)
memory = SqliteSaver(conn)


PROMPT_TEMPLATE = """
You are given:
1. A user question: {user_question}
2. A JSON array of products: {products_json}
3. agent ans: {final_response}

Your task is to generate a **single natural-language answer** summarizing the results from product details, question, and agent ans.
Put this summary inside **llm_ans**.

Then extract **all products EXACTLY as they appear** in the JSON input and put them in **product**.

Your output MUST follow this schema (Pydantic model):

{{
    "llm_ans": "string",
    "product": [ {{}} ]
}}

DO NOT modify or change product attributes.
DO NOT create multiple llm_ans.
DO NOT repeat llm_ans inside each product.
"""


API_KEY = "9071b34dca809ee3866b8a7ee048fe4e"


class Product(BaseModel):
    name: str
    cuisine: str
    category: str
    dietary: str
    description: str
    price: int
    rating: float
    spice_level: str
    id: str = Field(default="")
    image_url: str = Field(default="")
    preparation_time: int = Field(default=0)
    available: bool = Field(default=True)
    tags: List[str] = Field(default_factory=list)



class FoodContext(BaseModel):
    llm_ans: str
    product: List[Product]

@tool
def search_products(food_name: str):
    """Search for food products by matching keywords inside name."""
    result = []
    query = food_name.lower()

    for product in PRODUCTS_DATA:
        item_name = product.get("name", "").lower()

        # Split into words to match "paneer butter masala"
        if all(word in item_name for word in query.split()):
            result.append(product)

    return result



llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash", temperature=0)
tools = [search_products]
agent = create_deep_agent(llm, tools,checkpointer=memory)

def FoodChat(user_input: str = None, session_id: str = "123445"):
    """
    Interactive CLI chat with the food ordering agent.
    If user_input is provided, processes single query. Otherwise runs in loop.
    """
    config = {"configurable": {"thread_id": session_id}}
    
    # if user_input:
    #     response = agent.invoke({"messages": [("user", user_input)]}, config=config)
    #     final_response = response['messages'][-1].content
    #     print("Final Response:", final_response)
    #     products_data = []
        
    #     for msg in response['messages']:
    #         if hasattr(msg, 'name') and msg.name == 'search_products':
    #             content = msg.content
    #             if isinstance(content, str):
    #                 products_data = json.loads(content)
    #             else:
    #                 products_data = content
    #             break

    #     if products_data:
    #         llm_with_structure = llm.with_structured_output(FoodContext)
    #         prompt = PromptTemplate(
    #             input_variables=['products_json', 'user_question', 'final_response'],
    #             template=PROMPT_TEMPLATE
    #         )
    #         chain = prompt | llm_with_structure
    #         structured_output = chain.invoke({
    #             "products_json": json.dumps(products_data, ensure_ascii=False),
    #             "user_question": user_input,
    #             "final_response": final_response
    #         })
    #         result_json = structured_output.model_dump_json(indent=2)
    #         result = json.loads(result_json)
    #         return {"response": result}
    #     else:
    #         return {"response": final_response}
    
    # Interactive CLI mode
    print("\n" + "="*60)
    print("🍔 Food Ordering Chat Bot - CLI Mode")
    print("="*60)
    print("Type your food queries below.")
    print("Commands: 'quit', 'exit', 'bye' to end session")
    print("="*60 + "\n")
    
    while True:
        try:
            # Get user input
            user_query = input("You: ").strip()
            
            # Check for exit commands
            if user_query.lower() in ['quit', 'exit', 'bye', 'q']:
                print("\n👋 Thanks for chatting! Goodbye!\n")
                break
            
            # Skip empty inputs
            if not user_query:
                continue
            
            # Process the query
            print("\n🤖 Processing...\n")
            
            response = agent.invoke({"messages": [("user", user_query)]}, config=config)
            # print("Response Messages:", response['messages'])
            final_response = response['messages'][-1].content
            last_msg = response["messages"][-1]
            products_data = []

# Search inside ALL messages
            for msg in response["messages"]:
                if hasattr(msg, "type") and msg.type == "tool" and msg.name == "search_products":
                    content = msg.content
                    if isinstance(content, str):
                        products_data = json.loads(content)
                    else:
                        products_data = content
                    break  # <-- correct usage, exits only this small loop

            print("="*50)
            print("Debug - Products Data:", products_data)
            print("="*50)

            if products_data:
                llm_with_structure = llm.with_structured_output(FoodContext)
                prompt = PromptTemplate(
                    input_variables=['products_json', 'user_question', 'final_response'],
                    template=PROMPT_TEMPLATE
                )
                chain = prompt | llm_with_structure
                
                structured_output = chain.invoke({
                    "products_json": json.dumps(products_data, ensure_ascii=False),
                    "user_question": user_query,
                    "final_response": final_response
                })
                
                result_json = structured_output.model_dump_json(indent=2)
                result = json.loads(result_json)
                
                print(f"\n📦 Found {len(result['product'])} products:")
                print(result)

            else:
                print("Botpagel:", final_response)
                products_data.clear()
            
            print("\n" + "-"*60 + "\n")
            
        except KeyboardInterrupt:
            print("\n\n👋 Session interrupted. Goodbye!\n")
            break
        except Exception as e:
            print(f"\n❌ Error: {str(e)}\n")
            print("Please try again.\n")


if __name__ == "__main__":
    FoodChat()