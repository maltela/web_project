# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.create()
Message.create(recipient_id: 1000,sender_id: 1001,cipher:'Geheimnachricht',sig_recipient:'Empfänger',iv:'IV',
key_recipient_enc:'Text_KEY_REC_ENV')