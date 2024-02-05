{% macro snow_alert__create_or_get_resource(create=false) -%}

  {% set integration_name = "<YOUR NOTIFICATION INTEGRATION NAME>" ~ target.name %}
  {% set allowed_emails = env_var("DBT_CLOUD_ALERT_EMAILS", "<hidden>@<hidden>.slack.com") %}
  {% set query -%}

    use role accountadmin;
    create or replace notification integration {{ integration_name }}
      type = email
      allowed_recipients = ('{{ allowed_emails }}')
      enabled = true
      comment = "{{ target.name | upper }} Notification Integration object used for SB_IL dbt project";
    grant usage on integration {{ integration_name }} to role role_transform_{{ target.name }};

  {%- endset %}

  {{ log("query: " ~ query, info=True) if create }}
  {{ return(integration_name) }}
  
{%- endmacro %}