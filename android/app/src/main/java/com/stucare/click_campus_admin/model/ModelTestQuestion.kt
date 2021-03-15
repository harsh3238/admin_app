package com.stucare.click_campus_admin.model

import java.io.Serializable

class ModelTestQuestion(val isReport: Boolean) : Serializable {


  var questionId = ""
  var question = ""
  var questionUrl = ""
  var optionA = ""
  var optionAUrl = ""
  var optionB = ""
  var optionBUrl = ""
  var optionC = ""
  var optionCUrl = ""
  var optionD = ""
  var optionDUrl = ""
  var answer = ""
  var usersResponse = ""
  var marks = ""

  var skipped = 0
  var userSelectedAnswer = -1
  var userSelectedOption = ""
}
