(deffunction update-objective-variable (?obj ?new-value)
    "Update the value of the global variable with the new value only if it is better"
    (bind ?obj (max ?obj ?new-value)))