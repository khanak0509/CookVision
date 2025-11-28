import json
import os
import time
from typing import List

from langchain_core.prompts import PromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.tools import tool
from deepagents import create_deep_agent
from pydantic import BaseModel, Field


os.environ["GOOGLE_API_KEY"] = "AIzaSyC6-Ud11ezse9xCooAL8CWgBIXOmFwnQ1M"

PRODUCTS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'product.json')


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
def search_products(max_price: int):
    """Search for food products based on filters."""
    return { "products": [
            {
                "name": "Paneer Butter Masala",
                "cuisine": "Indian",
                "category": "Main Course",
                "dietary": "Vegetarian",
                "description": "Cottage cheese cubes in a rich tomato and butter gravy.",
                "price": 180,
                "rating": 4.5,
                "spice_level": "Medium",
                "id": "101",
                "image_url": "http://example.com/images/paneer_butter_masala.jpg",
                "preparation_time": 25,
                "available": True,
                "tags": ["comfort food", "rich", "creamy"]
            },
            {
                "name": "Chicken Biryani",
                "cuisine": "Indian",
                "category": "Main Course",
                "dietary": "Non-Vegetarian",
                "description": "Aromatic basmati rice cooked with marinated chicken and spices.",
                "price": 220,
                "rating": 4.7,
                "spice_level": "Hot",
                "id": "102",
                "image_url": "http://example.com/images/chicken_biryani.jpg",
                "preparation_time": 40,
                "available": True,
                "tags": ["spicy", "flavorful", "traditional"]
            }
        ]
       
    }


llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash", temperature=0)
tools = [search_products]
agent = create_deep_agent(llm, tools)

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

while True:
    user_input = input("Enter your query (or 'exit' to quit): ")
    if user_input.lower() == 'exit':
        break

    response = agent.invoke({"messages": [("user", user_input)]})
    final_response = response['messages'][-1].content
    time.sleep(2)

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
        print(result_json)
    else:
        print(final_response)
