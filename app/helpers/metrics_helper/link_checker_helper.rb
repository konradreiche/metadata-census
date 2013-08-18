module MetricsHelper::LinkCheckerHelper

  def response_td(response)
    success = response.is_a?(Fixnum) && response >= 200 && response < 300
    cls = success ? 'successful' : 'unsuccessful'
    content_tag(:td, response, class: cls)
  end

end
