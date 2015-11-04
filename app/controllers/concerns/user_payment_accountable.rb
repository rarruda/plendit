module UserPaymentAccountable
  extend ActiveSupport::Concern


  # GET/POST /me/bank_account
  def bank_account
    if request.post?
      #@user = current_user
      if @user_payment_account.update(user_payment_account_params)
        redirect_to payment_users_path( anchor: 'kontonummer' ), payment_account_notice: 'bank account was successfully updated.'
      else
        render 'edit_user_payment_account', payment_account_notice: 'bank account was NOT saved.'
      end
    else
      render 'edit_user_payment_account'
    end
  end


  private
  def set_user_payment_account
    @user_payment_account = current_user.user_payment_account || current_user.build_user_payment_account
  end

  def user_payment_account_params
    params.require(:user_payment_account).permit(:bank_account_number) || nil
  end
end