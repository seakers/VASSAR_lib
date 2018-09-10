(deftemplate REQUIREMENTS::Measurement
{% for slot in slots %}
    ({{slot.type}} {{slot.name}})
{% endfor %}
)