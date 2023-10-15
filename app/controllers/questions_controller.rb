class QuestionsController < ApplicationController
  def show
    @correct = Correct.new
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

    # 同じグループ内の20問の問題を5問ずつ、4ページに分けて表示
    questions_per_page = 5
    @total_pages = (questions_with_limited_num.count / questions_per_page.to_f).ceil
    @current_page = page.to_i
    offset = (page.to_i - 1) * questions_per_page

    # ページが範囲外の場合はリダイレクト
    if @current_page < 1 || @current_page > @total_pages
      flash[:error] = "ページが存在しません。"
      redirect_to root_path
      return
    end
    # questions_with_limited_numを、取得したid(level_of_chinese_character)に基づき、レベルも制限する
    # 制限された値をquestions_with_limited_num_and_levelに代入する
    questions_with_limited_num_and_level =  questions_with_limited_num.where(level_of_chinese_character: level, group: group)
    # 以前のページで出題された問題を除外
    previous_questions = session[:previous_questions] || []
    questions_with_limited_num_and_level = questions_with_limited_num_and_level.where.not(id: previous_questions)

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

    # まず、@questions_with_choicesに空の配列(箱)[]を代入する
    # question_setに含まれるquestionそれぞれ(.each)に対し、choicesを用意する
    # @questions_with_choicesにオブジェクト(値はquestion,choices)を追加する
    # generate_choicesはprivateの中で定義する
    # 出した問題のid(question.id)をsession[:question_history]配列に保存することで、回答履歴を保持する
    @questions_with_choices = []
    @question_set.each do |question|
      choices = generate_choices(question, type)
      @questions_with_choices << { question: question, choices: choices }
      session[:previous_questions] << question.id
    end

  end

  def answer
    @correct = Correct.new(correct_params)
    @correct.save
    redirect_to answer_questions_path
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
    # まず、answer_optionsの箱を作る[]、そこに、三項演算子を使ってreadとmeanの場合分けを行いながら、正解の選択肢(question.~)とそれ以外の選択肢(choice.~ <= choices)を追加する( << は箱(配列)[]への追加を意味する)
    # 三項演算子とは、次のように一般化される
    # (条件式 ? 真の場合 : 偽の場合)
    answer_options = []
    answer_options << (type == "read" ? question.reading_of_chinese_character : question.meaning_of_chinese_character)
    choices.each do |choice|
      answer_options << (type == "read" ? choice.reading_of_chinese_character : choice.meaning_of_chinese_character)
    end
    answer_options.shuffle!
    return answer_options
  end

end
