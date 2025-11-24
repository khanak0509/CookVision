import requests
from fastapi import FastAPI
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import PromptTemplate
import os 


os.environ["GOOGLE_API_KEY"] = "AIzaSyAZfeSc6Db1h-0pBxh24XI_8ZIRtSgL3VM"
llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

app = FastAPI()


API_KEY = "9071b34dca809ee3866b8a7ee048fe4e"

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



    
    


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
