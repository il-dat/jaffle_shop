{% macro get_mailing_list() -%}

  {{ return(var("snow_alert__mailing_list", env_var("DBT_CLOUD_MAILING_LIST", ""))) }}
  
{%- endmacro %}