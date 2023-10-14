class QuestionsController < ApplicationController
  def show
  # パラメータを受け取り、変数level,type,group,pageに代入する
    level = params[:level]
    type = params[:type]
    group = params[:group]
    page = params[:page]

    # group == 1..3について、次の場合分けを行う
    # group == 1 => number_for_each_level: 1..20
    # group == 2 => number_for_each_level: 21..40
    # group == 3 => number_for_each_level: 41..60
    # 場合分けと取得したgroupの値に基づき、numberを制限する
    # 制限された値をquestions_with_limited_numに代入する
    questions_with_limited_num = []
    if group == 1
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 1..20)
    elsif group == 2
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 21..40)
    elsif group == 3
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 41..60)
    else
      # エラーハンドリング: 無効なパラメータ
      flash[:error] = "有効なパラメータではありません。"
      redirect_to root_path
      return
    end

    # questions_with_limited_numを、取得したid(level_of_chinese_character)に基づき、レベルも制限する
    # 制限された値をquestions_with_limited_num_and_levelに代入する
    questions_with_limited_num_and_level =  questions_with_limited_num.where(level_of_chinese_character: level, group: group)

    #   page = [1, page, 4].sort[1]
    #   @questions = selected_mean_questions
    #   @page = page

    # questions_with_limited_num_and_levelを、取得したtypeの値に基づき、場合分けする
    # type == read => :reading_of_chinese_characterをselectし@questionsに代入
    # type == mean => :meaning_of_chinese_characterをselectし@questionsに代入
    if type == "read"
      @questions = questions_with_limited_num_and_level.select(:id, :chinese_character, :reading_of_chinese_character)
    elsif type == "mean"
      @questions = questions_with_limited_num_and_level.select(:id, :chinese_character, :meaning_of_chinese_character)
    else
      # エラーハンドリング: 未知の問題タイプ
      flash[:error] = "未知の問題タイプです。"
      redirect_to root_path
      return
    end

    # @questionsから無作為に(order("RANDOM()"))、5問のみ(limit)抽出して@question_setに代入する
    @question_set = @questions.order("RANDOM()").limit(5)


    @questions_with_choices = []
    @question_set.each do |question|
      # generate_choicesはprivateの中で定義する
      choices = generate_choices(question, type)
      @questions_with_choices << { question: question, choices: choices }
    end

    @question_set.each do |question|
      session[:question_history] << question.id
    end

  end

  def result
  end

  def score
  end

  private
  def generate_choices(question, type)
      # 問題と同じレベルの他の熟語を3つ取得
      # .where.notは()内に指定したidがquestion.idとは異なるものを取得する
    choices = ChineseCharacter.where(level_of_chinese_character: question.level_of_chinese_character)
                              .where.not(id: question.id)
                              .order("RANDOM()")
                              .limit(3)

    # ラジオボタン用の選択肢を作成
    answer_options = []
    answer_options << (type == "read" ? question.reading_of_chinese_character : question.meaning_of_chinese_character)
    choices.each { |choice| answer_options << (type == "read" ? choice.reading_of_chinese_character : choice.meaning_of_chinese_character) }
    answer_options.shuffle!
    return answer_options
  end

end
