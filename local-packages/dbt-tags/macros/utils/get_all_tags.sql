{% macro get_all_tags(resource_types=["model", "snapshot", "source"], debug=False) %}

  {% set found_tags = [] %}

  {% for relation in graph.nodes.values() if (relation.resource_type | lower) in resource_types %}
    {% do found_tags.extend(dbt_tags.get_relation_tags(relation=relation, debug=debug)) %}
  {% endfor %}

  {% for relation in graph.sources.values() if (relation.resource_type | lower) in resource_types %}
    {% do found_tags.extend(dbt_tags.get_relation_tags(relation=relation, debug=debug)) %}
  {% endfor %}

  {{ return(found_tags) }}

{% endmacro %}