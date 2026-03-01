List<Map<String, dynamic>> timeFormat = [
  {"H:i:s": "24-hour format - 15:45:30"},
  {"h:i:s A": "12-hour format AM/PM uppercase - 03:45:30 PM"},
  {"h:i:s a": "12-hour format AM/PM lowercase - 03:45:30 pm"},
];
List<Map<String, dynamic>> dateFormat = [
  {"DD-MM-YYYY|d-m-Y": "Day-Month-Year with leading zero (04-08-2023)"},
  {"D-M-YY|j-n-y": "Day-Month-Year with no leading zero (4-8-23)"},
  {"MM-DD-YYYY|m-d-Y": "Month-Day-Year with leading zero (08-04-2023)"},
  {"M-D-YY|n-j-y": "Month-Day-Year with no leading zero (8-4-23)"},
  {"YYYY-MM-DD|Y-m-d": "Year-Month-Day with leading zero (2023-08-04)"},
  {"YY-M-D|Y-n-j": "Year-Month-Day with no leading zero (23-8-4)"},
  {
    "MMMM DD, YYYY|F d, Y":
        "Month name-Day-Year with leading zero (August 04, 2023)"
  },
  {
    "MMM DD, YYYY|M d, Y":
        "Month abbreviation-Day-Year with leading zero (Aug 04, 2023)"
  },
  {
    "DD-MMM-YYYY|d-M-Y":
        "Day with leading zero, Month abbreviation, Year (04-Aug-2023)"
  },
  {
    "DD MMM, YYYY|d M, Y":
        "Day with leading zero, Month abbreviation, Year (04 Aug, 2023)"
  },
  {
    "YYYY-MMM-DD|Y-M-d":
        "Year, Month abbreviation, Day with leading zero (2023-Aug-04)"
  },
  {
    "YYYY, MMM DD|Y, M d":
        "Year, Month abbreviation, Day with leading zero (2023, Aug 04)"
  },
];
