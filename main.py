import requests
from fastapi import FastAPI
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
import os 
from fastapi.responses import JSONResponse

import json
import os
import time
from typing import List

from langchain_core.prompts import PromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.tools import tool
from deepagents import create_deep_agent
from pydantic import BaseModel, Field

from fastapi import FastAPI


os.environ["GOOGLE_API_KEY"] = "AIzaSyDOm-HdrKdYCcjVfQTZLON8g7niEBDKG0Q"
with open('products.json', 'r') as f:
    PRODUCTS_DATA = json.load(f)

PRODUCTS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'product.json')

llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

app = FastAPI()

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
def search_products(food_name:str):
    """Search for food products based on food name """

    result = []
    for product in PRODUCTS_DATA:
        for key, value in product.items():
            if key == 'name':
                if food_name in value:
                    result.append(product)

    return result 





llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash", temperature=0)
tools = [search_products]
agent = create_deep_agent(llm, tools)


def get_weather(city):
    url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric"

    response = requests.get(url).json()

    if response.get("cod") != 200:
        print("❌ Error:", response.get("message"))
        return

    temp = response["main"]["temp"]
    desc = response["weather"][0]["description"]

    return {"city": city, "temperature": temp, "description": desc}

get_weather("dausa")


@app.get("/weather/{city}")
def read_weather(city: str):
    weather = get_weather(city)
    return weather
@app.get("/")
def read_root():
    return {"health": "ok"}


@app.get("/query/{user_input}")
def Chat(user_input:str):
    response = llm.invoke(user_input)
    return {"response": response, "input": user_input}

@app.get("/food_query/{user_input}")
def FoodChat(user_input:str):
    response = agent.invoke({"messages": [("user", user_input)]})
    final_response = response['messages'][-1].content
    products_data = []
    for msg in response['messages']:
        if hasattr(msg, 'name') and msg.name == 'search_products':
            products_data = json.loads(msg.content)
            break

    if products_data:
        llm_with_structure = llm.with_structured_output(FoodContext)

        prompt = PromptTemplate(
            input_variables=['products_json', 'user_question', 'final_response'],
            template=PROMPT_TEMPLATE
        )

        chain = prompt | llm_with_structure

        structured_output = chain.invoke({
            "products_json": json.dumps(products_data, ensure_ascii=False),
            "user_question": "Show me food under 2000 rupees with all detail of food items",
            "final_response": final_response
        })

        result_json = structured_output.model_dump_json(indent=2)
        result = json.loads(result_json)
        return {"response": result}
    else:
        return {"response": final_response}


@app.get("/health")
def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
