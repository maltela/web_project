if (@user)
  json.extract!  :salt_masterkey, :privkey_user_enc, :pubkey_user
end