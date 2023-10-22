class QuestionsController < ApplicationController

  def show
    session[:previous_questions] = [] if params[:page].to_i <= 1 # 1ページ目の時、過去問セッションをクリア
    level = params[:level]
    type = params[:type]
    group = params[:group]
    page = params[:page]

    # 引数が不足している場合のエラー処理
    redirect_to root_path and return if level.blank? || type.blank? || group.blank? || page.blank?

    generate_quiz(group, page, level, type)
    @type = type
  end

  def answer
    valid_params = (0..4).all? { |i| params[i.to_s].present? }
    if valid_params

      level = params[:level]
      type = params[:type]

      @answers = []
      [0,1,2,3,4].each do |i|
        # fix_me  選択されていないラジオボタンがある時のエラー
        # redirect_to root_path and return if blank?
        question_chinese_character_id = params[:question_chinese_character_id][i]
        selected_id, selected_choice = params[i.to_s].split("_")
        question = ChineseCharacter.find_by!(id: question_chinese_character_id)
        correct = Correct.new
        correct.user_id = current_user.id
        correct.chinese_character_id = question.id
        if type == "read"
          question_chinese_character_id == selected_id ? is_correct = "true" : is_correct = "false"
          correct.correct_of_reading = is_correct
        elsif type == "mean"
          question_chinese_character_id == selected_id  ? is_correct = "true" : is_correct = "false"
          correct.correct_of_meaning = is_correct
        end
        correct.save!
        @answers << correct
      end
      flash[:success] = "解答しました"
      result
    else
      redirect_to root_path
    end
  end

  def result
    level = params[:level]
    type = params[:type]
    group = params[:group]
    page = params[:page]
    @type = type
    redirect_to root_path, notice: "不正な操作です。" and return if @answers.blank?
    render :result
  end

  def score
    @type = params[:type]
    if @type == "read"
      @count_of_corrects = Correct.where(user_id: current_user.id).last(20).count { |correct| correct.correct_of_reading == true }
    elsif @type == "mean"
      @count_of_corrects = Correct.where(user_id: current_user.id).last(20).count { |correct| correct.correct_of_meaning == true }
    end
  end
  private
  def generate_quiz(group, page, level, type)
    previous_questions = session[:previous_questions] || [] # セッション内に保持されている問題番号取得(1)

    questions_with_limited_num = []

    # where.notで、(1)に含まれない問題の取得
    if group.to_i == 1
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 1..20).where.not(id: previous_questions)
    elsif group.to_i == 2
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 21..40).where.not(id: previous_questions)
    elsif group.to_i == 3
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 41..60).where.not(id: previous_questions)
    else
      flash[:error] = "有効なパラメータではありません。"
    end

    questions_per_page = 5
    total_pages = (questions_with_limited_num.count / questions_per_page)
    current_page = page.to_i
    offset = (current_page - 1) * questions_per_page
    if current_page < 1 || current_page > total_pages
      flash[:error] = "ページが存在しません。"
    end

    # TODO: RAND()とRANDOM()でデプロイ後DB違いでエラー発生する想定
    # ref: https://taitan916.info/blog/archives/2486
    questions_with_limited_num_and_level = questions_with_limited_num.where(level_of_chinese_character: level)
    question_set = questions_with_limited_num_and_level.order("RANDOM()").limit(5)
    @questions_with_choices = []
    question_set.each do |question|
      choices = generate_choices(question, type)
      @questions_with_choices << { question: question, choices: choices }
      previous_questions << question.id
    end
  end

  def generate_choices(question, type)
    choices = ChineseCharacter.where(level_of_chinese_character: question.level_of_chinese_character)
                              .where.not(id: question.id)
                              .order("RANDOM()")
                              .limit(3)
    answer_options = []
    answer_options << (type == "read" ? question.reading_of_chinese_character : question.meaning_of_chinese_character)
    choices.each do |choice|
      answer_options << (type == "read" ? choice.reading_of_chinese_character : choice.meaning_of_chinese_character)
    end
    answer_options.shuffle!
    return answer_options
  end

end