class UsersController < ApplicationController
  def my_page
    @user = current_user
    
    read_corrects_chinese_characters = Correct.where(user_id: @user.id, type: 1, correct_of_reading: true).pluck(:chinese_character_id)
    Correct.where(chinese_character_id: read_corrects_chinese_characters).each do
      
    end

    @user.the_number_of_correct_answers = Correct.count { |correct| correct.correct_of_reading == true && correct.correct_of_meaning == true }

    @count_all_chinese_characters = ChineseCharacter.count
    @rank_of_current_user = User.where("the_number_of_correct_answers > ?", @user.the_number_of_correct_answers).count + 1
    @count_all_users = User.count

    (0..4).each do |level|
      Correct.where(correct_of_reading: true, correct_of_meaning: true)
      correct_set_level = ChineseCharacter.where(level_of_chinese_character: level).pluck(:chinese_character_id)
      User.all.each do |user|
        if correct_set_level.all? { |ch_id| user.corrects.find_by(chinese_character_id: ch_id)&.correct_of_reading && user.corrects.find_by(chinese_character_id: ch_id)&.correct_of_meaning }
          user.update(level: level)
        end
      end
    end

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
