class QuestionsController < ApplicationController
  def show
  # パラメータを受け取り、変数id,type,group,pageに代入する
    id = ChineseCharacter.find_by!(level_of_chinese_character: params[:id])
    type = params[:type]
    group = params[:group]
    page = params[:page]

    # group == 1..4について、次の場合分けを行う
    # group == 1 => number_for_each_level: 1..20
    # group == 2 => number_for_each_level: 21..40
    # group == 3 => number_for_each_level: 41..60
    # 場合分けと取得したgroupの値に基づき、numberを制限する
    # 制限された値をquestions_with_limited_numに代入する
    case group
    when 1
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 1..20)
    when 2
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 21..40)
    when 3
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 41..60)
    # else
    #   render json: { error: "Invalid group parameter" }, status: :bad_request
    #   return
    end

    # questions_with_limited_numを、取得したid(level_of_chinese_character)に基づき、レベルも制限する
    # 制限された値をquestions_with_limited_num_and_levelに代入する
    questions_with_limited_num_and_level = questions_with_limited_num.where(level_of_chinese_character: id, group: group)

    # questions_with_limited_num_and_levelを、取得したtypeの値に基づき、場合分けする
    # type == read => :reading_of_chinese_characterをselectしread_questionsに代入
    # type == mean => :meaning_of_chinese_characterをselectしmean_questionsに代入
    # read/mean_questionsから無作為に(order("RANDOM()"))、5問のみ(limit)抽出してselected_read/mean_questionsに代入する
    # questionsとしてjsonで出題？
    if type == "read"
      read_questions = questions_with_limited_num_and_level.select(:chinese_character, :reading_of_chinese_character)
      selected_read_questions = read_questions.order("RANDOM()").limit(5)
      page = [1, page, 4].sort[1]
      @questions = selected_read_questions
      @page = page
    else type == "mean"
      mean_questions = questions_with_limited_num_and_level.select(:chinese_character, :meaning_of_chinese_character)
      selected_mean_questions = mean_questions.order("RANDOM()").limit(5)
      page = [1, page, 4].sort[1]
      @questions = selected_read_questions
      @page = page

    # else
      # # render json: { error: "Invalid type parameter" }, status: :bad_request
      # return
    end
    @questions.each do |question|
      session[:question_history] << question.id
    end

  end

  def result
  end

  def score
  end
end
