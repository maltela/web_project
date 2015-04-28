json.array!(@message) do |message|
  json.extract! message, :id, :timestamp
  json.url message_url(message, format: :json)
end
