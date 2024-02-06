{% macro send_alert(query, title=none, body=none, mailing_list=none) -%}
  {{ return(adapter.dispatch('send_alert')(query=query, title=title, body=body, mailing_list=mailing_list)) }}
{%- endmacro %}

{% macro default__send_alert(
  query,
  title=none,
  body=none,
  mailing_list=none
) -%}

  {% set utcnow = modules.datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S") %}
  {% set mailing_list = mailing_list or snow_alert.get_mailing_list() %}
  {% set query -%}

    execute immediate
    $$
    declare
      failed_count number default 0;
    begin
      failed_count := (
        {{ query }}
      );
      case
        when failed_count > 0 then
          call system$send_email(
            '{{ snow_alert.create_or_get_resource() }}',
            '{{ mailing_list }}',
            '{{ title or "❄️ Snowflake Alert!"}} [' || :failed_count || '] | {{ utcnow }} (UTC)',
            '{{ body or 
            ("
              <p>The most recent job run details can be found at 
              <a 
                href=\"https://" ~ var("snow_alert__dbt_cloud_access_url") ~ "/deploy/" ~ env_var("DBT_CLOUD_ACCOUNT_ID", "manual") ~ "
                /projects/" ~ env_var("DBT_CLOUD_PROJECT_ID", "manual") ~ "
                /runs/" ~ env_var("DBT_CLOUD_RUN_ID", "manual") ~ "\" >
              
                Job Run [" ~ env_var("DBT_CLOUD_RUN_ID", "manual") ~ "]

              </a>
              </p>
              <p>
                <details>
                  <summary>Check query used as follows:</summary>
                  <pre><code> {{ query }} </code></pre>
                </details>
              </p>
            ")}}',
            'text/html'
          );
          return 'Alert is in queue 🕥';
        else
          return 'All good ✅!';
      end;
    end;
    $$;

  {%- endset %}

  {{ return(query) }}

{%- endmacro %}