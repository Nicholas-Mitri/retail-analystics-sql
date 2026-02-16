#!/bin/bash

# Configuration
DB_NAME="retail_analytics"
DB_USER="root"

# Check if password environment variable is set
if [ -z "$MYSQL_PASSWORD" ]; then
    echo "Error: MYSQL_PASSWORD environment variable is not set"
    echo "Usage: export MYSQL_PASSWORD='your_password'"
    exit 1
fi

# Execute SQL files
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/schema/01_create_database.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/schema/02_create_tables.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/schema/05_create_triggers.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/data/insert_sample_data.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/schema/06_create_triggers_after_data_insert.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/schema/04_create_constraints.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/schema/03_create_indexes.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/procedures/customer_procedures.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/procedures/inventory_procedures.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/functions/analytics_functions.sql
mysql -u "$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < database/views/business_views.sql

echo "Database setup complete!"
