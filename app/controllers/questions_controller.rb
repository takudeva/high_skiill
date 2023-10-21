class QuestionsController < ApplicationController

  def show
  # パラメータを受け取り、変数level,type,group,pageに代入する
    level = params[:level]
    type = params[:type]
    group = params[:group]
    page = params[:page]
    generate_quiz(group, page, level, type)
    @type = type
  end

  def answer
    level = params[:level]
    type = params[:type]
      # indexとして取得した値("#{qwc[:question].id}_#{choice}")を5問分("0"-"4")、"_"を境に切り離し、前者をquestion_idに、後者をselected_choiceに代入
      # ChineseCharacterモデルからquestion_idと同じid、かつ、levelが受け取ったパラメータと同じものを探し、ローカル変数questionに代入
      # correct_choiceにquestion_idとlevelが一致する読み(question.reading_of_chinese_character)を代入しておく
      # selected_choice == correct_choiceかを判定 => 真の場合、is_correctに"true"代入、偽は"false"代入
      # @correct.correct_of_readingにはis_correct => 真偽値が代入される
    @answers =[]
    [0,1,2,3,4].each do |i|
      correct = Correct.new
      question_id = params[:chinese_character_of_question][i]
      selected_id, selected_choice = params[i.to_s].split("_")
      question = ChineseCharacter.find_by!(id: question_id, level_of_chinese_character: level)
      if type == "read"
        #correct_choice = question.reading_of_chinese_character
        question_id == selected_id ? is_correct = "true" : is_correct = "false"
        correct.correct_of_reading = is_correct
      elsif type == "mean"
        #correct_choice = question.meaning_of_chinese_character
        question_id == selected_id  ? is_correct = "true" : is_correct = "false"
        correct.correct_of_meaning = is_correct
      end
      correct.user_id = current_user.id
      correct.chinese_character_id = question.id
      correct.save!
      @answers << correct
    end
    flash[:success] = "解答しました"
    result
    #@answer.each do | answer |
    #  pp answer
    #  pp answer.chinese_character.chinese_character
    #  pp answer.correct_of_reading
    #end
    #redirect_to answer_questions_path

  end

  def result
    level = params[:level]
    type = params[:type]
    group = params[:group]
    page = params[:page]
    #generate_quiz(group, page, level, type)
    @type = type
    render :result
  end

  def score
  end

  private
  def generate_quiz(group, page, level, type)

    questions_with_limited_num = []
    if group.to_i == 1
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 1..20)
    elsif group.to_i == 2
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 21..40)
    elsif group.to_i == 3
      questions_with_limited_num = ChineseCharacter.where(number_for_each_level: 41..60)
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

    previous_questions = session[:previous_questions] || []
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