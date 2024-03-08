

with customers as (

    select * from {{ ref('stg_customers') }}

),
    
check_valid_emails as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customers.last_name != customers.first_name as is_valid_customer_name
    from customers

)

select * from check_valid_emails