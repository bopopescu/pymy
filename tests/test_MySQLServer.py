import unittest

execfile('Z:\github\pymy\pymy\MySQLServer.py')

class MyTest(unittest.TestCase):

    MYSQL_HOSTNAME = '127.0.0.1'
    MYSQL_PORT = 3306
    MYSQL_USER = 'root'
    MYSQL_PASSWORD = 'rootpa55'

    def test_execute_mysql_query(self):
        m = MySQLServer(self.MYSQL_HOSTNAME, self.MYSQL_PORT, self.MYSQL_USER, self.MYSQL_PASSWORD)
        o = m.execute_mysql_query(m.connection, "SELECT COUNT(*) col FROM dual WHERE 1=1")
        self.assertTrue(len(o) == 1)
        self.assertTrue(str(o[0][0]) == "1")

    def test_query_global_status(self):
        m = MySQLServer(self.MYSQL_HOSTNAME, self.MYSQL_PORT, self.MYSQL_USER, self.MYSQL_PASSWORD)
        o = int(m.query_global_status(m.connection, "uptime"))
        self.assertTrue(isinstance(o, int) and o > 0)

    def test_query_global_variables(self):
        m = MySQLServer(self.MYSQL_HOSTNAME, self.MYSQL_PORT, self.MYSQL_USER, self.MYSQL_PASSWORD)
        o = int(m.query_global_variables(m.connection, "INNODB_BUFFER_POOL_INSTANCES"))
        self.assertTrue(isinstance(o, int) and o > 0)

    def test_show_slave_status(self):
        m = MySQLServer(self.MYSQL_HOSTNAME, self.MYSQL_PORT, self.MYSQL_USER, self.MYSQL_PASSWORD)
        o = m.show_slave_status(m.connection) # TODO Need a proper MySQL Cluster for this tests to be meaningful
        self.assertTrue(len(o) == 0)

    def test_show_master_status(self):
        m = MySQLServer(self.MYSQL_HOSTNAME, self.MYSQL_PORT, self.MYSQL_USER, self.MYSQL_PASSWORD)
        o =  m.show_master_status(m.connection)
        self.assertTrue(isinstance(o['position'], int) and o['position'] > 0)
        self.assertEqual(o['file'][:9], "mysql-bin")

    def test_show_databases(self):
        m = MySQLServer(self.MYSQL_HOSTNAME, self.MYSQL_PORT, self.MYSQL_USER, self.MYSQL_PASSWORD)
        o =  m.show_databases(m.connection)
        self.assertTrue(len(o) > 0)
        self.assertTrue(u'mysql' in o)
        self.assertTrue(u'test' in o)
        self.assertTrue(u'information_schema' in o)
        self.assertTrue(u'performance_schema' in o)

    def test_show_tables(self):
        m = MySQLServer(self.MYSQL_HOSTNAME, self.MYSQL_PORT, self.MYSQL_USER, self.MYSQL_PASSWORD)
        o =  m.show_tables(m.connection, 'mysql')
        self.assertTrue(len(o) > 0)
        self.assertTrue(u'user' in o)
        self.assertTrue(u'host' in o)
        self.assertTrue(u'db' in o)
        self.assertTrue(u'proc' in o)

    def test_show_processlist(self):
        m = MySQLServer(self.MYSQL_HOSTNAME, self.MYSQL_PORT, self.MYSQL_USER, self.MYSQL_PASSWORD)
        o =  m.show_processlist(m.connection)
        self.assertTrue(len(o) > 0)
        self.assertTrue(o[0]['progress'] >= 0.0 and isinstance(o[0]['id'], int))