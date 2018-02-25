post '/quotes/add' do
  quote = request[:quote]
  return 403 unless quote.length > 1
  token = request[:token]
  user = valid_token?(token)
  return 403 unless user
  id = $db.execute('SELECT MAX(id) FROM quotes;')[0][0]
  id = if id then id + 1 else 0 end
  $db.execute('INSERT INTO quotes (id, quote, author) VALUES (?, ?, ?);', [id, quote, user])
  {
    'id' => id
  }.to_json
end

post '/quotes/get' do
  offset = if request[:offset] then request[:offset].to_i else 0 end
  rows = $db.execute('SELECT * FROM quotes ORDER BY id DESC LIMIT 10 OFFSET ?;', [offset * 10])
  rows.map! do |row|
    {
      'id' => row[0],
      'quote' => row[1],
      'author' => row[2]
    }
  end
  rows.to_json
end

def get_quotes(page = 0)
  rows = $db.execute('SELECT * FROM quotes ORDER BY id DESC LIMIT 10 OFFSET ?;', [page * 10])
  rows.map! do |row|
    {
      'id' => row[0],
      'quote' => row[1],
      'author' => row[2]
    }
  end
end

def get_page_amount
  rows = $db.execute('SELECT MAX(id) FROM quotes;')
  if rows.empty?
    return 1
  else
    amount = (rows[0][0]/10.0).ceil
    amount = 1 if amount == 0
    return amount
  end
end