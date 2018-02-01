import sys
sys.path += '/usr/local/lib/python2.7/site-packages',
import psycopg2

def convert(x, i):
	if i == 1 or i == 2:
		return str("{0:.5f}".format(x))
	else:
		return str(int(x))

try:
    conn = psycopg2.connect("dbname='bathymetry' user='btea' host='localhost' password='my_password'")
except:
    print "I am unable to connect to the database1"

cur = conn.cursor()
source_id = ('55104')
query = """select * from file_paths;"""
cur.execute(query, (source_id,))
#source_id file_path
rows = cur.fetchall()
for row in rows:
	sid, file_path = row[0], row[1]
	print sid, file_path
	file_path = 'test_out'
	query = """select * from pings where source_id = %s;"""
	cur.execute(query, (sid,))
	rows = cur.fetchall()
	with open(file_path, 'w') as outFile:
		for row in rows:
			string = ' '.join([convert(row[i], i) for i in range(len(row))]) + ' \n'
			outFile.write(string)
	break
