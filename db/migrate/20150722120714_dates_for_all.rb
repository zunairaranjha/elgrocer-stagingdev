class DatesForAll < ActiveRecord::Migration
  def change
    execute 'ALTER TABLE brands ALTER COLUMN created_at TYPE timestamp with time zone'
    execute 'ALTER TABLE brands ALTER COLUMN updated_at TYPE timestamp with time zone'
    execute 'ALTER TABLE brands ALTER COLUMN photo_updated_at TYPE timestamp with time zone'

    execute 'ALTER TABLE categories ALTER COLUMN created_at TYPE timestamp with time zone'
    execute 'ALTER TABLE categories ALTER COLUMN updated_at TYPE timestamp with time zone'
    execute 'ALTER TABLE categories ALTER COLUMN photo_updated_at TYPE timestamp with time zone'

    execute 'ALTER TABLE orders ALTER COLUMN created_at TYPE timestamp with time zone'
    execute 'ALTER TABLE orders ALTER COLUMN updated_at TYPE timestamp with time zone'
    execute 'ALTER TABLE orders ALTER COLUMN approved_at TYPE timestamp with time zone'
    execute 'ALTER TABLE orders ALTER COLUMN processed_at TYPE timestamp with time zone'
    execute 'ALTER TABLE orders ALTER COLUMN accepted_at TYPE timestamp with time zone'

    execute 'ALTER TABLE product_categories ALTER COLUMN created_at TYPE timestamp with time zone'
    execute 'ALTER TABLE product_categories ALTER COLUMN updated_at TYPE timestamp with time zone'

    execute 'ALTER TABLE products ALTER COLUMN created_at TYPE timestamp with time zone'
    execute 'ALTER TABLE products ALTER COLUMN updated_at TYPE timestamp with time zone'
    execute 'ALTER TABLE products ALTER COLUMN photo_updated_at TYPE timestamp with time zone'

    execute 'ALTER TABLE retailers ALTER COLUMN created_at TYPE timestamp with time zone'
    execute 'ALTER TABLE retailers ALTER COLUMN updated_at TYPE timestamp with time zone'
    execute 'ALTER TABLE retailers ALTER COLUMN photo_updated_at TYPE timestamp with time zone'

    execute 'ALTER TABLE shopper_addresses ALTER COLUMN created_at TYPE timestamp with time zone'

    execute 'ALTER TABLE shoppers ALTER COLUMN created_at TYPE timestamp with time zone'
    execute 'ALTER TABLE shoppers ALTER COLUMN updated_at TYPE timestamp with time zone'

    execute 'ALTER TABLE shops ALTER COLUMN created_at TYPE timestamp with time zone'
    execute 'ALTER TABLE shops ALTER COLUMN updated_at TYPE timestamp with time zone'

  end
end
