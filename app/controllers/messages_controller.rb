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
    #Woher nimmst du die identity, timestamp und sig_message?
    #Und was willst du genau mit sig_message machen? Den Parameter gibt es nicht in der
    # Datenbankzeigen

    #Parameter
    #/(:identity)/message/(:message_id)/(:timestamp)/(:sig_message)
    ### dann musst du ein param[*] drumherum machen

    ### sig_message ist unsere Signatur zur Überprüfung auf Man in the middle Angriffe
    ### die braucht nicht in der Datenbank zu stehen.
    ### Die wird geprüft und danach verworfen. Die interessiert nur ein mal.
    ### Sig_Recipient hingegen braucht der Empfänger zur Überprüfung ob der Sender auch
    ### der tatsächliche Sender ist.



    @json_msg = Message.find_by_sql(['select identity,cipher,iv,key_recipient_enc,sig_recipient
                                    from messages m
                                    join users u
                                    on m.recipient_id=user_id
                                    where u.identity=?
                                      and m.created_at=?
                                      and m.sig_message=?
                                      and m.id = ?
                                    ',param[:identity],param[:timestamp],param[:message_id]
                                    ])



    # Ausgabe
    #JSON{
    #inner_envelope::JSON(2576 Byte)
        #identity
        #Cipher
        #iv
        #key_recipient_enc
        #sig_recipient"
    #sig_recipient::String(32 Byte)
    #status_code::Integer (2 Byte)}


    ### DRAN DENKEN! Wir müssen uns hinsetzen und Status Codes definieren.
    ### Das hab ich voll verpennt fällt mir grade so auf :D
    @inner_envelope = puts JSON.generate(@json_msg.sender_id,@json_msg.chipher,@json_msg.iv,@json_msg.key_recipient_enc,@json_msg.sig_recipient)
    @message = puts JSON.generate(@inner_envelope,@json_msg.sig_recipient,100)

    respond_with(Base64.encode(@message))

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
    message = JSON.parse request.body.read
   # digest = sha256.digest newMessage
   # if digest == params[sig_service]
    #  message = JSON.parse newMessage.inner_envelope
      @sender = User.find_by_identity(message.identity)
      @recipient = User.find_by_identity(newMessage.identity)
      @message = Message.new(:cipher => message.cipher, :sig_recipient => message.sig_recipient, :iv => message.iv, :key_recipient_enc => message.key_recipient_enc, :sender_id => @sender.user_id, :recipient_id => @recipient.user_id)
      if ((@sender) & (@recipient))
      if @message.save
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
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
      #params.permit(:identity, :inner_envelope, :sig_recipient,:timestamp, :sig_message, :message_id)
      params.permit!
    end
  end
