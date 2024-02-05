{% macro sample__alerts(dry_run=false) %}

  {{ sample__job1_alert(dry_run=dry_run) }}
  {# {{ sample__job2_alert(dry_run=dry_run) }} #}

{% endmacro %}