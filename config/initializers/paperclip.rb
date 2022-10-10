Paperclip.options[:content_type_mappings] = {
  csv: 'text/plain',
  jfif: 'image/jpeg'
}

Paperclip::DataUriAdapter.register
Paperclip::UriAdapter.register
Paperclip::HttpUrlProxyAdapter.register