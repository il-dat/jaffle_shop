{% macro create_or_get_resource(create=false, assign_to_role=none) -%}

  {% set integration_name = "ni_snow_alert_" ~ project_name ~ "_" ~ target.name %}
  {% set assign_to_role = assign_to_role or ("role_transform_" ~ target.name) %}
  {% set allowed_emails = snow_alert.get_mailing_list() %}
  {% set query -%}

    use role accountadmin;
    create or replace notification integration {{ integration_name }}
      type = email
      allowed_recipients = ('{{ allowed_emails }}')
      enabled = true
      comment = "{{ target.name | upper }} Notification Integration object used for {{ project_name }} dbt project";
    grant usage on integration {{ integration_name }} to role {{ assign_to_role }};

  {%- endset %}

  {{ log("query: " ~ query, info=True) if create }}
  {{ return(integration_name) }}
  
{%- endmacro %}