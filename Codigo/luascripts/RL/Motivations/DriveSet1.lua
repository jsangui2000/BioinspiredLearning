local folderDir = (...):match("(.-)[^%/]+$")
local DriveSet1 = {}
DriveSet1.fear = require (folderDir.."Fear")
DriveSet1.hunger = require (folderDir.."Hunger")
return DriveSet1