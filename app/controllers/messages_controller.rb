class MessagesController < ApplicationController

  respond_to :html, :json

  skip_before_action :verify_authenticity_token

  #im respond_with muss noch ein error_Code ausgegeben werden
  # GET /messages
  # GET /messages.json

  def showAll
    message = params[:identity] + params[:timestamp]
    @messages = Message.find_by_sql(['select m.id as message_id, u.identity as recipient, send.identity as identity, m.recipient_id,
                                      sender_id, cipher, sig_recipient, iv, key_recipient_enc, read
                                      from messages m
                                      join users u
                                          on m.recipient_id= u.user_id
                                      join users send
                                          on m.sender_id = send.user_id
                                      where u.identity = ?;
                                    ',params[:identity]])
    if (@messages.first)
      render json: @messages.to_json(only: [:message_id, :identity, :read])
    else
      @status_code = {:status_code => 420}
      render json: @status_code.to_json
    end
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

      sig_message = param[:identity] + param[:timestamp]
      digest = OpenSSL::Digest::SHA256.new
      @user = User.find_by_name(params[:user_id])
      key = OpenSSL::PKey::RSA.new(Base64.decode64(@user.pubkey_user))
      if (key.verify digest, param[:sig_message], sig_message)
        Message.find_by_sql(['Select * from messages where id = ?', params[:message_id]]).first.update_attribute(:read, true)
        render json:  @json_msg.first.to_json(only: [:identity, :cipher, :sig_recipient, :iv, :key_recipient_enc])
      end
    else
      @status_code = {:status_code => 423}
      render json: @status_code.to_json
    end
  end

   # POST /messages
  # POST /messages.json
  def create
    #@status_code = {:status_code => 421}#Verifizierung
    #@status_code = {:status_code => 422}#Timeout

      sig_service = param[:recipient] + param[:inner_envelope] + param[:timestamp]
      @sender = User.find_by_sql(['select * from users Where identity like ?;', params[:inner_envelope][:sender]])
      @recipient = User.find_by_sql(['select * from users Where identity like ?;', params[:recipient]])
      verify_user(@sender.first.pubkey_user, sig_service, param[:sig_service], param[:inner_envelope][:iv])
     if ((User.find_by_identity(@sender.first.identity)) && User.find_by_identity(@recipient.first.identity))
        @message = Message.new(:cipher => params[:inner_envelope][:cipher], :sig_recipient => params[:inner_envelope][:sig_recipient], :iv => params[:inner_envelope][:iv], :key_recipient_enc => params[:inner_envelope][:key_recipient_enc], :sender_id => @sender.first.user_id, :recipient_id => @recipient.first.user_id, :read => false)
        if (@message)
          respond_to do |format|
            if @message.save
              @status_code = {:status_code => 122}
              format.json  { render json: @status_code}
            else
              @status_code = {:status_code => 425}
              format.json  { render json: @status_code}
            end

          end
        else
          @status_code = {:status_code => 425}
          format.json  { render json: @status_code}
        end
      else
        @status_code = {:status_code => 424}
        render json: @status_code.to_json
    end
  end
  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    #newMessage = JSON.parse message_params.decode64
    #digest = sha256.digest newMessage
    #if digest == params[sig_service]
    @message = Message.find_by_sql(["Select* From messages where id = ?", params[:message_id]])
    if (@message)
      if (@message.first.destroy)
        @status_code = {:status_code => 124}
      else
        @status_code = {:status_code => 426}
      end
    else
      @status_code = {:status_code => 427}
    end
    render json: @status_code.to_json
  end

  private


    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.permit(:identity, :inner_envelope, :sig_recipient,:timestamp, :sig_message, :message_id)
    end

    def verify_user(key, message, signature, iv)
      timestamp  = Time.now.to_i

      sha256 = Digest::SHA2.new(256)
      aes = OpenSSL::Cipher.new("AES-256-CFB")
      key = sha256.digest(key)

      aes.decrypt
      aes.key = key
      aes.iv = iv

      if ((((timestamp-params[:timestamp])/ 1.minute)<=5) && (tmpsig == Base64.decode64(signature)))
        return true
      else
        return false
      end
    end
  end
