module UserPaymentAccountable
  extend ActiveSupport::Concern

  # GET /me/user_payment_accounts
  #def index
  #end

  # GET /me/user_payment_accounts
  def bank_account
    render 'edit_user_payment_account'
  end

  # POST /me/user_payment_accounts
  def update_bank_account
    @user = current_user
    if @user_payment_account.update(user_payment_account_params)
      redirect_to payment_users_path( anchor: 'kontonummer' ), notice: 'bank account was successfully updated.'
    else
      render 'edit_user_payment_account', notice: 'bank account was NOT successfully saved.'
    end
  end


  private
  def set_user_payment_account
    @user_payment_account = current_user.user_payment_account || current_user.build_user_payment_account
  end

  def user_payment_account_params
    params.require(:user_payment_account).permit(:bank_account_number)
  end
end