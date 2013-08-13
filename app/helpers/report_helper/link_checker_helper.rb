module ReportHelper::LinkCheckerHelper

  def response_td(response)
    success = response.is_a?(Fixnum) and response >= 200 and response < 300
    cls = success ? 'successful' : 'unsuccessful'
    content_tag(:td, response, class: cls)
  end

end
