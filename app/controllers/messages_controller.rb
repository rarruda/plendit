class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  after_action  :notify_user, only: [:create]
  before_filter :authenticate_user!

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)
    @message.from_user_id = current_user.id
    @message.to_user_id = ( @message.from_user_id == @message.booking.from_user_id ) ? @message.booking.ad.user.id : @message.booking.from_user_id

    respond_to do |format|
      if @message.save
        format.html { redirect_to @message.booking }
        format.json {
          @booking = @message.booking.decorate
          render json: (render_to_string partial: 'message_list', formats: [:html]), status: :created
        }
      else
        LOG.error message: "Failed saving message: #{@message.errors}", user_id: current_user.id
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id]).decorate
    end

    # Callback to create a user notification when an message has been created.
    def notify_user
      Notification.new(
        user_id: @message.to_user.id,
        message: "Melding fra #{@message.decorate.from_user.display_name} om \"#{@message.decorate.booking.ad.display_title}\".",
        notifiable: @message.booking).save
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:booking_id, :from_user_id, :to_user_id, :content)
    end
end
