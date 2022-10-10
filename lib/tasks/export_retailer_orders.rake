namespace :retailer_orders do
  desc "Export retailer orders"
  task export: :environment do

  @days = ENV['days_from'].to_i || 1
  @days_to = ENV['days_to'].to_i
  @retailer_ids = ENV['storeids']

  @startDate = @days.day.ago.to_date
  @endDate = @days_to.day.ago.to_date || Time.now.to_date
  # puts "Fetch retailers #{@retailer_ids}..."
  if @retailer_ids.blank?
    retailers = Retailer.where(is_active: true, is_generate_report: true) #.order(:id).all
  else
    retailers = Retailer.where(id: @retailer_ids.split(','))
  end
  
  order_headers = ['Order ID','Cust. Name','Cust. Email','Cust. Phone','Cust. Order Count','Order Date','Order Time','Address','Area','Phone','Order Amount','Payment Method','Acceptance Duration','Attending Duration','Special Instructions','Cancel_message', 'Status ID']
  order_position_headers = ['OrderID','Barcode','Name','Quantity','Amount','Availability']

  retailers.each do |retailer|
    puts "Fetch orders for retailer_id: #{retailer.id}..."
    excel_path =  "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}.xlsx")
    order_path =  "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}_summery.csv") #Tempfile.new('orders-')
    order_position_path =  "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}_orderdetail.csv")
    data_rows = []
    orders = retailer.orders.where.not(retailer_id: nil).where('created_at BETWEEN ? AND ?', @startDate, @endDate).order('created_at DESC')
      #.order('created_at DESC')
    #file_csv = CSV.generate do |csv|
    #CSV.open(order_path, "wb") do |csv|
        #csv << order_headers #Order.column_names
    orders.each do |order|
      order_count = Order.where(shopper_id: order.shopper_id, retailer_id: order.retailer_id).count
      # order_amount = OrderPosition.where(order_id: order.id).sum(:shop_price_cents)
      order_amount = order.order_positions.sum('ROUND(ROUND((order_positions.shop_price_dollars + (order_positions.shop_price_cents::numeric / 100)), 2) * order_positions.amount, 2)')
      payment_method = order.payment_type_id == 1 ? 'cash' : 'card'
      shopper_address = "#{order.shopper_address_apartment_number},#{order.shopper_address_building_name},#{order.shopper_address_street},#{order.shopper_address_area}"
      acceptance_duration =  order.accepted_at ? (order.accepted_at - order.created_at).to_i / 60 : 'NA'
      attending_duration = order.approved_at ? (order.approved_at - order.created_at).to_i / 60 : 'NA'
      shopper_email = retailer.is_report_add_phone ? order.shopper.email : ''
      shopper_phone = retailer.is_report_add_email ? order.shopper_phone_number : ''
      data_rows.push([order.id,order.shopper_name,shopper_email,shopper_phone,order_count,order.created_at,order.created_at,shopper_address,order.shopper_address_area,order.shopper_phone_number,order_amount,payment_method,acceptance_duration,attending_duration,order.shopper_note,order.message, order.status_id]) 
      #order.attributes.values
    end
    #end
    self.insertDataIntoCsv(order_path, order_headers, data_rows)

    # puts "Fetch order positions"
    position_data_rows = []
    order_positions = retailer.order_positions.where(order_id: orders)
    #CSV.open(order_position_path, "wb") do |csv|
    #    csv << order_position_headers #Order.column_names
    order_positions.each do |position|
      position_amount = ((position.shop_price_dollars + (position.shop_price_cents / 100.0)).round(2) * position.amount).round(2)
      position_data_rows.push([position.order_id,position.product_barcode,position.product_name,position.amount,position_amount,position.was_in_shop])
    end
    self.insertDataIntoCsv(order_position_path, order_position_headers, position_data_rows)
    #end

    # puts "insert into excel"
    self.insertDataIntoSheet(excel_path,retailer,order_headers,data_rows,order_position_headers,position_data_rows)

    # puts "Save into db"
    retailer_report = RetailerReport.new(name: 'orders', retailer_id: retailer.id, export_total: orders.count, from_date: @startDate, to_date: @endDate)
    retailer_report.file1 = File.open(order_path)
    retailer_report.file1.instance_write(:content_type, 'text/csv')
    retailer_report.file2 = File.open(order_position_path)
    retailer_report.file2.instance_write(:content_type, 'text/csv')
    retailer_report.excel = File.open(excel_path)
    retailer_report.excel.instance_write(:content_type, 'application/vnd.ms-excel')
    retailer_report.save!

    puts "OrdersCSV: #{retailer_report.file1.url}"
    puts "PositionsCSV: #{retailer_report.file2.url}"
    puts "Excel: #{retailer_report.excel.url}"

    RetailerMailer.order_report(retailer_report.id).deliver_later
    sleep(1)
    end
  end

  private

  def time_stamped_file(file)
    # file.gsub(/\./,"_#{@startDate.strftime('%Y%m%d%H%M%S')}-#{@endDate.strftime('%Y%m%d%H%M%S')}.") 
    file.gsub(/\./,"_#{@startDate.strftime('%Y%m%d')}-#{@endDate.strftime('%Y%m%d')}.") 
  end

  def self.insertDataIntoCsv(path, headers, data)
    CSV.open(path, "wb") do |csv|
      csv << headers
      data.each do |row|
        csv << row
      end
    end
  end

  def self.insertDataIntoSheet(path,retailer,orderheaders,orders,positionheaders,positions)
    Axlsx::Package.new do |p|
      wb = p.workbook
      wb.styles do |s|
        light_gray =  s.add_style :b => true, :bg_color => "f3f3f3"
        light_blue =  s.add_style :b => true, :bg_color => "c9daf8"
        cell_bold =  s.add_style :b => true
        wb.add_worksheet(:name => retailer.company_name[0..30]) do |sheet|
          sheet.add_row ["Store Code", retailer.id]
          sheet.add_row ["Store Name", retailer.company_name]
          sheet.add_row ["Total Orders", orders.count]
          sheet.add_row ["Accepted Orders", orders.count {|x| x[16] != 4}]
          sheet.add_row ["Total Orders in AED", orders.map {|s| s[10]}.reduce(0, :+)] #orders.map {|s| s['Order Amount'].to_i}.sum
          sheet.add_row ["Total Accepeted Orders in AED", orders.select {|x| x[16] != 4}.map {|s| s[10]}.sum]
          # sheet.add_row ["Date", @startDate.strftime('%Y/%m/%d %H:%M %S'), @endDate.strftime('%Y/%m/%d %H:%M %S')], :style => [light_gray, cell_bold, cell_bold]
          sheet.add_row ["Date", @startDate.strftime('%d/%m/%Y'), @endDate.strftime('%d/%m/%Y')], :style => [light_gray, cell_bold, cell_bold]
          sheet["A1:A6"].each { |c| c.style = light_gray }
          sheet["B1:B6"].each { |c| c.style = cell_bold }

          sheet.add_row [""]

          
          sheet.add_row orderheaders, :style => light_blue
          orders.each do |order|
            sheet.add_row order
          end
          
          sheet.add_row [""]
          sheet.add_row [""]
          sheet.add_row positionheaders, :style => light_blue
          positions.each do |posi|
            sheet.add_row posi
          end
        end
      end
      p.serialize(path)
    end
  end
  
end