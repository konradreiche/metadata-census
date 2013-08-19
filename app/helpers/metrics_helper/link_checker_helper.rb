module MetricsHelper::LinkCheckerHelper

  def successful?(code)
    code.is_a?(Fixnum) && code >= 200 && code < 300
  end

  def response_td(response)
    cls = successful?(response) ? 'successful' : 'unsuccessful'
    content_tag(:td, response, class: cls)
  end

end
