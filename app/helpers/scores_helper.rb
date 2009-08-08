module ScoresHelper
  
  # Wraps wrong result in <em> tag for conjugation test results
  def wrap_wrong_answers(result, answer)
    return answer == false ? "<em>#{result}</em>" : result
  end
  
end
