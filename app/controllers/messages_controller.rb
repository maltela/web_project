class MessagesController < ApplicationController

  respond_to :html, :json

  #im respond_with muss noch ein error_Code ausgegeben werden
  # GET /messages
  # GET /messages.json
  def index
    @message = Message.find_by_sql("select id from messages where ????")

    # Beziehung zwischen Users und Messages unklar
    ## Inwiefern?


    respond_with(@message)
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    #Woher nimmst du die identity, timestamp und sig_message?
    #Und was willst du genau mit sig_message machen? Den Parameter gibt es nicht in der
    # Datenbank
    @message = Message.find_by_sql(["select identity,cipher,iv,key_recipient_enc,sig_recipient
                                    from messages m
                                    join users u
                                    on m.recipient=id=user_id
                                    where u.identity=?
                                      and m.timestamp=?
                                      and m.sig_message=?
                                    ",identity,timestamp,sig_message])

    respond_with(@message)


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
    newMessage = JSON.parse message_params
    digest = sha256.digest newMessage
    if digest == params[sig_service]
      @message = Message.new(JSON.parse newMessage.inner_envelope)
      if @message.save
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
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
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private


    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:identity, :inner_envelope, :sig_recipient,:timestamp)

    end
end
