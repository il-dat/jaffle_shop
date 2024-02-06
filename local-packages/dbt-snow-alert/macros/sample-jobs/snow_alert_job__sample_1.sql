{% macro snow_alert_job__sample_1(dry_run=false) %}

  {% set alert_query -%}

    /*
      <Your rule description>
    */
    with failures as ( -- your query should be the same approach as dbt singuar test query

      select  1

    )
    select  count(*) as failed_count
    from    failures
    where   1=1
      and   -- your condition to implement the rule e.g. datediff(hour, max_<timestamp>, sysdate()) > 3

  {%- endset %}
  {% set alert_title = "⚠️ Sample Alert" %} {# your concise email title #}
  {# {% set alert_body = "Optional" %} specify if you'd like to override the default email body  #}
  
  {% set query -%}

    {{ snow_alert.send_alert(query=alert_query, title=alert_title) }}
    {# {{ snow_alert.send_alert(query=alert_query, title=alert_title, body=alert_body) }} #}
    
  {%- endset %}

  {{ log("query: " ~ query, info=True) if execute }}
  {% if not dry_run %}
    {{ log("[RUN]: snow_alert_job__sample_1", info=True) if execute }}
    {% set results = run_query(query) %}
    {{ log("Completed: " ~ results.print_json(), info=True) }}
  {% endif %}

{% endmacro %}