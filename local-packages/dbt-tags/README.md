<!-- markdownlint-disable no-inline-html no-alt-text ul-indent code-block-style -->
# dbt-tags [EXPERIMENTAL]

Tag-based masking policies management in Snowflake ❄️

## Installation

> Working as the local package as of now ⚠️

## Quick Start

### 1. Persist dbt tags as Snowflake object's tags

All dbt tags are allowed by default. If needed, let's define your list of tags with the below example:

- In `customers.yml`:

  ```yml
  models:
    - name: customers
      tags: 
        - jf
      columns:
        - name: customer_id
        - name: first_name
          tags: 
            - pii_name
            - abc
  ```

- In `dbt_project.yml`:

  ```yml
  vars:
    dbt_tags__allowed_tags: 
      - pii_name
      - pii_amount
  ```

  > So, only `first_name` column's tag (`pii_name`) is selected

Then, go create the Snowflake tags:

```bash
dbt run-opertion create_tags
```

<details>
  <summary>Sample logs</summary>

```log
03:17:12  Running with dbt=1.7.6
03:17:12  Registered adapter: snowflake=1.7.1
03:17:12  Found 5 models, 3 seeds, 21 tests, 2 sources, 1 exposure, 0 metrics, 552 macros, 0 groups, 0 semantic models
03:17:12  query:
create schema if not exists common.tags;
create tag if not exists common.tags.pii_name
  with comment = 'PROD - jaffle_shop''s dbt managed tags | context: {"level": "model.customers.column", "name": "first_name", "tag": "pii_name"}';
create tag if not exists common.tags.pii_amount
  with comment = 'PROD - jaffle_shop''s dbt managed tags | context: {"level": "model.orders.column", "name": "amount", "tag": "pii_amount"}';
03:17:12  [RUN]: dbt_tags.create_tags
03:17:14  Completed
```

</details>

### 2. Create masking policy functions & Apply to tags

TODO

### 3. Apply tags to columns on every run(s)

Configure the model's `post-hook` in the `dbt_project.yml` file as follows:

```yml
models:
  jaffle_shop:
    post-hook:
      - >
        {% if flags.WHICH in ('run', 'build') %}
          {{ dbt_tags.apply_column_tags() }}
        {% endif %}
```

<details>
  <summary>Sample logs</summary>
```bash
dbt run -s customers orders
```

```log
03:17:20  Running with dbt=1.7.6
03:17:20  Registered adapter: snowflake=1.7.1
03:17:20  Found 5 models, 3 seeds, 21 tests, 2 sources, 1 exposure, 0 metrics, 552 macros, 0 groups, 0 semantic models
03:17:20  
03:17:24  Concurrency: 1 threads (target='prod')
03:17:24  
03:17:24  1 of 2 START sql table model DAT.customers ..................................... [RUN]
03:17:26  dbt_tags.apply_column_tags - Set tag [common.tags.pii_name] on column [demo.DAT.customers:first_name]
03:17:27  1 of 2 OK created sql table model DAT.customers ................................ [SUCCESS 1 in 3.50s]
03:17:27  2 of 2 START sql table model DAT.orders ........................................ [RUN]
03:17:29  dbt_tags.apply_column_tags - Set tag [demo.tags.pii_amount] on column [demo.DAT.orders:amount]
03:17:30  2 of 2 OK created sql table model DAT.orders ................................... [SUCCESS 1 in 2.67s]
03:17:30  
03:17:30  Finished running 2 table models in 0 hours 0 minutes and 9.81 seconds (9.81s).
03:17:30  
03:17:30  Completed successfully
03:17:30  
03:17:30  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
```

</details>

## TODO

What's up! Enjoy 🎉
