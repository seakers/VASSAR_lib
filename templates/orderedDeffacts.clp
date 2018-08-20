(deffacts {{name}}

{% for fact in facts %}
    ({{template}}

{% for slot in fact %}
{% if slot.matches("\[(.+)(,(.+))+\]") %}
        ({{ slotNames[loop.index] }} {{ createJessList(slot) }})
{% else %}
        ({{ slotNames[loop.index] }} {{ slot }})
{% endif %}
{% endfor %}
        (factHistory F{{ startingNof + loop.index }}))

{% endfor %}
)