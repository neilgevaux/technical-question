GROUP_SHEET_IDS = {
    'Perkins' => '1xDQeHH9hwi3HqxOE4iJDgQfEnZVkjU9z9j9FuM6gMB6',
    'Saunders' => '1QrcnBWkIzWKDd5bcBLiSl2nI5eopkUYjCRKoaNtEhzl',
    'Wood' => '1AQ0DkwbzhKw5HQQuILOICfqcweZX72oIl3k136zxpb8'
     # Create the Izzard sheet and add the ID
     'Izzard' => 'Some ID'
    }
   
FEEDBACK_SHEET_ID = '1HdLjnfBpIyTB1eeGKUFmr2va9MZFzP3qH7U0B8vx1TA'
    
def aggregate_feedback
   
  group_sheets = GROUP_SHEET_IDS.transform_values { |id| Sheets.open(id)['Sheet1'] }
    
  log "Opened group sheets", group_sheets
    
  response_sheet = Sheets.open(FEEDBACK_SHEET_ID)['Form Responses']
    
  items = response_sheet.as_hashes
  log "Begin batch of #{items.length} items" 
    
  items.each do |entry|
    log "Process entry", entry
    # Begin rescue block
    begin
      username = entry[:username] 
      comment = entry[:comment]
      group = entry[:group]
    rescue => e # This rescues StandardError, which NoMethodError inherits from
      log "Group does not exist"
      # Or create a sheet using the API
    else
      sheet = group_sheets[group]
 
      # Original query
      query = "select supervisor_initials from student_supervisor where username='#{username}'"
 
      # Parameterised query/bind parameters
      query = db.prepare("select DISTINCT supervisor_initials from student_supervisor where username = ?")
      db.execute(username)
 
      supervisor = DB[query].get(:supervisor_initials)
    
      sheet.append(username, supervisor, comment)
    end
  end
log 'End batch action'