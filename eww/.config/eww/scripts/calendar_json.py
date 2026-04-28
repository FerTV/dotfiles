import calendar
import json
import datetime
import sys

# Set Monday as first day (0)
cal = calendar.Calendar(firstweekday=0)

today = datetime.date.today()
year = today.year
month = today.month

# Check if arguments provided (simple support)
if len(sys.argv) > 2:
    try:
        year = int(sys.argv[2])
        month = int(sys.argv[1])
    except:
        pass

# Get names
month_name = calendar.month_name[month]
# days header: Mo Tu We ...
day_headers = list(calendar.day_abbr)
# Rotate if needed, but Calendar(0) aligns days automatically,
# BUT we need headers to match [0,1,2,3,4,5,6] where 0 is Monday.
# calendar.day_abbr is always [Mon, Tue... Sun] in English locale.
# If we want Spanish, we can try setting locale in python, but user system is limited.
# We'll stick to English headers or hardcode Spanish if preferred?
# User speaks Spanish. Let's try to provide Spanish headers if simple.
# day_headers = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"]
# The user's screenshot was in English. I'll stick to English to match the "January" in screenshot.
day_headers = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

month_days = cal.monthdayscalendar(year, month)

weeks = []
for week in month_days:
    w_days = []
    for day in week:
        d_class = "day"
        if day == 0:
            d_class = "empty"
        elif day == today.day and month == today.month and year == today.year:
            d_class = "today"
        
        w_days.append({
            "number": str(day) if day != 0 else "",
            "class": d_class
        })
    weeks.append(w_days)

data = {
    "month": month_name,
    "year": str(year),
    "headers": day_headers,
    "weeks": weeks
}

print(json.dumps(data))
