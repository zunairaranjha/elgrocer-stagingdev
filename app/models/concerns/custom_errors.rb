class CustomErrors
  include Singleton

  def unauthorized
    { error_code: 4000, error_message: I18n.t('errors.unauthorized') }
  end

  def employee_not_exist
    { error_code: 4001, error_message: I18n.t('errors.employee_not_found') }
  end

  def only_for_employee
    { error_code: 4002, error_message: I18n.t('errors.only_for_employee') }
  end

  def update_to_latest
    { error_code: 4003, error_message: I18n.t('errors.update_to_latest') }
  end

  def already_login
    { error_code: 4004, error_message: I18n.t('errors.already_login') }
  end

  def invalid_credential
    { error_code: 4005, error_message: I18n.t('errors.invalid_credential') }
  end

  def order_not_found
    { error_code: 4006, error_message: I18n.t('errors.order_not_found') }
  end

  def only_for_superuser
    { error_code: 4007, error_message: I18n.t('errors.only_for_superuser') }
  end

  def order_status(status)
    { error_code: 4008, error_message: I18n.t('errors.order_status', status: status) }
  end

  def something_wrong
    { error_code: 4009, error_message: I18n.t('errors.something_wrong') }
  end

  def retailer_not_have_order
    { error_code: 4010, error_message: I18n.t('errors.retailer_not_have_order') }
  end

  def order_already_allocated
    { error_code: 4011, error_message: I18n.t('errors.order_already_allocated') }
  end

  def order_already_in_substitution
    { error_code: 4012, error_message: I18n.t('errors.order_already_in_substitution') }
  end

  def employee_not_have_role
    { error_code: 4013, error_message: I18n.t('errors.employee_not_have_role') }
  end

  def order_status_not_appends
    { error_code: 4014, error_message: I18n.t('errors.status_not_appends') }
  end

  def already_captured
    { error_code: 4015, error_message: I18n.t('errors.already_captured') }
  end

  def payment_failed(reason)
    { error_code: 4016, error_message: I18n.t('errors.payment_failed', reason: reason) }
  end

  def not_online_payment_no_card
    { error_code: 4017, error_message: I18n.t('errors.not_online_payment_no_card') }
  end

  def card_not_found
    { error_code: 4018, error_message: I18n.t('errors.card_not_found') }
  end

  def not_have_payment_type
    { error_code: 4019, error_message: I18n.t('errors.not_have_payment_type') }
  end

  def payment_details_missing
    { error_code: 4020, error_message: I18n.t('errors.payment_details_missing') }
  end

  def not_allowed
    { error_code: 4021, error_message: I18n.t('errors.not_allowed') }
  end

  def retailer_not_found
    { error_code: 4022, error_message: I18n.t('errors.retailer_not_found') }
  end

  def only_shopper_can_change
    { error_code: 4023, error_message: I18n.t('errors.only_shopper_can_change') }
  end

  def params_missing
    { error_code: 4024, error_message: I18n.t('errors.params_missing') }
  end

  def shopper_not_found
    { error_code: 4025, error_message: I18n.t('errors.shopper_not_found') }
  end

  def collector_not_found
    { error_code: 4026, error_message: I18n.t('errors.collector_not_found') }
  end

  def last_active_employee
    { error_code: 4027, error_message: I18n.t('errors.last_active_employee') }
  end

  def unable_to_process_request
    { error_code: 4028, error_message: I18n.t('errors.unable_to_process_request') }
  end

  def vehicle_not_found
    { error_code: 4029, error_message: I18n.t('errors.vehicle_not_found') }
  end

  def shopper_address_not_found
    { error_code: 4030, error_message: I18n.t('errors.shopper_address_not_found') }
  end

  def retailer_not_have_service
    { error_code: 4031, error_message: I18n.t('errors.retailer_not_have_service') }
  end

  def payment_type_invalid
    { error_code: 4032, error_message: I18n.t('errors.payment_type_invalid') }
  end

  def retailer_not_open_for_order
    { error_code: 4033, error_message: I18n.t('errors.retailer_not_open_for_order') }
  end

  def location_not_covered_retailer
    { error_code: 4034, error_message: I18n.t('errors.location_not_covered_retailer') }
  end

  def products_empty
    { error_code: 4035, error_message: I18n.t('errors.products_empty') }
  end

  def shopper_address_id_missing
    { error_code: 4036, error_message: I18n.t('errors.shopper_address_id_missing') }
  end

  def value_not_enough
    { error_code: 4037, error_message: I18n.t('errors.value_not_enough') }
  end

  def invalid_promo
    { error_code: 4038, error_message: I18n.t('errors.invalid_promo') }
  end

  def promo_expired
    { error_code: 4039, error_message: I18n.t('errors.promo_expired') }
  end

  def max_allowed_realization_exceed
    { error_code: 4040, error_message: I18n.t('errors.max_allowed_realizations') }
  end

  def promo_not_for_retailer
    { error_code: 4041, error_message: I18n.t('errors.promo_not_for_retailer') }
  end

  def promo_already_used
    { error_code: 4042, error_message: I18n.t('errors.promo_already_used') }
  end

  def promo_invalid_brands(brand_names, min_basket_value)
    { error_code: 4043, error_message: I18n.t('errors.promotion_invalid_brands', brand_names: brand_names, min_basket_value: min_basket_value) }
  end

  def payment_invalid_for_promo
    { error_code: 4044, error_message: I18n.t('errors.payment_invalid_for_promo') }
  end

  def promo_order_limit(order_limit)
    { error_code: 4045, error_message: I18n.t('errors.promo_order_limit', order_limit: order_limit) }
  end

  def delivery_slot_not_exits
    { error_code: 4046, error_message: I18n.t('errors.delivery_slot_not_exist') }
  end

  def delivery_slot_invalid
    { error_code: 4047, error_message: I18n.t('errors.delivery_slot_invalid') }
  end

  def slot_filled
    { error_code: 4048, error_message: I18n.t('errors.slot_filled') }
  end

  def delivery_type_invalid
    { error_code: 4049, error_message: I18n.t('errors.delivery_type_invalid') }
  end

  def pickup_location_not_found
    { error_code: 4050, error_message: I18n.t('errors.pickup_location_not_found') }
  end

  def shopper_not_have_order
    { error_code: 4051, error_message: I18n.t('errors.shopper_not_have_order') }
  end

  def order_not_in_edit
    { error_code: 4052, error_message: I18n.t('errors.order_not_in_edit') }
  end

  def order_with_address_processed
    { error_code: 4053, error_message: I18n.t('errors.order_with_address_not_processed') }
  end

  def campaign_not_found
    { error_code: 4054, error_message: I18n.t('errors.campaign_not_found') }
  end

  def recipe_not_found
    { error_code: 4055, error_message: I18n.t('errors.recipe_not_found') }
  end

  def invalid_zone
    { error_code: 4056, error_message: I18n.t('errors.invalid_zone') }
  end

  def category_not_found
    { error_code: 4057, error_message: I18n.t('errors.category_not_found') }
  end

  def product_not_found
    { error_code: 4058, error_message: I18n.t('errors.product_not_found') }
  end

  def not_login
    { error_code: 4059, error_message: I18n.t('errors.not_login') }
  end

  def brand_not_found
    { error_code: 4060, error_message: I18n.t('errors.brand_not_found') }
  end

  def fraudster
    { error_code: 4061, error_message: I18n.t('errors.fraudster') }
  end

  def promo_code_exist
    { error_code: 4062, error_message: I18n.t('errors.promo_code_exist') }
  end

  def value_must_be_greater
    { error_code: 4063, error_message: I18n.t('errors.value_must_be_greater') }
  end

  def end_must_be_greater
    { error_code: 4064, error_message: I18n.t('errors.end_must_be_greater') }
  end

  def promo_not_for_shopper
    { error_code: 4065, error_message: I18n.t('errors.promo_not_for_shopper') }
  end

  def promo_only_for_delivery
    { error_code: 4066, error_message: I18n.t('errors.promo_only_for_delivery') }
  end

  def promo_only_for_cnc
    { error_code: 4067, error_message: I18n.t('errors.promo_only_for_cnc') }
  end

  def product_quantity_limit(qty, product_id)
    { error_code: 4068, error_message: I18n.t('errors.product_quantity_limit', qty: qty), product_id: product_id, available_quantity: qty }
  end

  def products_limited_stock(list)
    { error_code: 4069, error_message: I18n.t('errors.products_limitd_stock'), data: list }
  end

  def card_delete_cancel_order
    { error_code: 4070, error_message: I18n.t('errors.card_delete_cancel_order') }
  end

  def payment_issue(message)
    { error_code: 4071, error_message: I18n.t('errors.payment_issue', message: message) }
  end

  def invalid_reference_number
    { error_code: 4072, error_message: I18n.t('errors.invalid_reference') }
  end

  def otp_attempts_limit
    { error_code: 4073, error_message: I18n.t('errors.tib_loyalty_5000') }
  end

  def invalid_otp
    { error_code: 4074, error_message: I18n.t('errors.tib_loyalty_9057') }
  end

  def low_smiles_balance
    { error_code: 4076, error_message: I18n.t('errors.tib_loyalty_3199') }
  end

  def tib_001
    { error_code: 4077, error_message: I18n.t('errors.tib_001') }
  end

  def tib_002
    { error_code: 4078, error_message: I18n.t('errors.tib_002') }
  end

  def tib_003
    { error_code: 4079, error_message: I18n.t('errors.tib_003') }
  end

  def tib_005
    { error_code: 4080, error_message: I18n.t('errors.tib_005') }
  end

  def tib_999
    { error_code: 4081, error_message: I18n.t('errors.tib_999') }
  end

  def tib_loyalty_3111
    { error_code: 4082, error_message: I18n.t('errors.tib_loyalty_3111') }
  end

  def tib_loyalty_4305
    { error_code: 4083, error_message: I18n.t('errors.tib_loyalty_4305') }
  end

  def tib_loyalty_4316
    { error_code: 4084, error_message: I18n.t('errors.tib_loyalty_4316') }
  end

  def tib_loyalty_4321
    { error_code: 4085, error_message: I18n.t('errors.tib_loyalty_4321') }
  end

  def tib_loyalty_4502
    { error_code: 4086, error_message: I18n.t('errors.tib_loyalty_4502') }
  end

  def tib_loyalty_5101
    { error_code: 4087, error_message: I18n.t('errors.tib_loyalty_5101') }
  end

  def tib_loyalty_5008
    { error_code: 4088, error_message: I18n.t('errors.tib_loyalty_5008') }
  end

  def tib_loyalty_9057
    { error_code: 4089, error_message: I18n.t('errors.tib_loyalty_9057') }
  end

  def tib_loyalty_9059
    { error_code: 4090, error_message: I18n.t('errors.tib_loyalty_9059') }
  end

  def tib_loyalty_9073
    { error_code: 4091, error_message: I18n.t('errors.tib_loyalty_9073') }
  end

  def invalid_pin
    { error_code: 4092, error_message: I18n.t('errors.invalid_pin') }
  end

  def loyalty_sign_in
    { error_code: 4093, error_message: I18n.t('errors.tib_loyalty_5061') }
  end

  def phone_is_blocked
    { error_code: 4094, error_message: I18n.t('errors.tib_loyalty_5000') }
  end

  def phone_max_attempt_reached
    { error_code: 4095, error_message: I18n.t('errors.tib_loyalty_5000') }
  end

  def otp_expired
    { error_code: 4096, error_message: I18n.t('errors.otp_expired') }
  end

  def tib_loyalty_3142
    { error_code: 4097, error_message: I18n.t('errors.tib_loyalty_3142') }
  end

  def tib_loyalty_3133
    { error_code: 4098, error_message: I18n.t('errors.tib_loyalty_3133') }
  end

  def tib_loyalty_3105
    { error_code: 4099, error_message: I18n.t('errors.tib_loyalty_3105') }
  end

  def tib_loyalty_3126
    { error_code: 4100, error_message: I18n.t('errors.tib_loyalty_3126') }
  end

  def tib_loyalty_3117
    { error_code: 4101, error_message: I18n.t('errors.tib_loyalty_3117') }
  end

  def tib_loyalty_3110
    { error_code: 4102, error_message: I18n.t('errors.tib_loyalty_3110') }
  end

  def tib_loyalty_3199
    { error_code: 4103, error_message: I18n.t('errors.tib_loyalty_3199') }
  end

  def tib_loyalty_3104
    { error_code: 4104, error_message: I18n.t('errors.tib_loyalty_3104') }
  end

  def tib_loyalty_3010
    { error_code: 4105, error_message: I18n.t('errors.tib_loyalty_3010') }
  end

  def tib_loyalty_3124
    { error_code: 4106, error_message: I18n.t('errors.tib_loyalty_3124') }
  end

  def tib_loyalty_3101
    { error_code: 4107, error_message: I18n.t('errors.tib_loyalty_3101') }
  end

  def tib_loyalty_3130
    { error_code: 4108, error_message: I18n.t('errors.tib_loyalty_3130') }
  end

  def tib_loyalty_3106
    { error_code: 4109, error_message: I18n.t('errors.tib_loyalty_3106') }
  end

  def tib_loyalty_3141
    { error_code: 4110, error_message: I18n.t('errors.tib_loyalty_3141') }
  end

  def tib_loyalty_3108
    { error_code: 4111, error_message: I18n.t('errors.tib_loyalty_3108') }
  end

  def tib_loyalty_3114
    { error_code: 4112, error_message: I18n.t('errors.tib_loyalty_3114') }
  end

  def tib_loyalty_3138
    { error_code: 4113, error_message: I18n.t('errors.tib_loyalty_3138') }
  end

  def tib_loyalty_3118
    { error_code: 4114, error_message: I18n.t('errors.tib_loyalty_3118') }
  end

  def tib_loyalty_3008
    { error_code: 4115, error_message: I18n.t('errors.tib_loyalty_3008') }
  end

  def tib_loyalty_3131
    { error_code: 4116, error_message: I18n.t('errors.tib_loyalty_3131') }
  end

  def tib_loyalty_3116
    { error_code: 4117, error_message: I18n.t('errors.tib_loyalty_3116') }
  end

  def tib_loyalty_3128
    { error_code: 4118, error_message: I18n.t('errors.tib_loyalty_3128') }
  end

  def tib_loyalty_3129
    { error_code: 4119, error_message: I18n.t('errors.tib_loyalty_3129') }
  end

  def tib_loyalty_3170
    { error_code: 4120, error_message: I18n.t('errors.tib_loyalty_3170') }
  end

  def tib_loyalty_3193
    { error_code: 4121, error_message: I18n.t('errors.tib_loyalty_3193') }
  end

  def tib_loyalty_3140
    { error_code: 4122, error_message: I18n.t('errors.tib_loyalty_3140') }
  end

  def tib_loyalty_3135
    { error_code: 4123, error_message: I18n.t('errors.tib_loyalty_3135') }
  end

  def tib_loyalty_3132
    { error_code: 4124, error_message: I18n.t('errors.tib_loyalty_3132') }
  end

  def tib_loyalty_3125
    { error_code: 4125, error_message: I18n.t('errors.tib_loyalty_3125') }
  end

  def tib_loyalty_3123
    { error_code: 4126, error_message: I18n.t('errors.tib_loyalty_3123') }
  end

  def tib_loyalty_3122
    { error_code: 4127, error_message: I18n.t('errors.tib_loyalty_3122') }
  end

  def tib_loyalty_3120
    { error_code: 4128, error_message: I18n.t('errors.tib_loyalty_3120') }
  end

  def tib_loyalty_3119
    { error_code: 4129, error_message: I18n.t('errors.tib_loyalty_3119') }
  end

  def tib_loyalty_5022
    { error_code: 4130, error_message: I18n.t('errors.tib_loyalty_5022') }
  end

  def tib_loyalty_5042
    { error_code: 4131, error_message: I18n.t('errors.tib_loyalty_5042') }
  end

  def tib_loyalty_5043
    { error_code: 4132, error_message: I18n.t('errors.tib_loyalty_5043') }
  end

  def tib_loyalty_5040
    { error_code: 4133, error_message: I18n.t('errors.tib_loyalty_5040') }
  end

  def tib_loyalty_5041
    { error_code: 4134, error_message: I18n.t('errors.tib_loyalty_5041') }
  end

  def tib_loyalty_5127
    { error_code: 4135, error_message: I18n.t('errors.tib_loyalty_5127') }
  end

  def tib_loyalty_5004
    { error_code: 4136, error_message: I18n.t('errors.tib_loyalty_5004') }
  end

  def tib_loyalty_5005
    { error_code: 4137, error_message: I18n.t('errors.tib_loyalty_5005') }
  end

  def tib_loyalty_5056
    { error_code: 4138, error_message: I18n.t('errors.tib_loyalty_5056') }
  end

  def tib_loyalty_5007
    { error_code: 4139, error_message: I18n.t('errors.tib_loyalty_5007') }
  end

  def tib_loyalty_5061
    { error_code: 4140, error_message: I18n.t('errors.tib_loyalty_5061') }
  end

  def tib_loyalty_5078
    { error_code: 4141, error_message: I18n.t('errors.tib_loyalty_5078') }
  end

  def tib_loyalty_5000
    { error_code: 4142, error_message: I18n.t('errors.tib_loyalty_5000') }
  end

  def tib_loyalty_5006
    { error_code: 4143, error_message: I18n.t('errors.tib_loyalty_5006') }
  end

  def product_missing
    { error_code: 4144, error_message: I18n.t('errors.product_missing') }
  end

  def shop_not_exist
    { error_code: 4145, error_message: I18n.t('errors.shop_not_exist') }
  end

  def substitution_or_proposal_missing
    { error_code: 4147, error_message: I18n.t('errors.substitution_or_proposal_missing') }
  end

  def phone_number_not_same
    { error_code: 4159, error_message: I18n.t('errors.phone_number_not_same') }
  end

  def order_cant_track_on_smiles
    { error_code: 4185, error_message: I18n.t('errors.order_cant_track_on_smiles')}
  end

  def is_valid_phone
    { error_code: 4186, error_message: I18n.t('errors.is_valid_phone')}
  end

  def shopper_registration_failed
    { error_code: 4188, error_message: I18n.t('errors.shopper_registration_failed')}
  end

  def server_error
    { error_code: 4197, error_message: I18n.t('errors.server_error')}
  end
end