{% macro execute_jobs(dry_run=false) -%}

  {% set job_names = var("snow_alert__jobs").split(",") %}
  {% for job_name in job_names %}
    
    {% set macro_name = "snow_alert_job__" ~ (job_name | trim) %}
    {% set call_macro = context[macro_name]  %}

    {{ call_macro(dry_run=dry_run) }}

  {% endfor %}

{%- endmacro %}