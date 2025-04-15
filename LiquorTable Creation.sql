CREATE OR REPLACE TABLE liquor_sales_us (
    invoice_item_number STRING,
    date DATE,
    store_number INT,
    store_name STRING,
    address STRING,
    city STRING,
    zip_code STRING,
    store_location STRING,
    county_number INT,
    county STRING,
    category INT,
    category_name STRING,
    vendor_number INT,
    vendor_name STRING,
    item_number STRING,
    item_description STRING,
    pack INT,
    bottle_volume_ml INT,
    state_bottle_cost FLOAT,
    state_bottle_retail FLOAT,
    bottles_sold INT,
    sale_dollars FLOAT,
    volume_sold_liters FLOAT,
    volume_sold_gallons FLOAT
);


COPY INTO liquor_sales_us
FROM 's3://awstestbucket8/us-liqour-sales/'
CREDENTIALS = (
    AWS_KEY_ID = 'EnterYourAuthIDHere'
    AWS_SECRET_KEY = 'EnterYourSecretKeyHere'
)

FILE_FORMAT = (TYPE = CSV, SKIP_HEADER=1, FIELD_OPTIONALLY_ENCLOSED_BY='"');

SELECT * FROM liquor_sales_us
ORDER BY store_number
LIMIT 1000



