class RetailersSelectInput
  include Formtastic::Inputs::Base

  def to_html
    input_wrapping do
      label_html <<
      content_html
    end
  end

  private

  def content_html
    builder.template.content_tag(:div, id: 'retailers_admin_select', class: 'retailers-input') do
      delivery_zones_select <<
      retailers_select <<
      retailers_list <<
      hidden_field_for_ids
    end
  end

  def delivery_zones_select
    builder.template.select_tag(
      'delivery_zones_select',
      builder.template.options_from_collection_for_select(DeliveryZone.where.not(name: nil), 'id', 'name'),
      include_blank: true
    )
  end

  def retailers_select
    builder.template.content_tag(
      :select,
      '',
      id: 'retailers_select',
      data: Retailer.joins(:delivery_zones)
          .select("retailers.id, retailers.company_name, delivery_zones.id as delivery_zone_id")
          .group_by(&:delivery_zone_id).map do |delivery_zone_id, retailers|
        ["delivery-zone-#{delivery_zone_id}", retailers]
      end.to_h
    )
  end

  def hidden_field_for_ids
    builder.template.content_tag(:div, id: 'retailers_hidden_fields') do
      object.send(method).each.map do |retailer|
        builder.template.hidden_field_tag(
          "#{object.class.to_s.underscore}[retailer_ids][]",
          retailer.id,
          data: {
            retailer_id: retailer.id
          }
        )
      end.join.html_safe
    end
  end

  def retailers_list
    builder.template.content_tag(:ul, id: 'retailers_list') do
      object.send(method).map do |retailer|
        builder.template.content_tag(:li) do
          builder.template.content_tag(:a, '×', href: '#', data: {
            retailer_id: retailer.id
          }) << retailer.company_name
        end
      end.join.html_safe
    end
  end
end
