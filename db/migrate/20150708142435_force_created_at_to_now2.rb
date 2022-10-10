class ForceCreatedAtToNow2 < ActiveRecord::Migration
  def change
    execute 'alter table brands alter column created_at set default now()'
    execute 'alter table brands alter column updated_at set default now()'

    execute 'alter table categories alter column created_at set default now()'
    execute 'alter table categories alter column updated_at set default now()'

    execute 'alter table products alter column created_at set default now()'
    execute 'alter table products alter column updated_at set default now()'

    execute 'alter table retailers alter column created_at set default now()'
    execute 'alter table retailers alter column updated_at set default now()'

    execute 'alter table shops alter column created_at set default now()'
    execute 'alter table shops alter column updated_at set default now()'

    execute 'alter table product_categories alter column created_at set default now()'
    execute 'alter table product_categories alter column updated_at set default now()'
  end
end
