class MessagesController < ApplicationController

  respond_to :html, :json

  skip_before_action :verify_authenticity_token

  #im respond_with muss noch ein error_Code ausgegeben werden
  # GET /messages
  # GET /messages.json
  def index
    @message = Message.find_by_sql(['select id, sender_id from messages join users on m.recipient_id=user_id', param[:identity]])

    # Beziehung zwischen Users und Messages unklar
    ## Inwiefern?


    respond_with(Base64.encode(@message))
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @json_msg = Message.find_by_sql(['select identity,cipher,iv,key_recipient_enc,sig_recipient
                                    from messages m
                                    join users u
                                    on m.recipient_id=user_id
                                    where u.identity=?
                                      and m.id = ?
                                    ',param[:identity],param[:message_id]
                                    ])


    @inner_envelope = puts JSON.generate(@json_msg.first.sender_id,@json_msg.first.chipher,@json_msg.first.iv,@json_msg.first.key_recipient_enc,@json_msg.first.sig_recipient)
    @message = puts JSON.generate(@inner_envelope,@json_msg.first.sig_recipient,100)

    render json:  Base64.encode(@message)

  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

   # POST /messages
  # POST /messages.json
  def create
    #newMessage = JSON.parse message_params
   # digest = sha256.digest newMessage
   # if digest == params[sig_service]
      message = JSON.parse message_params.inner_envelope
      @sender = User.find_by_sql(['select * from users Where identity like ?;', message.sender])
      @recipient = User.find_by_sql(['select * from users Where identity like ?;', params[:recipient]])
      #@recipient = User.find_by_identity(newMessage.identity)
      @message = Message.new(:cipher => message.cipher, :sig_recipient => message.sig_recipient, :iv => message.iv, :key_recipient_enc => message.key_recipient_enc, :sender_id => @sender.user_id, :recipient_id => @recipient.user_id)
      #@message = Message.new(:cipher => params[:cipher], :sig_recipient => params[:sig_recipient], :iv => params[:iv], :key_recipient_enc => params[:key_recipient_enc], :sender_id => @sender.first.user_id, :recipient_id => @recipient.first.user_id)
      if ((@sender) && (@recipient))
      respond_to do |format|
        if @message.save
          @status_code = {:status_code => 110}
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
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

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
