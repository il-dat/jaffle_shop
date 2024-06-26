<!-- markdownlint-disable no-inline-html no-alt-text ul-indent code-block-style -->
# Snowflake Alerts ❄️

Managing the native Snowflake [Notification](https://docs.snowflake.com/en/user-guide/email-stored-procedures) with dbt 🚀

## Installation

> Working as the local package as of now ⚠️

## Usage

### 1. Create your job macro

Take a look at our sample at [`sample-jobs/snow_alert_job__sample_1.sql`](./macros/sample-jobs/snow_alert_job__sample_1.sql). Note: the macro name MUST start with `snow_alert_job__` ❗

Your job name is `sample_1` in this case.

### 2. Decide to run the alert job(s)

Add a new step to the dbt (Cloud) Job, it should be the last step with the following command:

```bash
dbt run-operation execute_jobs --vars '{snow_alert__jobs: YOUR_JOB_NAMES}'

# for a dry run
dbt run-operation execute_jobs --vars '{snow_alert__jobs: YOUR_JOB_NAMES}' --args '{dry_run: true}'
```

> `YOUR_JOB_NAMES`: can have multiple values splitted by comma

In the above sample, your command is:

```bash
dbt run-operation execute_jobs --vars '{snow_alert__jobs: sample_1}'
# or: dbt run-operation execute_jobs --vars '{snow_alert__jobs: sample_1}' --args '{dry_run: true}'
```

```log
07:39:22  Running with dbt=1.7.6
07:39:23  Registered adapter: snowflake=1.7.1
07:39:23  Found 5 models, 3 seeds, 21 tests, 2 sources, 1 exposure, 0 metrics, 568 macros, 0 groups, 0 semantic models
07:39:23  [RUN]: snow_alert_job__sample_1"
07:39:24  Alert is in queue 🕥
```

## Production Readiness

## 1. Create a Snowflake User and get the email address verified

We need an associated Snowflake User that holds the alert audience's email address.

Login to Snowflake using this new user's credential and **get the email verification done** ❗

👉 Sample script for User creation:

```sql
use role securityadmin;
create or replace user user_slack_email_alert with
  password='<hidden>'
  email = 'sample@domain.com';
```

## 2. Create the Notification Integration object

Make sure that the Notification Integration object gets created manually first using the `ACCOUNTADMIN` role.

Its script will be generated by the `engine/create_or_get_resource` macro:

```bash
dbt run-operation create_or_get_resource --args '{create: true}'
```

Sample generated script:
  
```sql
use role accountadmin;

create or replace notification integration <YOUR_NOTIFICATION_INTEGRATION_NAME>
  type = email
  enabled = true
  allowed_recipients = ('sample@domain.com')
  comment = "PROD Notification Integration object used for <PROJECT_NAME> dbt project";
grant usage on integration <YOUR_NOTIFICATION_INTEGRATION_NAME> to role <YOUR_DBT_ROLE_NAME>;
```

## 3. Decide to configure the alerts

Refers to the [Usage](#usage) section to implement your alert jobs, then find the dbt command and configure it into the dbt Cloud Job
