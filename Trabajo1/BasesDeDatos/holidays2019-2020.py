# Días festivos del 2019 y 2020, para modelo en producción
from holidays_co import get_colombia_holidays_by_year
import pandas as pd
import numpy as np

dates = list()
months = list()
years = list()
days = list()
celebrations = list()
is_holiday = list()
# Iterar desde 2019-2021
for y in range(2019,2021):
    holidays_y = get_colombia_holidays_by_year(y)
    for holiday in holidays_y:
        date = holiday.date
        
        year = str(date.year)
        month = str(date.month).zfill(2)
        day = str(date.day).zfill(2)
        date_string = "{}-{}-{}".format(year,month,day)
        celebration = holiday.celebration

        # Agregar a las listas
        dates.append(date_string)
        celebrations.append(celebration)
        years.append(year)
        months.append(month)
        days.append(day)
        is_holiday.append(1)


values_dict = dict()
values_dict["date"] = dates
values_dict["celebration"] = celebrations
values_dict["year"] = years
values_dict["month"] =  months
values_dict["day"] = days
values_dict["is_holiday"] = is_holiday

df = pd.DataFrame(values_dict)

df.to_csv('holidays2019-2020.csv')