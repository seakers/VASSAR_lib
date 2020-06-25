(defrule CAPABILITIES::XIE-measurements 
"Define measurement capabilities of instrument XIE"
?this <- (CAPABILITIES::Manifested-instrument  (Name XIE) (Id ?id) (flies-in ?miss) (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano) )
 => 
(assert (REQUIREMENTS::Measurement (Parameter "A8.Total electron content in ionosphere")  (Region-of-interest Global)  (Coverage-of-region-of-interest Global)  (Accuracy High)  (taken-by XIE)  (flies-in ?miss)  (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano)  (Id XIE1) (Instrument XIE ) ))
(assert (REQUIREMENTS::Measurement (Parameter "5.1.3 Space weather -solar X-ray/EUV, energetic particles, ionosphere-")  (Region-of-interest Global)  (Coverage-of-region-of-interest Global)  (Accuracy High)  (taken-by XIE)  (flies-in ?miss)  (orbit-altitude# ?h) (orbit-RAAN ?raan) (orbit-anomaly# ?ano)  (Id XIE2) (Instrument XIE ) ))
(assert (SYNERGIES::cross-registered (measurements  XIE1  XIE2  ) (degree-of-cross-registration  instrument) (platform ?id  )))(modify ?this (measurement-ids  XIE1  XIE2 )))
