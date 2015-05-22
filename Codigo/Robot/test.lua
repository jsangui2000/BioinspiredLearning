while true do
  local event, param = os.pullEvent()
  if event == 'key' then
    if param == keys.enter then
      break
    else
      print "You didn't press enter!"
    end
  end
end