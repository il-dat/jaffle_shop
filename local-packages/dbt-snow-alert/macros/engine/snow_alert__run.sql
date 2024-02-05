{% macro snow_alert__run(
  query,
  title=none,
  emails=env_var("DBT_CLOUD_ALERT_EMAILS", "<hidden>@<hidden>.slack.com")
) -%}

  {% set utcnow = modules.datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S") %}
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
            '{{ snow_alert__create_or_get_resource() }}',
            '{{ emails }}',
            '{{ title or "❄️ Snowflake Alert!"}} [' || :failed_count || '] | {{ utcnow }} (UTC)',
            '
              <p>The most recent job run details can be found at <a href="https://YOUR_ACCESS_URL/deploy/{{ env_var('DBT_CLOUD_ACCOUNT_ID', 'manual') }}/projects/{{ env_var('DBT_CLOUD_PROJECT_ID', 'manual') }}/runs/{{ env_var('DBT_CLOUD_RUN_ID', 'manual') }}" >runs/{{ env_var('DBT_CLOUD_RUN_ID', 'manual') }}</a></p>
              <p>
                <details>
                  <summary>▶️ Check query used as follows:</summary>
                  <pre><code> {{ query }} </code></pre>
                </details>
              </p>
            ',
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