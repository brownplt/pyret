#lang pollen

◊p{
   In many languages, the only easy way to examine values during program execution is
   by using print commands, leading to what is often called “printf-debugging”.
   Pyret recognizes the value of examining dynamic values and provides an elegant
   way of doing this:
   ◊link/new-tab["https://pyret.org/docs/latest/s_spies.html"]{spies}.
   Unlike with a “printf”, spying presents well-formatted output: you can trace back
   to the source, the output looks different to distinguish from other printed output,
   values in the display are clickable, etc.
}
