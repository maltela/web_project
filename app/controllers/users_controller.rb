class UsersController < ApplicationController
  respond_to :html, :json
  skip_before_action :verify_authenticity_token
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end
  def pubKey
    @user = User.find_by_identity(params[:identity])
    if (@user)
      @pubkey = {:pubkey_user => @user.pubkey_user, :status => 200}
    else
      @pubkey = {:status => "400"}
    end
    render json: @pubkey.to_json
  end

  # GET /users/1
  # GET /users/1.json
  def login
    @user = User.find_by_sql(['select * from users Where identity like ?;', params[:identity]])
    if (@user)
      @userdata =  {:salt_masterkey => @user.first.salt_masterkey, :privkey_user_enc => @user.first.privkey_user_enc, :pubkey_user => @user.first.pubkey_user, :status => 200}
    else
      @userdata = {:status => 101}
    end
    render json: @userdata.to_json
  end

  # GET /users/new
  def new
    @user = User.new
  end
  # POST /users
  # POST /users.json
  def register
    @user = User.new(user_params)
    respond_to do |format|
      if !(User.find_by_identity(@user.identity))
        respond_to do |format|
          if @user.save
            @status_code = {:status_code => 110}
            format.json  { render json: @status_code}
          else
            format.json { render json: @user.errors, status: 119 }
          end
        end
      end
      format.json { render json: @user.errors, status: 111}
      end

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
