# Architecture
## showing the window
- +AlwaysOnTop: Stays above normal windows
- -Caption: No title bar or close button
- +ToolWindow: Doesn't show up in Alt+Tab
- NoActivate : Do not steal focus from what we are doing right now

## Syntax
the `.` (Concatenation Operator) works similar to how + works in python

# librehardware monitor 
it serves info on "http://localhost:8085/data.json" , we have to set it to run on startup and run in the background forever so that we can query it always. must install it.