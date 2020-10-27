from holidays_co import get_colombia_holidays_by_year
import pandas as pd
import numpy as np

year_dict= {
                2014: {
                            "Día de la Mujer":"2014-03-08",
                            "Domingo de Ramos":"2014-04-13",
                            "Sábado Santo":"2014-04-19",
                            "Domingo Santo":"2014-04-20",
                            "Día de la Madre":"2014-05-11",
                            "Día del Padre":"2014-06-15",  
                            "Feria de las Flores":["2014-08-01","2014-08-02","2014-08-03","2014-08-08", "2014-08-09", "2014-08-10"],
                            "Día de Amor y Amistad":"2014-09-20",
                            "Halloween":"2014-10-31",
                            "Alborada":"2014-11-30",
                            "Día de las velitas":"2014-12-07",
                            "Víspera de Navidad":"2014-12-24",
                            "Fin de Año":"2014-12-31"  
                        },
                2015: {
                            "Día de la Mujer":"2015-03-08",
                            "Domingo de Ramos":"2015-03-29",
                            "Sábado Santo":"2015-04-04",
                            "Domingo Santo":"2015-04-05",
                            "Día de la Madre":"2015-05-10",
                            "Día del Padre":"2015-06-21",  
                            "Feria de las Flores":["2015-07-31","2015-08-01","2015-08-02","2015-08-08", "2015-08-09"],
                            "Día de Amor y Amistad":"2015-09-19",
                            "Halloween":"2015-10-31",
                            "Alborada":"2015-11-30",
                            "Día de las velitas":"2015-12-07",
                            "Víspera de Navidad":"2015-12-24",
                            "Fin de Año":"2015-12-31" 
                },
                2016: {
                            "Día de la Mujer":"2016-03-08",
                            "Domingo de Ramos":"2016-03-20",
                            "Sábado Santo":"2016-03-26",
                            "Domingo Santo":"2016-03-27",
                            "Día de la Madre":"2016-05-08",
                            "Día del Padre":"2016-06-19",  
                            "Feria de las Flores":["2016-07-29","2016-07-30","2016-07-31","2016-08-05","2016-08-06"],
                            "Día de Amor y Amistad":"2016-09-17",
                            "Halloween":"2016-10-31",
                            "Alborada":"2016-11-30",
                            "Día de las velitas":"2016-12-07",
                            "Víspera de Navidad":"2016-12-24",
                            "Fin de Año":"2016-12-31", 
                },
                2017: {
                            "Día de la Mujer":"2017-03-08",
                            "Domingo de Ramos":"2017-04-09",
                            "Sábado Santo":"2017-04-15",
                            "Domingo Santo":"2017-04-16",
                            "Día de la Madre":"2017-05-14",
                            "Día del Padre":"2017-06-18",  
                            "Feria de las Flores":["2017-07-28","2017-07-29","2017-07-30","2017-08-04", "2017-08-05", "2017-08-06"],
                            "Día de Amor y Amistad":"2017-09-16",
                            "Halloween":"2017-10-31",
                            "Alborada":"2017-11-30",
                            "Día de las velitas":"2017-12-07",
                            "Víspera de Navidad":"2017-12-24",
                            "Fin de Año":"2017-12-31", 
                },
                2018: {
                            "Día de la Mujer":"2018-03-08",
                            "Domingo de Ramos":"2018-03-25",
                            "Sábado Santo":"2018-03-31",
                            "Domingo Santo":"2018-03-1",
                            "Día de la Madre":"2018-05-13",
                            "Día del Padre":"2018-06-17",  
                            "Feria de las Flores":["2018-08-03","2018-08-04","2018-08-05","2018-08-10", "2018-08-11","2018-08-12"],
                            "Día de Amor y Amistad":"2018-09-15",
                            "Halloween":"2018-10-31",
                            "Alborada":"2018-11-30",
                            "Día de las velitas":"2018-12-07",
                            "Víspera de Navidad":"2018-12-24",
                            "Fin de Año":"2018-12-31", 
                }       
            }


dates = list()
months = list()
years = list()
days = list()
celebrations = list()
is_holiday = list()
# Iterar desde 2014-2018
for y in range(2014,2019):
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

    specials_y = year_dict[y]

    celebrations_k = specials_y.keys()
    # Iterar sobre los días especiales
    for celebration in celebrations_k:
        # Revisar si es una lista, o una cadena
        if (isinstance(specials_y[celebration],list)):
            for date in specials_y[celebration]:
                date_string = date
                [year,month,day] = date_string.split("-")
                dates.append(date_string)
                celebrations.append(celebration)
                years.append(year)
                months.append(month)
                days.append(day)
                is_holiday.append(0)
        else:
            date_string = specials_y[celebration]
            [year,month,day] = date_string.split("-")
            dates.append(date_string)
            celebrations.append(celebration)
            years.append(year)
            months.append(month)
            days.append(day)
            is_holiday.append(0)


values_dict = dict()
values_dict["date"] = dates
values_dict["celebration"] = celebrations
values_dict["year"] = years
values_dict["month"] =  months
values_dict["day"] = days
values_dict["is_holiday"] = is_holiday

df = pd.DataFrame(values_dict)

df.to_csv('holidays.csv')