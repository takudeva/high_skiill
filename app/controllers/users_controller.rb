class UsersController < ApplicationController
  def my_page
    @user = current_user
    @count_all_chinese_characters = ChineseCharacter.count
    @count_of_corrects = Correct.count { |correct| correct.correct_of_reading == true && correct.correct_of_meaning == true }
    @count_all_users = User.count
    @rank_of_current_user = User.where("count_of_corrects > ?", @count_of_corrects).count + 1
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
