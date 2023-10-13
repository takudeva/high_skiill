class HomesController < ApplicationController
  def top
    @question = ChineseCharacter.find_by(id: params[:chinese_character][:level_of_chinese_character])
    params[:group] = 1
    params[:page] = 1
  end

  def about
  end
end
