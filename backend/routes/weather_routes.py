"""
Weather routes for fetching weather data based on location
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
# import httpx  # Uncomment when integrating with OpenWeatherMap API

router = APIRouter()


class WeatherRequest(BaseModel):
    latitude: float
    longitude: float


class WeatherResponse(BaseModel):
    temperature: float
    max: float
    min: float
    feels_like: float
    condition: str
    humidity: Optional[float] = None
    wind_speed: Optional[float] = None


@router.post("/weather", response_model=WeatherResponse)
async def get_weather(request: WeatherRequest):
    """
    Get weather data for a given location
    Uses OpenWeatherMap API (free tier) or returns mock data
    """
    try:
        # For now, return mock weather data based on location
        # In production, integrate with OpenWeatherMap API:
        # API_KEY = "your_openweathermap_api_key"
        # url = f"https://api.openweathermap.org/data/2.5/weather?lat={request.latitude}&lon={request.longitude}&appid={API_KEY}&units=metric"
        # async with httpx.AsyncClient() as client:
        #     response = await client.get(url)
        #     data = response.json()
        #     return WeatherResponse(
        #         temperature=data['main']['temp'],
        #         max=data['main']['temp_max'],
        #         min=data['main']['temp_min'],
        #         feels_like=data['main']['feels_like'],
        #         condition=data['weather'][0]['main'],
        #         humidity=data['main']['humidity'],
        #         wind_speed=data['wind']['speed'] if 'wind' in data else None
        #     )
        
        # Mock weather data - varies slightly based on location
        # Tunisia coordinates range: lat ~30-37, lon ~7-12
        base_temp = 26.0
        if 30 <= request.latitude <= 37 and 7 <= request.longitude <= 12:
            # Tunisia region - adjust temperature slightly
            base_temp = 28.0 + (request.latitude - 33) * 0.5
        
        return WeatherResponse(
            temperature=round(base_temp, 1),
            max=round(base_temp + 2, 1),
            min=round(base_temp - 2, 1),
            feels_like=round(base_temp + 5, 1),
            condition="Nuageux",
            humidity=60.0,
            wind_speed=12.0
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching weather: {str(e)}")

