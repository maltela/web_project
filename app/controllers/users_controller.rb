class UsersController < ApplicationController
  respond_to :html, :json
  skip_before_action :verify_authenticity_token
  require "base64"
  # GET /users
  # GET /users.json
  def getAll
    @users = User.all
    if (user.first)
      render json: @users.to_json(only: [:identity, :pubkey_user])
    else
      @status_code = {:status_code => 413}
      render json: @status_code
    end
  end
  def pubKey
    @user = User.find_by_identity(params[:identity])
    if (@user)
      @pubkey = {:pubkey_user => @user.pubkey_user, :status_code => 112}
    else
      @pubkey = {:status_code => 411}
    end
    render json: @pubkey.to_json
  end

  # GET /users/1
  # GET /users/1.json
  def login
    @user = User.find_by_sql(['select * from users Where identity like ?;', params[:identity]])
    if (@user)
      @userdata =  {:salt_masterkey => @user.first.salt_masterkey, :privkey_user_enc => @user.first.privkey_user_enc, :pubkey_user => @user.first.pubkey_user, :status => 111}
    else
      @userdata = {:status => 411}
    end
    render json: @userdata.to_json
  end


  # POST /users
  # POST /users.json
  def register

    @user = User.new(:identity => params[:identity], :salt_masterkey => params[:salt_masterkey], :pubkey_user => params[:pubkey_user], :privkey_user_enc => params[:privkey_user_enc])
      if !(User.find_by_identity(@user.identity))
          if @user.save
            @status_code = {:status_code => 110}
          else
            @status_code = {:status_code => 412}
          end
      else
        @status_code ={:status_code => 410}
      end
      render json: @status_code.to_json

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.permit(:identity, :salt_masterkey, :pubkey_user, :privkey_user_enc)
    end
end
