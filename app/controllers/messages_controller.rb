class MessagesController < ApplicationController

  respond_to :html, :json

  skip_before_action :verify_authenticity_token

  #im respond_with muss noch ein error_Code ausgegeben werden
  # GET /messages
  # GET /messages.json

  def showAll

    @messages = Message.find_by_sql(['select m.id as message_id, u.identity as recipient, send.identity as identity, m.recipient_id,
                                      sender_id, cipher, sig_recipient, iv, key_recipient_enc, read
                                      from messages m
                                      join users u
                                          on m.recipient_id= u.user_id
                                      join users send
                                          on m.sender_id = send.user_id
                                      where u.identity = ?;
                                    ',params[:identity]])

    render json: @messages.to_json(only: [:message_id, :identity, :read])
  end

  # GET /messages/1
  # GET /messages/1.json
  def showMessage
    @json_msg = Message.find_by_sql(['select m.id as message_id, u.identity as recipient, send.identity as identity, m.recipient_id,
                                      sender_id, cipher, sig_recipient, iv, key_recipient_enc, read
                                      from messages m
                                      join users u
                                          on m.recipient_id= u.user_id
                                      join users send
                                          on m.sender_id = send.user_id
                                      where u.identity = ?
                                      and m.id = ?
                                    ',params[:identity],params[:message_id]
                                    ])
    if (@json_msg.first)
      Message.find_by_sql(['Select * from messages where id = ?', params[:message_id]]).first.update_attribute(:read, true)
      render json:  @json_msg.first.to_json(only: [:identity, :cipher, :sig_recipient, :iv, :key_recipient_enc])
    else
      @status_code = {:status_code => 451}
      render json: @status_code.to_json
    end
  end

   # POST /messages
  # POST /messages.json
  def create

   # digest = sha256.digest newMessage
   # if digest == params[sig_service]
      #message = params[:inner_envelope]
      @sender = User.find_by_sql(['select * from users Where identity like ?;', params[:inner_envelope][:sender]])
      @recipient = User.find_by_sql(['select * from users Where identity like ?;', params[:recipient]])
      service = {:envelope => params[:inner_envelope], :recipient => params[:recipient]}
      digest = OpenSSL::Digest.new('sha256')
      sig_service = OpenSSL::HMAC.hexdigest(digest, @sender.first.privkey_user_enc, sig_service)
      #@recipient = User.find_by_identity(newMessage.identity)
     #@message = Message.new(:cipher => params[:cipher], :sig_recipient => params[:sig_recipient], :iv => params[:iv], :key_recipient_enc => params[:key_recipient_enc], :sender_id => @sender.first.user_id, :recipient_id => @recipient.first.user_id)
      if ((@sender) && (@recipient))
        @message = Message.new(:cipher => params[:inner_envelope][:cipher], :sig_recipient => params[:inner_envelope][:sig_recipient], :iv => params[:inner_envelope][:iv], :key_recipient_enc => params[:inner_envelope][:key_recipient_enc], :sender_id => @sender.first.user_id, :recipient_id => @recipient.first.user_id, :read => false)
        respond_to do |format|
        if @message.save
          @status_code = {:status_code => Base64.encode(digest)}
          format.json  { render json: @status_code}
        else
          format.json  { render json: @message.errors, status: 119 }
        end
      end
    end
   # end
  end
  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    newMessage = JSON.parse message_params.decode64
    digest = sha256.digest newMessage
    if digest == params[sig_service]
      @message.destroy
      respond_to do |format|
        format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private


    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.permit(:identity, :inner_envelope, :sig_recipient,:timestamp, :sig_message, :message_id)
      #params.permit(:identity, :cipher, :iv, :key_recipient_enc, :sig_recipient, :timestamp, :pubkey_user, :sig_service)
    end
  end
