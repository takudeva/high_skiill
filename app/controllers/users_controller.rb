class UsersController < ApplicationController
  def my_page

    @user = User.find(current_user.id)

    read_corrects_even_once_id = Correct.where(user_id: @user.id, type: 1, correct_of_reading: true).order(chinese_character_id: "ASC").pluck(:chinese_character_id).uniq
    mean_corrects_even_once_id = Correct.where(user_id: @user.id, type: 2, correct_of_meaning: true).order(chinese_character_id: "ASC").pluck(:chinese_character_id).uniq
    counts = {}
    (0..4).each do |level|
      counts["read_corrects_even_once_level_#{level}_count"] = ChineseCharacter.where(id: read_corrects_even_once_id, level_of_chinese_character: level).count
      counts["mean_corrects_even_once_level_#{level}_count"] = ChineseCharacter.where(id: mean_corrects_even_once_id, level_of_chinese_character: level).count
    end

    set_level("read", counts)
    set_level("mean", counts)


    corrects = []
    chinese_character_id_answered_by_current_user = Correct.where(user_id: @user.id).order(chinese_character_id: "ASC").pluck(:chinese_character_id).uniq
    chinese_character_id_answered_by_current_user.each do |num|
      last_read_correct = Correct.where(chinese_character_id: num, type: 1).last
      last_mean_correct = Correct.where(chinese_character_id: num, type: 2).last
      if last_read_correct.nil? || last_mean_correct.nil?
        corrects << 0
      elsif last_read_correct.correct_of_reading == true && last_mean_correct.correct_of_meaning == true
        corrects << 1
      else
        corrects << 0
      end
    end
    @user.the_number_of_correct_answers = corrects.count(1)

    @count_all_chinese_characters = ChineseCharacter.count

    @rank_of_current_user = User.where("the_number_of_correct_answers > ?", @user.the_number_of_correct_answers).count + 1

    @count_all_users = User.count

    @user.save!
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
  def set_level(field, counts)
    levels = [4, 3, 2, 1, 0]
    levels.each do |level|
      if counts["#{field}_corrects_even_once_level_#{level}_count"] > 50
        @user.send("#{field}_level=", level)
        return
      end
    end
    @user.send("#{field}_level=", 5)
  end

end
