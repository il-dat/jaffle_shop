{% macro sample__job1_alert(dry_run=false) %}

  {% set alert_query -%}

    /*
      <Your rule description>
    */
    with failures as (

      select  max(<timestamp>) as max_<timestamp>
      from    {{ ref('<hidden') }}

    )
    select  count(*) as failed_count
    from    failures
    where   1=1
      and   <your sql rule e.g. datediff(hour, max_<timestamp>, sysdate()) > 3>

  {%- endset %}
  
  {% set query -%}
    
    {{ snow_alert__run(
        query=alert_query,
        title="⚠️ Data Freshness Alert - <short rule>"
    ) }}
    
  {%- endset %}

  {{ log("query: " ~ query, info=True) if execute }}
  {% if not dry_run %}
    {{ log("[RUN]: sample__job1_alert", info=True) if execute }}
    {% set results = run_query(query) %}
    {{ log("Completed: " ~ results.print_json(), info=True) }}
  {% endif %}

{% endmacro %}