(deffunction ContainsBands (?list-bands ?desired-bands)
    "Returns true if the list of bands contains the desired bands"
    (if (subsetp ?desired-bands ?list-bands) then
        (return TRUE)
    else
        (return FALSE)))