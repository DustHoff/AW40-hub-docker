from enum import Enum

from beanie import Document, Indexed
from pydantic import BaseModel


class Component(str, Enum):
    """All the components that a vehicle can have."""
    battery = "Batterie"
    maf_sensor = "Luftmassenmesser"
    lambda_sensor_before_cat = "Lambda Sonde (vor Kat)"
    lambda_sensor_behind_cat = "Lambda Sonde (nach Kat)"
    boost_pressure_solenoid_valve = "Ladedruck-Magnetventil"
    boost_pressure_control_valve = "Ladedruck-Regelventil"
    tc_boost_control_position_sensor = "Ladedrucksteller-Positionssensor"
    engine_control_unit = "Motor-Steuergerät"
    variable_nozzle_tc = "VTG-Abgasturbolader"


class Vehicle(Document):

    class Config:
        # 'vin' is used instead of 'id'
        fields = {"id": {"exclude": True}}

    class Settings:
        name = "vehicles"

    vin: Indexed(str, unique=True)
    tsn: str = None
    year_build: int = None


class VehicleUpdate(BaseModel):
    tsn: str = None
    year_build: int = None
