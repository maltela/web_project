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
      respond_with(@user.pubkey_user)
    else
      respond_with(:status => "Identity not found")
    end
  end

  # GET /users/1
  # GET /users/1.json
  def login
    @user = User.find_by_sql('select * from users Where identity=?;', params[:identity])
    if (@user)
      respond_with(@user.salt_masterkey, @user.privkey_user_enc, @user.pubkey_user, status: 100)
    else
      respond_with(status: 101)
    end
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
            format.html { notice 'User was successfully created.' }
            format.json { render :show, status: 110, location: @user }
          else
            format.html { render :new }
            format.json { render json: @user.errors, status: 119 }
          end
        end
      end
      format.html { render :new }
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
