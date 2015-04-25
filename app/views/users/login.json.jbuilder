if (@user)
  json.extract! @user, :salt_masterkey, :privkey_user_enc, :pubkey_user
end