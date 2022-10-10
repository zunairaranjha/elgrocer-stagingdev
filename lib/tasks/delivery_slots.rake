namespace :delivery_slots do
	desc 'Update the Delivery Slots materialized view'
	task :update_available_slots_view => :environment do
		AvailableSlot.refresh
	end


	desc 'Update the Delivery Slots Capacity materialized view'
	task :update_slots_capacity_view => :environment do
		AvailableSlot.refresh_capacity
	end
end