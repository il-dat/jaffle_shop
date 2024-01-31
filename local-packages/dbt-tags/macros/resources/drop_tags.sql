{% macro drop_tags(debug=False) %}

  {# Run on release: dbt run-operation drop_tags --args '{debug: True}' #}
  {% set ns = dbt_tags.get_tags_ns() %}

  {% set query_adapter_tags_in_ns %}
  
    show tags in schema {{ ns }};
    select  "database_name" || '.' || "schema_name" || '.' || "name" as tag_name
    from    table(result_scan(last_query_id()))
    where   "database_name" || '.' || "schema_name" ilike '{{ ns }}';

  {% endset %}
  {% set adapter_tags = dbt_utils.get_query_results_as_dict(query_adapter_tags_in_ns) %}
  {% set adapter_tags = adapter_tags['TAG_NAME'] | unique | list %}
  {{ log("adapter_tags: " ~ adapter_tags, info=True) if debug }}

  {% set query -%}
    
    {% for item in adapter_tags -%}
      {% if loop.first %}
        create or replace masking policy {{ ns }}.dbt_tags__dummy as (val string) returns string -> val;
      {% endif %}
  
      alter tag {{ item }} set masking policy {{ ns }}.dbt_tags__dummy force;
      alter tag {{ item }} unset masking policy {{ ns }}.dbt_tags__dummy;
      drop tag {{ item }};

      {% if loop.last %}
        drop masking policy {{ ns }}.dbt_tags__dummy;
      {% endif %}
      
    {%- endfor %}

  {%- endset %}

  {{ log("query: " ~ (query or "nothing runs"), info=True) if execute }}
  {% if not debug and adapter_tags %}

    {{ log("[RUN]: dbt_tags.drop_tags", info=True) }}
    {% set results = run_query(query) %}
    {{ log("Completed", info=True) }}
    
  {% endif %}

{% endmacro %}