class UsersController < ApplicationController
  def my_page

    @user = User.find(current_user.id)

    [0..4].each do |level|
    chinese_character_id_for_each_level = ChineseCharacter.where(level_of_chinese_character: level).pluck(:id)
      if Correct.where(user_id: @user.id, chinese_character_id: chinese_character_id_for_each_level, type: 1).group(:chinese_character_id).having("correct_of_reading == true").count > 50
        @user.read_level = level
      end
    end
    
    corrects = []
    chinese_character_id_answered_by_current_user = Correct.where(user_id: @user.id).order(chinese_character_id: "ASC").pluck(:chinese_character_id).uniq
    chinese_character_id_answered_by_current_user.each do |num|
      last_read_correct = Correct.where(chinese_character_id: num, type: 1).last
      last_mean_correct = Correct.where(chinese_character_id: num, type: 2).last
      last_read_correct.correct_of_reading == true && last_mean_correct.correct_of_meaning == true ? corrects << 1 : corrects << 0
    end
    @user.the_number_of_correct_answers = corrects.count(1)

    @count_all_chinese_characters = ChineseCharacter.count

    @rank_of_current_user = User.where("the_number_of_correct_answers > ?", @user.the_number_of_correct_answers).count + 1
    @count_all_users = User.count

  end

  def edit
    @user = current_user
  end

  def update
    user = current_user
    user.update(user_params)
  end

  def confirm
  end

  def withdrawal
    user = current_user
    if user.update(is_deleated: true)
      reset_session
      flash[:success] = "退会しました"
      redirect_to root_path
    else
      flash[:error] = "退会できませんでした"
      render :my_page
    end
  end

  private
  def user_params
    params.require(:user).permit(:last_name, :first_name, :last_name_kana, :first_name_kana, :nickname, :email )
  end
end
