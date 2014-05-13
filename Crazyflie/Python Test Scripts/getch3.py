from getch import getch, pause
check = True

while check:
	key = getch()
	print 'You pressed:', key
	if key == 'k':
		check = False
		print "DIE!!!!!"
	        break	


